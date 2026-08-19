import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Thin seam around the `google_mlkit_face_detection` platform channel.
///
/// [FacePhotoValidator] (face_photo_validator.dart) never touches this —
/// only [SelfieCaptureService] does, via this interface, so the acceptance
/// rules stay unit-testable with hand-built [Face] objects and a fake
/// implementation of this class.
abstract class FaceDetectorAdapter {
  Future<List<Face>> detectFaces(InputImage image);

  /// Releases the native detector. Must be called after use.
  Future<void> close();
}

/// Default [FaceDetectorAdapter] backed by ML Kit's on-device face detector.
///
/// Landmarks are required by [FacePhotoValidator]'s acceptance rules, and
/// [FaceDetectorMode.accurate] is required for a reliably-populated
/// `headEulerAngleY` (yaw) — ML Kit only guarantees that angle in accurate
/// mode, not fast mode.
class MlKitFaceDetectorAdapter implements FaceDetectorAdapter {
  MlKitFaceDetectorAdapter()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

  final FaceDetector _detector;

  @override
  Future<List<Face>> detectFaces(InputImage image) =>
      _detector.processImage(image);

  @override
  Future<void> close() => _detector.close();
}
