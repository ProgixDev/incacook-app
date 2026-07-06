import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/services/realtime/driver_location.dart';
import 'package:incacook/core/services/realtime/order_status_event.dart';
import 'package:incacook/core/services/realtime/tracking_socket_client.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/core/utils/log.dart';

/// Where the driver is in the journey, from the buyer's POV. Drives
/// which destination + route polyline the buyer's map renders:
///   * [awaitingPickup] — driver is heading to the seller (1st leg).
///   * [enRoute] — driver has picked up the food and is heading to the buyer.
/// Derived from the backend `OrderStatus` (`IN_DELIVERY` flips us to enRoute).
enum TrackingPhase { awaitingPickup, enRoute }

/// Sentinel until the real snapshot resolves. Never displayed: the map only
/// renders at the `onTheWay` stage, which the snapshot sets *after* writing
/// the real pickup/dropoff coordinates.
const MapPoint _kUnsetPoint = MapPoint(lng: 0, lat: 0);

/// Buyer-side live tracking. 100% real data: pickup/dropoff/driver position +
/// status come from `GET /v1/orders/:id/tracking` and the `/tracking` socket.
/// No mock order, no fake ETA, no simulated driver — before a driver is
/// assigned the buyer sees the real order status and no driver marker.
class OrderTrackingController extends GetxController {
  OrderTrackingController({this.orderId});

  static OrderTrackingController get instance => Get.find();

  /// Server-issued order id. Tracking is only opened for a real order.
  final String? orderId;

  /// Real assigned driver identity from the tracking snapshot. Null until a
  /// driver claims the delivery — the buyer must never see a driver before.
  final Rxn<TrackingDriver> assignedDriver = Rxn<TrackingDriver>();

  /// True once a real driver is assigned — the only gate the UI uses to
  /// reveal the driver name/photo/phone + the driver map marker.
  bool get hasAssignedDriver => assignedDriver.value != null;

  /// PICKUP vs DELIVERY (from the snapshot). Drives the pickup-handoff UI.
  final RxBool isPickup = false.obs;

  /// True once the real tracking snapshot has loaded (real coords + status).
  final RxBool snapshotReady = false.obs;

  /// True when the order is NO_DRIVER_AVAILABLE — no driver accepted the
  /// delivery within the timeout, so the buyer must decide (switch to pickup or
  /// cancel + refund). Drives the no-driver decision card on the tracking screen.
  final RxBool noDriverDecisionPending = false.obs;

  /// Cancellation reason once the order is cancelled (e.g. `seller_unavailable`),
  /// null otherwise. Drives the buyer's cancelled-state message.
  final Rxn<String> cancellationReason = Rxn<String>();

  /// Real seller pickup + client dropoff coordinates (from the snapshot).
  MapPoint _pickupPoint = _kUnsetPoint;
  MapPoint _dropoffPoint = _kUnsetPoint;

  String? get _subscribeId => orderId;

  /// Current displayed stage on the buyer's stepper. Updated from the
  /// snapshot + live `order:status` events.
  final Rx<OrderStage> stage = OrderStage.prepared.obs;

  /// Estimated arrival in minutes. Null = unknown (no fabricated value); the
  /// UI shows a generic "en route" label instead of a fake number.
  final Rxn<int> etaMinutes = Rxn<int>();

  late final Rx<MapPoint> driverPosition = Rx<MapPoint>(_pickupPoint);

  /// Which leg of the trip the buyer is watching. Flips to `enRoute` once the
  /// backend broadcasts `IN_DELIVERY` (driver picked up the food).
  final Rx<TrackingPhase> phase = TrackingPhase.awaitingPickup.obs;

  /// Where the driver is currently heading — destination marker + polyline
  /// endpoint, switching with [phase] (seller leg → buyer leg).
  MapPoint get destination => switch (phase.value) {
    TrackingPhase.awaitingPickup => _pickupPoint,
    TrackingPhase.enRoute => _dropoffPoint,
  };

  MapPoint get pickupPoint => _pickupPoint;
  MapPoint get dropoffPoint => _dropoffPoint;

  // Live sources: `driver:location` + `order:status` over the tracking socket.
  StreamSubscription<DriverLocation>? _socketLocSub;
  StreamSubscription<OrderStatusEvent>? _socketStatusSub;

