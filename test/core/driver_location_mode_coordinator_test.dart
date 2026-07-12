import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/features/delivery/controllers/driver_location_mode_coordinator.dart';

class _RecordingModeApplier implements LocationModeApplier {
  final modes = <LocationMode>[];

  @override
  Future<void> applyMode(LocationMode mode) async => modes.add(mode);
}

void main() {
  test(
    'driver state changes converge through one ordered mode sequence',
    () async {
      final online = false.obs;
      final activeJob = Rxn<Object>();
      final location = _RecordingModeApplier();
      final coordinator = DriverLocationModeCoordinator<Object>(
        online: online,
        activeJob: activeJob,
        location: location,
      );
      addTearDown(coordinator.dispose);

      await coordinator.start();
      online.value = true;
      await coordinator.settled;
      activeJob.value = Object();
      await coordinator.settled;
      activeJob.value = null;
      await coordinator.settled;
      activeJob.value = Object();
      await coordinator.settled;
      activeJob.value = null;
      await coordinator.settled;
      online.value = false;
      await coordinator.settled;

      expect(location.modes, [
        LocationMode.off,
        LocationMode.foreground,
        LocationMode.background,
        LocationMode.foreground,
        LocationMode.background,
        LocationMode.foreground,
        LocationMode.off,
      ]);
    },
  );
}
