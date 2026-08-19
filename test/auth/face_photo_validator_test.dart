import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:incacook/features/authentication/data/services/face_photo_validator.dart';

/// Pure acceptance-rule coverage for [FacePhotoValidator] (issue #45) — no
/// platform channel involved: [Face] is a plain Dart object we build by
/// hand, so every rejection reason and boundary is exercised directly.
void main() {
  const imageWidth = 1000;
  const imageHeight = 1000;
  const validator = FacePhotoValidator();

  Map<FaceLandmarkType, FaceLandmark?> landmarks({bool complete = true}) {
    if (!complete) {
      return {for (final type in FaceLandmarkType.values) type: null};
    }
    return {
      for (final type in FaceLandmarkType.values)
        type: FaceLandmark(type: type, position: const Point<int>(0, 0)),
    };
  }

  Face buildFace({
    double widthRatio = 0.5,
    double centerOffsetXRatio = 0,
    double centerOffsetYRatio = 0,
    bool hasLandmarks = true,
    double? yaw = 0,
    double? roll = 0,
  }) {
    final width = imageWidth * widthRatio;
    final centerX = imageWidth / 2 + imageWidth * centerOffsetXRatio;
    final centerY = imageHeight / 2 + imageHeight * centerOffsetYRatio;
    return Face(
      boundingBox: Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: width,
        height: width,
      ),
      landmarks: landmarks(complete: hasLandmarks),
      contours: const {},
      headEulerAngleY: yaw,
      headEulerAngleZ: roll,
    );
  }

  FacePhotoValidationInput inputWith({
    List<Face>? faces,
    double averageBrightness = 0.5,
  }) => FacePhotoValidationInput(
    faces: faces ?? [buildFace()],
    imageWidth: imageWidth,
    imageHeight: imageHeight,
    averageBrightness: averageBrightness,
  );

  test('rejects when no face is detected', () {
    final result = validator.validate(inputWith(faces: []));
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.noFaceDetected);
  });

  test('rejects when more than one face is detected', () {
    final result = validator.validate(
      inputWith(faces: [buildFace(), buildFace()]),
    );
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.multipleFacesDetected);
  });

  test('accepts a single, centred, frontal, well-lit face', () {
    final result = validator.validate(inputWith());
    expect(result.isAccepted, isTrue);
    expect(result.reason, isNull);
  });

  test('rejects a face that is too small in the frame', () {
    final result = validator.validate(
      inputWith(faces: [buildFace(widthRatio: 0.2)]),
    );
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.faceTooSmall);
  });

  test('rejects a face that is too large (too close) in the frame', () {
    final result = validator.validate(
      inputWith(faces: [buildFace(widthRatio: 0.9)]),
    );
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.faceTooLarge);
  });

  test('rejects a face materially outside the central capture area', () {
    final result = validator.validate(
      inputWith(faces: [buildFace(centerOffsetXRatio: 0.3)]),
    );
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.faceOffCenter);
  });

  test('rejects when required landmarks are unavailable', () {
    final result = validator.validate(
      inputWith(faces: [buildFace(hasLandmarks: false)]),
    );
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.missingLandmarks);
  });

  test('rejects excessive yaw (head turned too far)', () {
    final result = validator.validate(inputWith(faces: [buildFace(yaw: 25)]));
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.excessivePose);
  });

  test('rejects excessive roll (head tilted too far)', () {
    final result = validator.validate(inputWith(faces: [buildFace(roll: -20)]));
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.excessivePose);
  });

  test('rejects when the detector could not compute a pose', () {
    final result = validator.validate(inputWith(faces: [buildFace(yaw: null)]));
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.excessivePose);
  });

  test('rejects an image that is clearly too dark', () {
    final result = validator.validate(inputWith(averageBrightness: 0.05));
    expect(result.isAccepted, isFalse);
    expect(result.reason, FaceRejectionReason.tooDark);
  });

  group('boundary values are inclusive (accepted)', () {
    test('face width exactly at the minimum ratio', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(widthRatio: 0.30)]),
      );
      expect(result.isAccepted, isTrue);
    });

    test('face width exactly at the maximum ratio', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(widthRatio: 0.80)]),
      );
      expect(result.isAccepted, isTrue);
    });

    test('centre offset exactly at the maximum ratio', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(centerOffsetXRatio: 0.20)]),
      );
      expect(result.isAccepted, isTrue);
    });

    test('yaw exactly at the maximum degrees', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(yaw: 18.0)]),
      );
      expect(result.isAccepted, isTrue);
    });

    test('roll exactly at the maximum degrees', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(roll: -15.0)]),
      );
      expect(result.isAccepted, isTrue);
    });
  });

  group('boundary values just past the limit (rejected)', () {
    test('face width just under the minimum ratio', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(widthRatio: 0.299)]),
      );
      expect(result.isAccepted, isFalse);
      expect(result.reason, FaceRejectionReason.faceTooSmall);
    });

    test('yaw just over the maximum degrees', () {
      final result = validator.validate(
        inputWith(faces: [buildFace(yaw: 18.1)]),
      );
      expect(result.isAccepted, isFalse);
      expect(result.reason, FaceRejectionReason.excessivePose);
    });
  });
}
