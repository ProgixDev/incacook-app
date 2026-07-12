import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/delivery/domain/delivery_map_policy.dart';

void main() {
  test('centers on the driver until an active route can own the camera', () {
    expect(
      shouldCenterDriverOnMapOpen(hasActiveJob: false, hasRoute: false),
      isTrue,
    );
    expect(
      shouldCenterDriverOnMapOpen(hasActiveJob: true, hasRoute: false),
      isTrue,
    );
    expect(
      shouldCenterDriverOnMapOpen(hasActiveJob: true, hasRoute: true),
      isFalse,
    );
  });
}