  // Last observed backend status — guards the completion popup against a
  // re-broadcast DELIVERED.
  String? _lastStatus;
  bool _completionShown = false;

  @override
  void onInit() {
    super.onInit();
    _startLiveTracking();
    unawaited(_loadTrackingSnapshot());
  }

  void setStage(OrderStage next) => stage.value = next;

  /// Re-pulls the snapshot — used after the buyer resolves a no-driver prompt
  /// so the screen reflects the new status (pickup / cancelled).
  Future<void> refreshSnapshot() => _loadTrackingSnapshot();

  /// Pulls the real pickup/dropoff/driver coordinates + status + driver
  /// identity. This is the initial frame; live movement then arrives over
  /// the socket. On failure the screen shows a safe "unavailable" state.
  Future<void> _loadTrackingSnapshot() async {
    final id = orderId;
    if (id == null) return;
    try {
      final snap = await OrdersRepository.instance.getTracking(id);
      if (snap.pickup != null) _pickupPoint = snap.pickup!;
      if (snap.dropoff != null) _dropoffPoint = snap.dropoff!;
      isPickup.value = snap.isPickup;

      _lastStatus = snap.orderStatus;
      noDriverDecisionPending.value = snap.orderStatus == 'NO_DRIVER_AVAILABLE';
      cancellationReason.value = snap.cancellationReason;
      final mappedStage = _statusToStage(snap.orderStatus);
      if (mappedStage != null) stage.value = mappedStage;
      phase.value = _phaseForStatus(snap.orderStatus);
      assignedDriver.value = snap.driverInfo;

      // Seed the driver marker from the last-known point (only used once a
      // driver is assigned — see [hasAssignedDriver] gating in the map view).
      if (snap.driver != null) driverPosition.value = snap.driver!;

      snapshotReady.value = true;
      logInfo(
        '[tracking] order $id snapshot: status=${snap.orderStatus} '
        'fulfillment=${snap.fulfillmentChoice} '
        'driver=${snap.driverInfo?.fullName ?? "unassigned"}',
      );
      _logTrackingState('snapshot');
    } catch (_) {
      // Leave snapshotReady=false → the screen renders its unavailable state.
    }
  }

  /// Re-fetches the snapshot to pick up the assigned driver once one claims
  /// the delivery. No-op once a driver is already known.
  Future<void> _refreshAssignedDriver() async {
    final id = orderId;
    if (id == null || assignedDriver.value != null) return;
    try {
      final snap = await OrdersRepository.instance.getTracking(id);
      if (snap.driverInfo != null) {
        assignedDriver.value = snap.driverInfo;
        if (snap.driver != null) driverPosition.value = snap.driver!;
        logInfo('[tracking] order $id driver assigned: ${snap.driverInfo!.fullName}');
        _logTrackingState('driver-assigned');
      }
    } catch (_) {
      // best-effort
    }
  }

  /// One-line dump of the three tracking points for verifying the map shows
  /// all of them. Logs exactly which coordinate is missing — never fabricates
  /// one (a missing point means the backend hasn't geocoded it / no driver).
  void _logTrackingState(String source) {
    String fmt(MapPoint p) =>
        '(${p.lat.toStringAsFixed(5)},${p.lng.toStringAsFixed(5)})';
    final hasPickup = _pickupPoint != _kUnsetPoint;
    final hasDropoff = _dropoffPoint != _kUnsetPoint;
    final dp = driverPosition.value;
    final hasDriver = hasAssignedDriver && (dp.lng != 0 || dp.lat != 0);
    final markers =
        (hasPickup ? 1 : 0) + (hasDropoff ? 1 : 0) + (hasDriver ? 1 : 0);
    logWarning(
      '[TrackingMap]($source) '
      'pickup=${hasPickup ? fmt(_pickupPoint) : "MISSING"}, '
      'dropoff=${hasDropoff ? fmt(_dropoffPoint) : "MISSING"}, '
      'driver=${hasDriver ? fmt(dp) : "MISSING"}, '
      'markers=$markers',
    );
    if (!hasPickup) {
      logWarning('[TrackingMap] pickup MISSING — seller location not geocoded.');
    }
    if (!hasDropoff) {
      logWarning('[TrackingMap] dropoff MISSING — client address not geocoded.');
    }
    if (!hasDriver) {
      logWarning('[TrackingMap] driver MISSING — no driver assigned/located yet.');
    }
  }

