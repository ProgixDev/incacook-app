import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:incacook/core/constants/text_strings.dart';

/// Why [FacePhotoValidator.validate] rejected a captured selfie.
///
/// This is a presence/quality gate only — it confirms the image contains a
/// plausible, well-framed, frontal face. It does **not** prove liveness and
/// does **not** recognize or identify the person; a photograph of a photo
/// can still pass. See the KYC selfie issue for the out-of-scope note.
enum FaceRejectionReason {
  noFaceDetected,
  multipleFacesDetected,
  faceTooSmall,
  faceTooLarge,
  faceOffCenter,
  missingLandmarks,
  excessivePose,
  tooDark,
  detectorFailure,
}

/// Specific French retry copy for each [FaceRejectionReason], shown inline
/// on the KYC selfie form.
extension FaceRejectionReasonMessage on FaceRejectionReason {
  String get message {
    switch (this) {
      case FaceRejectionReason.noFaceDetected:
        return AppTexts.kycSelfieRejectionNoFace;
      case FaceRejectionReason.multipleFacesDetected:
        return AppTexts.kycSelfieRejectionMultipleFaces;
      case FaceRejectionReason.faceTooSmall:
        return AppTexts.kycSelfieRejectionTooSmall;
      case FaceRejectionReason.faceTooLarge:
        return AppTexts.kycSelfieRejectionTooLarge;
      case FaceRejectionReason.faceOffCenter:
        return AppTexts.kycSelfieRejectionOffCenter;
      case FaceRejectionReason.missingLandmarks:
        return AppTexts.kycSelfieRejectionMissingLandmarks;
      case FaceRejectionReason.excessivePose:
        return AppTexts.kycSelfieRejectionPose;
      case FaceRejectionReason.tooDark:
        return AppTexts.kycSelfieRejectionTooDark;
      case FaceRejectionReason.detectorFailure:
        return AppTexts.kycSelfieRejectionDetectorFailure;
    }
  }
}

/// Outcome of [FacePhotoValidator.validate].
class FaceValidationResult {
  const FaceValidationResult.accepted() : isAccepted = true, reason = null;

  const FaceValidationResult.rejected(FaceRejectionReason this.reason)
    : isAccepted = false;

  final bool isAccepted;
  final FaceRejectionReason? reason;

  @override
  String toString() => isAccepted
      ? 'FaceValidationResult.accepted()'
      : 'FaceValidationResult.rejected($reason)';
}

/// Everything [FacePhotoValidator] needs to judge one capture. Built from
/// the detector's output plus the normalized JPEG's own dimensions and
/// average brightness — no platform channel involved, so this (and the
/// validator itself) is fully unit-testable with hand-built [Face] objects.
class FacePhotoValidationInput {
  const FacePhotoValidationInput({
    required this.faces,
    required this.imageWidth,
    required this.imageHeight,
    required this.averageBrightness,
  });

  final List<Face> faces;
  final int imageWidth;
  final int imageHeight;

  /// Normalized average luminance of the image: 0.0 (black) – 1.0 (white).
  final double averageBrightness;
}

/// Pure acceptance rules for a KYC selfie — no I/O, no platform channels.
///
/// Requires exactly one face that is large enough, centred, frontal, and
/// well-lit. Thresholds are named/configurable per issue #45's suggested
/// starting values and can be tuned without touching the detection or
/// upload plumbing.
class FacePhotoValidator {
  const FacePhotoValidator({
    this.minFaceWidthRatio = 0.30,
    this.maxFaceWidthRatio = 0.80,
    this.maxCenterOffsetRatio = 0.20,
    this.maxAbsYawDegrees = 18.0,
    this.maxAbsRollDegrees = 15.0,
    this.minAverageBrightness = 0.20,
  });

  /// Smallest acceptable face width, as a fraction of the image width.
  final double minFaceWidthRatio;

  /// Largest acceptable face width, as a fraction of the image width.
  final double maxFaceWidthRatio;

  /// Largest acceptable distance between the face centre and the image
  /// centre, as a fraction of the image dimension, checked on each axis.
  final double maxCenterOffsetRatio;

  /// Largest acceptable |headEulerAngleY| (left/right turn), in degrees.
  final double maxAbsYawDegrees;

  /// Largest acceptable |headEulerAngleZ| (tilt), in degrees.
  final double maxAbsRollDegrees;

  /// Smallest acceptable normalized average brightness (0.0–1.0).
  final double minAverageBrightness;

  static const _requiredLandmarks = <FaceLandmarkType>[
    FaceLandmarkType.leftEye,
    FaceLandmarkType.rightEye,
    FaceLandmarkType.noseBase,
    FaceLandmarkType.bottomMouth,
  ];

  FaceValidationResult validate(FacePhotoValidationInput input) {
    if (input.faces.isEmpty) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.noFaceDetected,
      );
    }
    if (input.faces.length > 1) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.multipleFacesDetected,
      );
    }

    final face = input.faces.single;
    final box = face.boundingBox;

    final widthRatio = box.width / input.imageWidth;
    if (widthRatio < minFaceWidthRatio) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.faceTooSmall,
      );
    }
    if (widthRatio > maxFaceWidthRatio) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.faceTooLarge,
      );
    }

    final offsetX =
        (box.center.dx - input.imageWidth / 2).abs() / input.imageWidth;
    final offsetY =
        (box.center.dy - input.imageHeight / 2).abs() / input.imageHeight;
    if (offsetX > maxCenterOffsetRatio || offsetY > maxCenterOffsetRatio) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.faceOffCenter,
      );
    }

    final hasAllLandmarks = _requiredLandmarks.every(
      (type) => face.landmarks[type] != null,
    );
    if (!hasAllLandmarks) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.missingLandmarks,
      );
    }

    final yaw = face.headEulerAngleY;
    final roll = face.headEulerAngleZ;
    if (yaw == null ||
        roll == null ||
        yaw.abs() > maxAbsYawDegrees ||
        roll.abs() > maxAbsRollDegrees) {
      return const FaceValidationResult.rejected(
        FaceRejectionReason.excessivePose,
      );
    }

    if (input.averageBrightness < minAverageBrightness) {
      return const FaceValidationResult.rejected(FaceRejectionReason.tooDark);
    }

    return const FaceValidationResult.accepted();
  }
}
