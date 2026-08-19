import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/log.dart';
import 'package:incacook/features/authentication/data/models/requests/create_upload_request.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/services/face_detector_adapter.dart';
import 'package:incacook/features/authentication/data/services/face_photo_validator.dart';
import 'package:incacook/features/authentication/data/services/image_brightness.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';

/// Outcome of [SelfieCaptureService.captureValidateAndUpload]. Exhaustive so
/// callers (the KYC selfie form) can't accidentally forget a branch — in
/// particular, `selfieUrl` must only ever be set from [SelfieCaptureUploaded].
sealed class SelfieCaptureOutcome {
  const SelfieCaptureOutcome();
}

/// The user dismissed the camera without taking a photo.
class SelfieCaptureCancelled extends SelfieCaptureOutcome {
  const SelfieCaptureCancelled();
}

/// Local validation rejected the capture. Nothing was uploaded.
class SelfieCaptureRejected extends SelfieCaptureOutcome {
  const SelfieCaptureRejected(this.reason);

  final FaceRejectionReason reason;
}

/// Capture, camera, normalization, detector, or upload failure — anything
/// that isn't a validation rejection. [message] is already French and safe
/// to show inline.
class SelfieCaptureFailed extends SelfieCaptureOutcome {
  const SelfieCaptureFailed(this.message);

  final String message;
}

/// Validation passed and the upload succeeded. Only this outcome should
/// ever populate `selfieUrl`.
class SelfieCaptureUploaded extends SelfieCaptureOutcome {
  const SelfieCaptureUploaded({required this.file, required this.path});

  final File file;
  final String path;
}

/// Orchestrates the KYC selfie flow end to end: capture → normalize →
/// on-device face validation → upload — in that order, so a rejected photo
/// is never uploaded and `selfieUrl` is never populated for it (issue #45).
///
/// Every dependency is injectable so the flow can be exercised in tests
/// without a camera, a real ML Kit detector, or a live backend: only
/// [MlKitFaceDetectorAdapter] (the default [detector]) touches a platform
/// channel.
class SelfieCaptureService {
  SelfieCaptureService({
    Future<XFile?> Function()? pickImage,
    FaceDetectorAdapter? detector,
    FacePhotoValidator? validator,
    UploadsRepository? uploads,
    this.imageQuality = 85,
    this.maxWidth = 1600,
    this.maxHeight = 1600,
  }) : _pickImage = pickImage,
       _detector = detector ?? MlKitFaceDetectorAdapter(),
       _validator = validator ?? const FacePhotoValidator(),
       _uploads = uploads ?? UploadsRepository.instance;

  final Future<XFile?> Function()? _pickImage;
  final FaceDetectorAdapter _detector;
  final FacePhotoValidator _validator;
  final UploadsRepository _uploads;
  final int imageQuality;
  final double maxWidth;
  final double maxHeight;

  Future<XFile?> _pick() {
    final custom = _pickImage;
    if (custom != null) return custom();
    // Camera-only, front-facing — a gallery pick would defeat the point of
    // a live capture gate.
    return ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  Future<SelfieCaptureOutcome> captureValidateAndUpload() async {
    final XFile? picked;
    try {
      picked = await _pick();
    } catch (e) {
      logError('[Selfie] capture failed: $e');
      return const SelfieCaptureFailed(AppTexts.kycSelfieCaptureFailed);
    }
    if (picked == null) return const SelfieCaptureCancelled();

    final NormalizedImage normalized;
    try {
      normalized = await normalizeImageToJpeg(
        picked,
        imageQuality: imageQuality,
      );
    } on UnsupportedImageTypeException catch (e) {
      return SelfieCaptureFailed(e.message);
    }

    if (normalized.bytes.length > maxUploadBytes) {
      return const SelfieCaptureFailed(AppTexts.imagePickerTooLarge);
    }

    final decoded = img.decodeImage(normalized.bytes);
    if (decoded == null) {
      return const SelfieCaptureFailed(AppTexts.imagePickerUnsupported);
    }

    List<Face> faces;
    try {
      final inputImage = InputImage.fromFilePath(normalized.file.path);
      faces = await _detector.detectFaces(inputImage);
    } catch (e) {
      // Never log the file path, byte contents, or any face-derived value.
      logError('[Selfie] face detector failed: $e');
      return const SelfieCaptureRejected(FaceRejectionReason.detectorFailure);
    } finally {
      await _detector.close();
    }

    final result = _validator.validate(
      FacePhotoValidationInput(
        faces: faces,
        imageWidth: decoded.width,
        imageHeight: decoded.height,
        averageBrightness: computeAverageBrightness(decoded),
      ),
    );

    if (!result.isAccepted) {
      logInfo('[Selfie] rejected: ${result.reason}');
      return SelfieCaptureRejected(result.reason!);
    }

    try {
      final path = await _uploads.upload(
        req: const CreateUploadRequest(
          purpose: UploadPurpose.kycDocument,
          contentType: 'image/jpeg',
        ),
        bytes: normalized.bytes,
      );
      logSuccess('[Selfie] validated capture uploaded');
      return SelfieCaptureUploaded(file: normalized.file, path: path);
    } on ApiFailure catch (e) {
      return SelfieCaptureFailed(e.message);
    } catch (e) {
      return SelfieCaptureFailed(e.toString());
    }
  }
}
