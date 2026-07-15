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

  // `Get.offAll(DeliveryHomeScreen)` on a dispatch push replaces the delivery
  // screen while it is already mounted, so the incoming coordinator's start()
  // runs before the outgoing one's dispose(). The dead coordinator must not
  // switch off the live one's tracking on its way out.
  test('dispose does not release a mode another coordinator now owns', () async {
    final location = _RecordingModeApplier();
    final outgoing = DriverLocationModeCoordinator<Object>(
      online: true.obs,
      activeJob: Rxn<Object>(Object()),
      location: location,
    );
    await outgoing.start();

    final incoming = DriverLocationModeCoordinator<Object>(
      online: true.obs,
      activeJob: Rxn<Object>(Object()),
      location: location,
    );
    await incoming.start();
    addTearDown(incoming.dispose);

    outgoing.dispose();
    await Future<void>.delayed(Duration.zero);

    // The live coordinator still holds an active job — mode stays background.
    expect(location.modes, isNot(contains(LocationMode.off)));
    expect(location.modes.last, LocationMode.background);
  });

  test('dispose releases the location mode while a job is still active', () async {
    final online = true.obs;
    final activeJob = Rxn<Object>(Object());
    final location = _RecordingModeApplier();
    final coordinator = DriverLocationModeCoordinator<Object>(
      online: online,
      activeJob: activeJob,
      location: location,
    );

    await coordinator.start();
    expect(location.modes, [LocationMode.background]);

    // The applier is app-permanent, so a dispose that only drops the workers
    // would strand the foreground service with nothing left to stop it.
    coordinator.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(location.modes.last, LocationMode.off);
  });
}
