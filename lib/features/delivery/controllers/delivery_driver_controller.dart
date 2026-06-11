import 'package:get/get.dart';

import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';

/// Driver online/offline state. The UI flips this; the controller
/// mirrors it on the backend (`POST /v1/drivers/me/online`) so the
/// matching system + the buyer's tracking pipe know the driver is
/// available.
class DeliveryDriverController extends GetxController {
  static DeliveryDriverController get instance => Get.find();

  final RxBool isOnline = false.obs;
  final RxBool busy = false.obs;
  final RxnString lastError = RxnString();

  /// Flips local state optimistically, then syncs the backend. On
  /// failure the local state reverts and [lastError] is populated.
  /// UI is expected to read [busy] to disable taps mid-flight.
  Future<void> toggle() async {
    if (busy.value) return;
    final next = !isOnline.value;
    busy.value = true;
    lastError.value = null;
    isOnline.value = next;

    try {
      // Best-effort initial fix when going online so matching has a
      // recent point.
      final pos = next ? await LocationService.instance.getCurrent() : null;
      await DeliveriesRepository.instance.setOnline(
        isOnline: next,
        lat: pos?.latitude,
        lng: pos?.longitude,
      );
      if (next) {
        // Keep the geolocator stream open so the periodic push in
        // DeliveryRouteController has data even before a job is
        // accepted.
        await LocationService.instance.start();
      } else {
        LocationService.instance.stop();
      }
    } catch (e) {
      isOnline.value = !next;
      lastError.value = '$e';
    } finally {
      busy.value = false;
    }
  }
}
