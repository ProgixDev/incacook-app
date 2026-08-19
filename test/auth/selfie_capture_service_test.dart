import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/models/requests/create_upload_request.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/services/face_detector_adapter.dart';
import 'package:incacook/features/authentication/data/services/face_photo_validator.dart';
import 'package:incacook/features/authentication/data/services/selfie_capture_service.dart';

/// Only [normalizeImageToJpeg] (via `upload_picker.dart`) touches a real
/// platform channel here — `path_provider`'s `getTemporaryDirectory`. Every
/// other seam ([FaceDetectorAdapter], [UploadsRepository], the picker
/// callback) is faked, so these are service tests, not integration tests:
/// no camera, no real ML Kit, no live backend.
class _FakeUploadsRepository extends UploadsRepository {
  _FakeUploadsRepository({this.pathToReturn = 'kyc/selfie-1.jpg', this.error})
    : callCount = 0,
      super(
        api: ApiClient(dio: Dio(), tokenStorage: TokenStorage()),
        rawDio: Dio(),
      );

  final String pathToReturn;
  final Object? error;
  int callCount;

  @override
  Future<String> upload({
    required CreateUploadRequest req,
    required Uint8List bytes,
  }) async {
    callCount++;
    if (error != null) throw error!;
    return pathToReturn;
  }
}

class _FakeFaceDetectorAdapter implements FaceDetectorAdapter {
  _FakeFaceDetectorAdapter({List<Face>? faces, this.error})
    : faces = faces ?? [];

  final List<Face> faces;
  final Object? error;
  bool closed = false;

  @override
  Future<List<Face>> detectFaces(InputImage image) async {
    if (error != null) throw error!;
    return faces;
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}

Face _wellFramedFace() => Face(
  boundingBox: const Rect.fromLTRB(200, 200, 600, 600),
  landmarks: {
    for (final type in FaceLandmarkType.values)
      type: FaceLandmark(type: type, position: const Point<int>(0, 0)),
  },
  contours: const {},
  headEulerAngleY: 0,
  headEulerAngleZ: 0,
);

/// A flat, bright 800x800 JPEG — deterministic dimensions/brightness so the
/// validator's accept path doesn't depend on real photo content.
Uint8List _brightJpegBytes() {
  final image = img.Image(width: 800, height: 800);
  img.fill(image, color: img.ColorRgb8(230, 230, 230));
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

XFile _fakePickedImage() => XFile.fromData(
  _brightJpegBytes(),
  mimeType: 'image/jpeg',
  name: 'selfie.jpg',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `normalizeImageToJpeg` writes the re-encoded JPEG via path_provider so
  // ML Kit's InputImage.fromFilePath has a real file to read — mock the
  // channel to point at a real temp dir instead of hitting a real platform.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  SelfieCaptureService serviceWith({
    List<Face>? faces,
    Object? detectorError,
    _FakeUploadsRepository? uploads,
    Future<XFile?> Function()? pickImage,
  }) {
    final uploadsRepo = uploads ?? _FakeUploadsRepository();
    return SelfieCaptureService(
      pickImage: pickImage ?? () async => _fakePickedImage(),
      detector: _FakeFaceDetectorAdapter(faces: faces, error: detectorError),
      uploads: uploadsRepo,
    );
  }

  test('cancellation returns Cancelled without calling upload', () async {
    final uploads = _FakeUploadsRepository();
    final service = serviceWith(pickImage: () async => null, uploads: uploads);

    final outcome = await service.captureValidateAndUpload();

    expect(outcome, isA<SelfieCaptureCancelled>());
    expect(uploads.callCount, 0);
  });

  test('an invalid capture (no face) is rejected and never uploaded', () async {
    final uploads = _FakeUploadsRepository();
    final service = serviceWith(faces: [], uploads: uploads);

    final outcome = await service.captureValidateAndUpload();

    expect(outcome, isA<SelfieCaptureRejected>());
    expect(
      (outcome as SelfieCaptureRejected).reason,
      FaceRejectionReason.noFaceDetected,
    );
    expect(uploads.callCount, 0);
  });

  test('a valid capture uploads once and returns the path', () async {
    final uploads = _FakeUploadsRepository(pathToReturn: 'kyc/selfie-42.jpg');
    final service = serviceWith(faces: [_wellFramedFace()], uploads: uploads);

    final outcome = await service.captureValidateAndUpload();

    expect(outcome, isA<SelfieCaptureUploaded>());
    expect((outcome as SelfieCaptureUploaded).path, 'kyc/selfie-42.jpg');
    expect(uploads.callCount, 1);
  });

  test(
    'a detector/plugin error is surfaced as a rejection, not an uncaught exception',
    () async {
      final uploads = _FakeUploadsRepository();
      final service = serviceWith(
        detectorError: PlatformException(code: 'boom'),
        uploads: uploads,
      );

      final outcome = await service.captureValidateAndUpload();

      expect(outcome, isA<SelfieCaptureRejected>());
      expect(
        (outcome as SelfieCaptureRejected).reason,
        FaceRejectionReason.detectorFailure,
      );
      expect(uploads.callCount, 0);
    },
  );

  test(
    'a camera/picker error resolves to Failed, not a stuck Future',
    () async {
      final uploads = _FakeUploadsRepository();
      final service = serviceWith(
        pickImage: () async =>
            throw PlatformException(code: 'camera_access_denied'),
        uploads: uploads,
      );

      final outcome = await service.captureValidateAndUpload();

      expect(outcome, isA<SelfieCaptureFailed>());
      expect(uploads.callCount, 0);
    },
  );

  test(
    'an upload failure surfaces as Failed after validation passed',
    () async {
      final uploads = _FakeUploadsRepository(
        error: const ApiFailure(statusCode: 500, code: 'x', message: 'nope'),
      );
      final service = serviceWith(faces: [_wellFramedFace()], uploads: uploads);

      final outcome = await service.captureValidateAndUpload();

      expect(outcome, isA<SelfieCaptureFailed>());
      expect((outcome as SelfieCaptureFailed).message, 'nope');
      expect(uploads.callCount, 1);
    },
  );
}
