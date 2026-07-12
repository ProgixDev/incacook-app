import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/services/location/location_service.dart';

/// Pure decision behind [LocationService.start]'s restart guard: while a stream
/// is already live, only an UPGRADE (foreground → background) restarts it. A
/// foreground request must never implicitly tear down a running background
/// stream — this is the relaunch-mid-delivery bug where the online-restore's
/// foreground `start()` ran after the active-delivery's background `start()`
/// and silently killed background persistence.
void main() {
  group('desiredLocationMode', () {
    test('resolves the complete online and active-delivery matrix', () {
      expect(
        desiredLocationMode(online: false, hasActiveJob: false),
        LocationMode.off,
      );
      expect(
        desiredLocationMode(online: false, hasActiveJob: true),
        LocationMode.off,
      );
      expect(
        desiredLocationMode(online: true, hasActiveJob: false),
        LocationMode.foreground,
      );
      expect(
        desiredLocationMode(online: true, hasActiveJob: true),
        LocationMode.background,
      );
    });
  });

  bool restart(bool current, bool requested) =>
      LocationService.shouldRestartStream(
        currentBackground: current,
        requestedBackground: requested,
      );

  test('foreground → background upgrades (restart)', () {
    expect(restart(false, true), isTrue);
  });

  test('background → foreground never downgrades (keep background)', () {
    expect(restart(true, false), isFalse);
  });

  test('same mode is a no-op — foreground → foreground', () {
    expect(restart(false, false), isFalse);
  });

  test('same mode is a no-op — background → background', () {
    expect(restart(true, true), isFalse);
  });
}
