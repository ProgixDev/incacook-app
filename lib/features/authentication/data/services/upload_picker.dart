import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/features/authentication/data/models/requests/create_upload_request.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';

/// One pick + two-step upload, packaged for any UI that needs more
/// custom presentation than [SignupImagePicker] provides (e.g. the KYC
/// selfie page with its oval frame).
///
/// Returns the picked [File] and the storage `path` returned by
/// `POST /v1/uploads`. Returns null if the user cancelled the picker.
/// Throws [ApiFailure] / [Exception] on upload failure — callers
/// surface those in their own UI state.
class UploadPickResult {
  const UploadPickResult({required this.file, required this.path});

  final File file;
  final String path;
}

Future<UploadPickResult?> pickAndUploadImage({
  required ImageSource source,
  required UploadPurpose purpose,
  int imageQuality = 85,
  double maxWidth = 2048,
  CameraDevice preferredCameraDevice = CameraDevice.rear,
  UploadsRepository? uploads,
}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: source,
    maxWidth: maxWidth,
    imageQuality: imageQuality,
    preferredCameraDevice: preferredCameraDevice,
  );
  if (picked == null) return null;

  final file = File(picked.path);
  final bytes = await file.readAsBytes();
  final repo = uploads ?? UploadsRepository.instance;
  final path = await repo.upload(
    req: CreateUploadRequest(
      purpose: purpose,
      contentType: _guessContentType(file.path),
    ),
    bytes: bytes,
  );
  return UploadPickResult(file: file, path: path);
}

String _guessContentType(String filePath) {
  final lower = filePath.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