  TrackingPhase _phaseForStatus(String status) => switch (status) {
        'PICKED_UP' || 'IN_DELIVERY' || 'DELIVERED' || 'COMPLETED' =>
          TrackingPhase.enRoute,
        _ => TrackingPhase.awaitingPickup,
      };

  void _startLiveTracking() {
    final id = _subscribeId;
    if (id == null) return;
    final TrackingSocketClient? socket = Get.isRegistered<TrackingSocketClient>()
        ? Get.find<TrackingSocketClient>()
        : null;
    if (socket == null) return;

    try {
      logInfo('[tracking] buyer subscribing to order $id');
      // Driver position — only meaningful once a driver is assigned.
      _socketLocSub = socket.subscribeToOrder(id).listen(
        (ev) {
          driverPosition.value = MapPoint(lng: ev.lng, lat: ev.lat);
          // A live driver fix means a driver is assigned — pull their
          // identity if we don't have it yet.
          if (assignedDriver.value == null) {
            unawaited(_refreshAssignedDriver());
          }
        },
        onError: (Object _) {},
        cancelOnError: false,
      );

      // Status transitions — drive the stepper + completion popup.
      _socketStatusSub = socket.subscribeToOrderStatus(id).listen(
        _onStatusEvent,
        onError: (Object _) {},
        cancelOnError: false,
      );
    } catch (_) {
      // No live channel — the snapshot is still the real initial frame.
    }
  }

  void _onStatusEvent(OrderStatusEvent ev) {
    if (ev.status == _lastStatus) return;
    _lastStatus = ev.status;
    noDriverDecisionPending.value = ev.status == 'NO_DRIVER_AVAILABLE';

    final newPhase = _phaseForStatus(ev.status);
    if (phase.value != newPhase) phase.value = newPhase;

    // On a live cancellation, pull the reason for the cancelled-state message.
    if (ev.status == 'CANCELLED' || ev.status == 'REFUNDED') {
      unawaited(refreshSnapshot());
    }

    final next = _statusToStage(ev.status);
    if (next == null) return;
    final wasNotDelivered = stage.value != OrderStage.delivered;
    stage.value = next;
    // Once the order is on its way, a driver is assigned — pull the real
    // identity so the buyer sees the actual driver.
    if (assignedDriver.value == null &&
        (next == OrderStage.onTheWay || next == OrderStage.delivered)) {
      unawaited(_refreshAssignedDriver());
    }
    if (wasNotDelivered && next == OrderStage.delivered) {
      _maybeShowCompletionPopup();
    }
  }

  /// Maps backend [OrderStatus] strings to the local 5-stage stepper.
  OrderStage? _statusToStage(String s) {
    switch (s) {
      case 'PENDING':
      case 'CONFIRMED':
      case 'PREPARING':
        return OrderStage.prepared;
      case 'READY':
      case 'PICKED_UP':
      case 'IN_DELIVERY':
        return OrderStage.onTheWay;
      case 'DELIVERED':
      case 'COMPLETED':
        return OrderStage.delivered;
      case 'CANCELLED':
      case 'REFUNDED':
        return OrderStage.failed;
    }
    return null;
  }

  void _maybeShowCompletionPopup() {
    if (_completionShown) return;
    _completionShown = true;
    final ctx = Get.context;
    if (ctx == null) return;
    final pickup = isPickup.value;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: Text(pickup ? 'Commande récupérée !' : 'Commande livrée !'),
        content: Text(
          pickup
              ? 'Merci d\'être passé. Bon appétit !'
              : 'Votre commande vient d\'arriver. Bon appétit !',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _socketLocSub?.cancel();
    _socketStatusSub?.cancel();
    final id = _subscribeId;
    if (id != null && Get.isRegistered<TrackingSocketClient>()) {
      unawaited(Get.find<TrackingSocketClient>().unsubscribeFromOrder(id));
    }
    super.onClose();
  }
}
