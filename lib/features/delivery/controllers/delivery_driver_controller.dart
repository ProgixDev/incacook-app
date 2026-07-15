import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/error_codes.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/delivery/domain/delivery_driver_models.dart';

/// Driver online/offline state. The UI flips this; the controller
/// mirrors it on the backend (`POST /v1/drivers/me/online`) so the
/// matching system + the buyer's tracking pipe know the driver is
/// available.
class DeliveryDriverController extends GetxController {
  static DeliveryDriverController get instance => Get.find();

  final RxBool isOnline = false.obs;
  final RxBool busy = false.obs;
  final RxnString lastError = RxnString();

  /// Today's dashboard stats. Earnings + delivery count come from the backend
  /// (`GET /drivers/me/stats/today`); online-time is measured on the device
  /// (below), since the server keeps no online-session log. Null until first
  /// load — the card shows a zeroed placeholder in the meantime.
  final Rxn<DailyStats> todayStats = Rxn<DailyStats>();

  // Device-side "online time today" accumulator. Session-scoped: resets on app
  // restart (there's no server log to reconcile against), but reflects real
  // time spent online during the current run.
  Duration _accumulatedOnline = Duration.zero;
  DateTime? _onlineSince;

  /// Online time so far today, including the currently-open session.
  Duration get onlineTimeToday {
    var total = _accumulatedOnline;
    if (isOnline.value && _onlineSince != null) {
      total += DateTime.now().difference(_onlineSince!);
    }
    return total;
  }

  /// True while the driver holds an active delivery. Read reactively (an `Obx`
  /// wrapping a [canToggleOnline] read tracks `currentJob`), and defensively
  /// false when the route controller isn't registered — the driver can't be on
  /// a job if the delivery screen was never mounted.
  bool get hasActiveJob =>
      Get.isRegistered<DeliveryRouteController>() &&
      DeliveryRouteController.instance.currentJob.value != null;

  /// Drivers may only enter matching once KYC is approved, and may only leave
  /// it once they aren't holding a delivery — going offline mid-job kills the
  /// buyer's tracking while the job stays assigned, and nothing re-offers it
  /// post-pickup. The server enforces this too (409); this just avoids the
  /// round-trip.
  bool get canToggleOnline => isOnline.value
      ? !hasActiveJob
      : UserController.instance.canDriverClaim;

  String? get onlineDisabledReason {
    if (isOnline.value) {
      return hasActiveJob
          ? 'Terminez votre livraison en cours avant de passer hors ligne.'
          : null;
    }

    final driver = UserController.instance.user.value?.driverAccount;
    if (driver == null) {
      return 'Profil livreur introuvable. Terminez l\'inscription livreur.';
    }

    return switch (driver.kycStatus.toUpperCase()) {
      'APPROVED' => null,
      'REJECTED' =>
        'KYC refusé. Corrigez vos documents avant de passer en ligne.',
      'PENDING' =>
        'Vérification KYC en attente. Vous pourrez passer en ligne une fois approuvé.',
      _ => 'KYC requis avant de passer en ligne.',
    };
  }

  @override
  void onInit() {
    super.onInit();
    // Populate the dashboard card as soon as the driver screen mounts.
    refreshTodayStats();
  }

  /// Restores the online session on relaunch from the server-side flag
  /// (`DriverProfile.isOnline`, surfaced via `/users/me`). The local [isOnline]
  /// always boots to `false`, so without this a driver who was online before
  /// killing the app reappears "deactivated" with no matching. Does NOT re-POST
  /// `/online` (already online server-side) — it just mirrors the state and
  /// reopens the location stream so matching + tracking resume. Reactive
  /// listeners (online marker, incoming-order polling) fire off the flip.
  Future<void> restoreOnlineState() async {
    if (isOnline.value) return;
    final serverOnline =
        UserController.instance.user.value?.driverAccount?.isOnline ?? false;
    if (!serverOnline) return;
    isOnline.value = true;
    _onlineSince = DateTime.now();
    await refreshTodayStats();
  }

  /// Fetches today's earnings/deliveries and folds in the local online-time.
  /// Best-effort: on failure the previous value (or the zeroed placeholder)
  /// stays put rather than surfacing an error on the dashboard.
  Future<void> refreshTodayStats() async {
    try {
      final s = await DeliveriesRepository.instance.todayStats();
      todayStats.value = DailyStats(
        earnings: s.earningsCents / 100.0,
        onlineTime: onlineTimeToday,
        rides: s.deliveriesCount,
      );
    } catch (_) {
      // Keep whatever we had; the card degrades to zeros, not an error.
      todayStats.value ??= DailyStats(
        earnings: 0,
        onlineTime: onlineTimeToday,
        rides: 0,
      );
    }
  }

  /// Syncs the backend first, then flips local state. This avoids showing an
  /// online map marker when the endpoint rejected the transition.
  Future<void> toggle() async {
    if (busy.value) return;
    final next = !isOnline.value;
    if (next && !canToggleOnline) {
      lastError.value = onlineDisabledReason;
      return;
    }

    busy.value = true;
    lastError.value = null;

    try {
      // Best-effort initial fix when going online so matching has a recent
      // point. A GPS failure should not block the online toggle itself.
      final pos = next ? await _tryCurrentLocation() : null;
      await DeliveriesRepository.instance.setOnline(
        isOnline: next,
        lat: pos?.latitude,
        lng: pos?.longitude,
      );
      isOnline.value = next;
      if (next) {
        // Start counting online-time. The location-mode coordinator reacts to
        // this state flip and opens the idle foreground stream.
        _onlineSince = DateTime.now();
      } else {
        // Fold the just-ended session into the running total.
        if (_onlineSince != null) {
          _accumulatedOnline += DateTime.now().difference(_onlineSince!);
          _onlineSince = null;
        }
      }
      // Reflect the new online-time (and pick up any deliveries closed while
      // online) on the dashboard card.
      await refreshTodayStats();
    } on ApiFailure catch (e) {
      lastError.value = _onlineFailureMessage(e);
    } catch (e) {
      lastError.value = '$e';
    } finally {
      busy.value = false;
    }
  }

  Future<Position?> _tryCurrentLocation() async {
    try {
      return await LocationService.instance.getCurrent();
    } catch (_) {
      return null;
    }
  }

  String _onlineFailureMessage(ApiFailure error) {
    final isKycBlock =
        error.code == IncaCookErrorCodes.forbidden &&
        error.statusCode == 403 &&
        error.message.toLowerCase().contains('kyc');
    if (isKycBlock) {
      return onlineDisabledReason ?? 'KYC requis avant de passer en ligne.';
    }
    return error.message;
  }
}
