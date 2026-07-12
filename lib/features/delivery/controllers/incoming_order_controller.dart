import 'dart:async';

import 'package:get/get.dart';

import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/orders/data/order_mock_data.dart';

/// Driver-side dispatcher: while online with no active job, polls
/// `GET /v1/drivers/me/deliveries/available` and surfaces the first
/// hit through [pendingOrder] / [pendingDeliveryId]. The screen
/// listens to [pendingOrder] and shows the incoming-order modal.
///
/// On accept the screen claims via [DeliveriesRepository.claim] using
/// the captured [pendingDeliveryId], then calls
/// [DeliveryRouteController.acceptJob]. Every field the offer modal
/// displays (seller, pickup/dropoff, payout, recipient, item count) is
/// real, from the available-deliveries response; a template only fills
/// the non-displayed OrderDetail fields the slim list response omits.
class IncomingOrderController extends GetxController {
  static IncomingOrderController get instance => Get.find();

  static const Duration _pollInterval = Duration(seconds: 5);

  /// Idle-online location pushes are throttled hard: an idle driver's matching
  /// position only needs to be coarsely fresh, so we push at most once per
  /// minute instead of before every 5s poll. This is the main server-cost
  /// win — a stationary online driver went from ~12 writes/min to ~1.
  /// (Active-delivery live tracking is handled separately by
  /// [DeliveryRouteController] and stays fast.)
  static const Duration _minLocationPushInterval = Duration(seconds: 60);

  final Rxn<OrderDetail> pendingOrder = Rxn<OrderDetail>();
  final RxnString pendingDeliveryId = RxnString();
  final RxnString pendingOrderId = RxnString();

  /// Delivery ids the driver declined / timed out / lost the claim race
  /// on this online session. Skipped when picking the next job so a
  /// passed offer doesn't immediately re-pop. Cleared on going offline.
  final Set<String> _dismissed = {};

  Timer? _pollTimer;
  Worker? _onlineWorker;
  Worker? _jobWorker;
  bool _polling = false;

  /// Last time an idle location push actually hit the server — throttle gate
  /// for [_minLocationPushInterval]. Reset when going offline.
  DateTime? _lastLocationPushAt;

  @override
  void onInit() {
    super.onInit();
    _onlineWorker = ever<bool>(
      DeliveryDriverController.instance.isOnline,
      _onOnlineChanged,
    );
    _jobWorker = ever<OrderDetail?>(
      DeliveryRouteController.instance.currentJob,
      _onJobChanged,
    );
    if (DeliveryDriverController.instance.isOnline.value) {
      _startPolling();
    }
  }

  void _onJobChanged(OrderDetail? job) {
    if (job == null && DeliveryDriverController.instance.isOnline.value) {
      _startPolling();
    }
  }

  void _onOnlineChanged(bool online) {
    if (online) {
      _startPolling();
    } else {
      _stopPolling();
      pendingOrder.value = null;
      pendingDeliveryId.value = null;
      pendingOrderId.value = null;
      _lastLocationPushAt = null;
      // Fresh slate next time the driver goes online — previously
      // passed jobs become offerable again.
      _dismissed.clear();
    }
  }

  void _startPolling() {
    _stopPolling();
    unawaited(_pollOnce());
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_pollOnce()));
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollOnce() async {
    if (_polling) return;
    final driver = DeliveryDriverController.instance;
    final route = DeliveryRouteController.instance;
    if (!driver.isOnline.value ||
        route.order != null ||
        pendingOrder.value != null) {
      return;
    }
    _polling = true;
    try {
      // Refresh the driver's lastKnownPoint so proximity matching sees an
      // up-to-date position — but throttled to at most once per
      // [_minLocationPushInterval], NOT before every poll. Idle matching
      // tolerates a coarse (up-to-60s-stale) position, and pushing every 5s
      // was a needless server-cost multiplier. Best-effort: silent on failure.
      final now = DateTime.now();
      final lastPush = _lastLocationPushAt;
      final pushDue =
          lastPush == null ||
          now.difference(lastPush) >= _minLocationPushInterval;
      final pos = LocationService.instance.currentPosition.value;
      if (pushDue && pos != null) {
        try {
          await DriversRepository.instance.pushLocation(
            lat: pos.latitude,
            lng: pos.longitude,
            headingDeg: pos.heading >= 0 ? pos.heading : null,
            speedMps: pos.speed >= 0 ? pos.speed : null,
            accuracyM: pos.accuracy,
          );
          _lastLocationPushAt = now;
        } catch (_) {
          // Swallow — listAvailable below will still try.
        }
      }

      // Fetch a small batch and pick the first the driver hasn't
      // already passed on this session — otherwise a declined job
      // (still SEARCHING on the server) would re-pop immediately.
      final list = await DeliveriesRepository.instance.listAvailable(limit: 10);
      DeliverySummary? next;
      for (final d in list) {
        if (_dismissed.contains(d.id)) continue;
        // Skip offers we can't route (no geocoded pickup) — never show the
        // driver a fake/placeholder pickup location.
        if (d.pickupLat == null || d.pickupLng == null) continue;
        next = d;
        break;
      }
      if (next == null) return;
      if (!driver.isOnline.value ||
          route.order != null ||
          pendingOrder.value != null) {
        return;
      }
      pendingDeliveryId.value = next.id;
      pendingOrderId.value = next.orderId;
      pendingOrder.value = hydrateFromSummary(next);
    } catch (_) {
      // Swallow — next poll retries.
    } finally {
      _polling = false;
    }
  }

  /// Called by the screen after the modal closes. For [accepted]=true,
  /// the screen has already claimed + bootstrapped the route. Either
  /// way, clear local state. On decline / timeout, kick another poll
  /// immediately so the next available job pops without delay.
  void resolve({required bool accepted}) {
    final dismissedId = pendingDeliveryId.value;
    pendingOrder.value = null;
    pendingDeliveryId.value = null;
    pendingOrderId.value = null;
    if (!accepted) {
      // Remember the pass so the next poll skips it instead of
      // re-popping the same offer (it's still SEARCHING server-side).
      if (dismissedId != null) _dismissed.add(dismissedId);
      if (DeliveryDriverController.instance.isOnline.value) {
        unawaited(_pollOnce());
      }
    }
  }

  @override
  void onClose() {
    _stopPolling();
    _onlineWorker?.dispose();
    _jobWorker?.dispose();
    super.onClose();
  }

  /// Overlays the real backend data onto the mock OrderDetail template
  /// so the modal renders dynamic info AND DeliveryRouteController has
  /// the real pickup point to route to. Backend-driven fields:
  ///   - id, orderNumber, placedAt, total            (order header)
  ///   - seller.name / neighborhood / location       (pickup card + map)
  ///   - deliveryDetails.address (+ coordinate)      (dropoff card + map)
  ///   - deliveryFee                                  (driver payout)
  ///   - items[*].quantity                            (item count badge)
  /// Other OrderDetail fields (cart line specifics, payment method, etc.)
  /// stay on the mock as visual filler — the slim list response doesn't
  /// carry them.
  static OrderDetail hydrateFromSummary(DeliverySummary s) {
    final mock = OrderMockData.demoOrder();
    // Pickup is guaranteed real by the poll filter (un-routable offers are
    // skipped); fall back to a neutral point, never to fake Paris coords.
    final pickup = (s.pickupLat != null && s.pickupLng != null)
        ? MapPoint(lng: s.pickupLng!, lat: s.pickupLat!)
        : const MapPoint(lng: 0, lat: 0);
    final dropoffCoord = (s.dropoffLat != null && s.dropoffLng != null)
        ? MapPoint(lng: s.dropoffLng!, lat: s.dropoffLat!)
        : null;

    final hydratedSeller = mock.seller.copyWith(
      // Real seller identity; neutral generic fallback (never mock data).
      name: s.sellerName ?? 'Cuisinier',
      neighborhood: s.sellerNeighborhood ?? '',
      location: pickup,
    );

    final hydratedDelivery = mock.deliveryDetails == null
        ? null
        : mock.deliveryDetails!.copyWith(
            recipientName: s.recipientName,
            address: mock.deliveryDetails!.address.copyWith(
              fullAddress:
                  s.dropoffFullAddress ??
                  mock.deliveryDetails!.address.fullAddress,
              city: s.dropoffCity.isNotEmpty
                  ? s.dropoffCity
                  : mock.deliveryDetails!.address.city,
              postalCode: s.dropoffPostalCode.isNotEmpty
                  ? s.dropoffPostalCode
                  : mock.deliveryDetails!.address.postalCode,
              coordinate: dropoffCoord,
            ),
          );

    // Replace the mock items list with a single synthetic line whose
    // quantity equals the real backend item count. OrderDetail.itemCount
    // is derived as `items.fold(quantities)`, so this makes the badge
    // ("X articles") match what the buyer actually ordered without
    // having to load every line item.
    final firstMockItem = mock.items.first;
    final realCount = (s.itemCount ?? mock.itemCount).clamp(1, 99);
    final hydratedItems = [firstMockItem.copyWith(quantity: realCount)];

    return mock.copyWith(
      id: s.orderId,
      orderNumber: s.orderNumber.isNotEmpty ? s.orderNumber : mock.orderNumber,
      placedAt: s.placedAt ?? mock.placedAt,
      total: s.totalEuros ?? mock.total,
      // Backend's driverPayoutCents (== order.fulfillmentFeeCents) is
      // the driver's full earning for the delivery. Surface that as
      // deliveryFee so the modal's payout block reads from real data.
      deliveryFee: s.feeEuros,
      seller: hydratedSeller,
      deliveryDetails: hydratedDelivery,
      items: hydratedItems,
    );
  }
}
