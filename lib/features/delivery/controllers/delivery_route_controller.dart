import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';

import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/geo/distance.dart';
import 'package:incacook/features/authentication/data/repositories/drivers_repository.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';

/// Owns the active delivery's route state and the position-driven re-fetch
/// logic. Created when the delivery screen mounts; auto-disposed when the
/// route is popped (default GetX smart management).
class DeliveryRouteController extends GetxController {
  static DeliveryRouteController get instance => Get.find();

  /// The job currently being executed. Null when the driver is idle (online
  /// but no accepted order). Set via [acceptJob]; cleared via [clearJob].
  final Rxn<OrderDetail> currentJob = Rxn<OrderDetail>();

  /// Where the driver is in the job lifecycle. Null while idle. Mutates via
  /// [advanceStage]; reset on [clearJob].
  final Rxn<OrderStage> currentStage = Rxn<OrderStage>();

  OrderDetail? get order => currentJob.value;

  MapPoint? get pickup => order?.seller.location;
  MapPoint? get dropoff => order?.deliveryDetails?.address.coordinate;

  /// The point the driver is currently navigating to, based on [currentStage].
  /// Pre-pickup stages target [pickup]; post-pickup stages target [dropoff].
  /// Null when idle or terminal.
  MapPoint? get currentDestination {
    if (order == null) return null;
    switch (currentStage.value) {
      case null:
      case OrderStage.delivered:
      case OrderStage.failed:
        return null;
      case OrderStage.prepared:
      case OrderStage.arrivedPickup:
        return pickup;
      case OrderStage.onTheWay:
      case OrderStage.arrivedDropoff:
        return dropoff;
    }
  }

  /// Latest driver position from [LocationService], converted to a [MapPoint].
  /// Null until the location stream emits its first reading.
  MapPoint? get currentDriverPosition {
    final pos = LocationService.instance.currentPosition.value;
    return pos == null
        ? null
        : MapPoint(lng: pos.longitude, lat: pos.latitude);
  }

  //* Latest route from Mapbox Directions. Null until [bootstrap] succeeds.
  final Rxn<MapRoute> route = Rxn<MapRoute>();

  //* Off-route detection thresholds.
  static const double _offRouteThresholdMeters = 50;
  static const int _offRouteHitsBeforeReroute = 3;

  //* Location-push throttle. Push at most once per [_minPushIntervalMs],
  //* and only when the driver has moved at least [_minPushDistanceM] OR
  //* it's been [_keepaliveMs] since the last push (so a stopped driver
  //* still emits a heartbeat).
  static const int _minPushIntervalMs = 3000;
  static const double _minPushDistanceM = 10;
  static const int _keepaliveMs = 15000;

  int _offRouteHits = 0;
  bool _refetching = false;
  Worker? _positionWorker;

  DateTime? _lastPushAt;
  MapPoint? _lastPushedPoint;
  bool _pushingLocation = false;

  /// Backend delivery id from the available-deliveries claim. Null
  /// when the job is mock/demo — in that case backend transitions are
  /// skipped silently.
  String? _deliveryId;

  /// Sets the active job and triggers route bootstrap. [deliveryId] is
  /// the backend Delivery row id (returned by listAvailable / claim);
  /// pass null for demo flows. Replaces any in-flight job.
  Future<void> acceptJob(OrderDetail job, {String? deliveryId}) async {
    _deliveryId = deliveryId;
    currentJob.value = job;
    currentStage.value = OrderStage.prepared;
    await bootstrap();
  }

  /// Advances the lifecycle to [next]. Also fires the matching backend
  /// transition when we have a real [_deliveryId]:
  ///   prepared        -> arrivedPickup    : POST arrive-pickup
  ///   arrivedPickup   -> onTheWay         : POST confirm-pickup
  ///   arrivedDropoff  -> delivered        : POST confirm-delivery
  /// Backend errors don't block the local UI advance (kept best-effort
  /// so the demo doesn't lock up on a transient network blip).
  Future<void> advanceStage(OrderStage next) async {
    final prev = currentStage.value;
    currentStage.value = next;
    await _syncBackendTransition(prev, next);

    final destinationFlipped =
        prev == OrderStage.arrivedPickup && next == OrderStage.onTheWay;
    if (destinationFlipped) {
      final origin = currentDriverPosition;
      if (origin != null) await _refetchRoute(origin);
    }
  }

  Future<void> _syncBackendTransition(OrderStage? prev, OrderStage next) async {
    final id = _deliveryId;
    if (id == null) return;
    final repo = DeliveriesRepository.instance;
    try {
      if (prev == OrderStage.prepared && next == OrderStage.arrivedPickup) {
        await repo.arrivePickup(id);
      }
      // Pickup (arrivedPickup → onTheWay) and delivery (arrivedDropoff →
      // delivered) are NOT here: both are token-validated QR scans handled by
      // [confirmPickupScanned] / [confirmDeliveryScanned], which advance the
      // stage themselves on success.
    } catch (_) {
      //? swallow — local UI keeps moving, server can resync on retry
    }
  }

  /// Driver scanned the seller's pickup QR. Confirms pickup on the backend
  /// (token-validated, with current GPS when available); on success advances
  /// to "en livraison" and reroutes to the dropoff. Unlike [advanceStage]
  /// this is NOT best-effort — it rethrows [ApiFailure] (invalid/duplicate
  /// QR, wrong driver) so the caller can show the message and the stage does
  /// not advance on failure.
  Future<void> confirmPickupScanned(String pickupToken) async {
    final id = _deliveryId;
    if (id == null) return;
    final p = currentDriverPosition;
    await DeliveriesRepository.instance.confirmPickup(
      id,
      pickupToken: pickupToken,
      lat: p?.lat,
      lng: p?.lng,
    );
    currentStage.value = OrderStage.onTheWay;
    if (p != null) await _refetchRoute(p);
  }

  /// Driver scanned the buyer's reception QR. Confirms delivery on the backend
  /// (token-validated, with current GPS when available). On success the order
  /// is DELIVERED, so we clear the active job — which stops live tracking and
  /// returns the driver to available deliveries. NOT best-effort: rethrows
  /// [ApiFailure] (invalid/duplicate QR, wrong driver) so the caller can show
  /// the message and the job is not cleared on failure.
  Future<void> confirmDeliveryScanned(String deliveryToken) async {
    final id = _deliveryId;
    if (id == null) return;
    final p = currentDriverPosition;
    await DeliveriesRepository.instance.confirmDelivery(
      id,
      deliveryToken: deliveryToken,
      lat: p?.lat,
      lng: p?.lng,
    );
    clearJob();
  }

  /// Client-absent fallback: the driver leaves the order at the door with a
  /// mandatory photo ([photoUrl] from the upload flow) + GPS. On success the
  /// order is DELIVERED, so we clear the active job (stops tracking, returns to
  /// available deliveries). NOT best-effort: rethrows [ApiFailure] so the
  /// caller can show the message and the job is not cleared on failure.
  Future<void> confirmAbsentDropoff({
    required String photoUrl,
    required double lat,
    required double lng,
    String? note,
  }) async {
    final id = _deliveryId;
    if (id == null) return;
    await DeliveriesRepository.instance.confirmAbsentDropoff(
      id,
      photoUrl: photoUrl,
      lat: lat,
      lng: lng,
      note: note,
    );
    clearJob();
  }

  /// Driver reports the seller couldn't provide the order at pickup (absent / no
  /// food). On success the order is cancelled + refunded and the driver is
  /// compensated, so we clear the active job (back to available deliveries).
  /// NOT best-effort: rethrows [ApiFailure] so the caller can show the message
  /// and the job is not cleared on failure.
  Future<void> reportSellerUnavailable({
    required String reason,
    required double lat,
    required double lng,
    String? note,
    String? photoUrl,
  }) async {
    final id = _deliveryId;
    if (id == null) return;
    await DeliveriesRepository.instance.reportSellerUnavailable(
      id,
      reason: reason,
      lat: lat,
      lng: lng,
      note: note,
      photoUrl: photoUrl,
    );
    clearJob();
  }

  /// Clears the active job, the rendered route, and stops the position watcher.
  void clearJob() {
    _positionWorker?.dispose();
    _positionWorker = null;
    LocationService.instance.stop();
    route.value = null;
    currentJob.value = null;
    currentStage.value = null;
    _offRouteHits = 0;
    _lastPushAt = null;
    _lastPushedPoint = null;
    _deliveryId = null;
  }

  /// Reads the driver's current position, fetches the initial route to
  /// [currentDestination], and starts streaming the live position so
  /// [_onPositionUpdate] can detect off-route deviation. No-op when no job is
  /// accepted.
  Future<void> bootstrap() async {
    final destination = currentDestination;
    if (destination == null) return;

    final pos = await LocationService.instance.getCurrent();
    final origin =
        pos == null ? null : MapPoint(lng: pos.longitude, lat: pos.latitude);

    route.value = await _computeRoute(origin, destination);
    await LocationService.instance.start();
    _startPositionWatcher();
  }

  /// Best-effort route for the current leg: driver → [destination]. When the
  /// driver's position is unknown or unroutable to the destination (e.g. an
  /// emulator's default GPS sitting far from the order), it falls back to
  /// the seller→client trip so the map still shows a sensible route between
  /// the two stops, and finally to a straight line. Null only if the stops
  /// themselves are unknown.
  Future<MapRoute?> _computeRoute(
    MapPoint? origin,
    MapPoint destination,
  ) async {
    final client = Get.find<MapboxDirectionsClient>();
    if (origin != null) {
      try {
        return await client.getRoute(origin: origin, destination: destination);
      } catch (_) {
        //? fall through to the stop-to-stop fallback below
      }
    }
    final p = pickup, d = dropoff;
    if (p != null && d != null) {
      try {
        return await client.getRoute(origin: p, destination: d);
      } catch (_) {
        return MapRoute(points: [p, d], distanceMeters: 0, durationSeconds: 0);
      }
    }
    return null;
  }

  void _startPositionWatcher() {
    _positionWorker?.dispose();
    _positionWorker = ever<geo.Position?>(
      LocationService.instance.currentPosition,
      _onPositionUpdate,
    );
  }

  Future<void> _onPositionUpdate(geo.Position? pos) async {
    if (pos == null) return;
    final point = MapPoint(lng: pos.longitude, lat: pos.latitude);

    // Push first — the buyer's tracking screen wants the freshest fix
    // even if we're off-route and about to recompute.
    unawaited(_maybePushLocation(point, pos));

    final current = route.value;
    if (current == null || _refetching) return;

    final distance = distanceToPolyline(point, current.points);
    if (distance > _offRouteThresholdMeters) {
      _offRouteHits++;
      if (_offRouteHits >= _offRouteHitsBeforeReroute) {
        _offRouteHits = 0;
        await _refetchRoute(point);
      }
    } else {
      _offRouteHits = 0;
    }
  }

  /// Pushes the driver's fix to `POST /v1/drivers/me/location` so the
  /// backend can fan it out to the buyer's tracking socket. Throttled
  /// to at most one request per [_minPushIntervalMs], and skipped
  /// entirely when the driver hasn't moved [_minPushDistanceM] unless
  /// it's been [_keepaliveMs] since the last push.
  Future<void> _maybePushLocation(MapPoint point, geo.Position pos) async {
    if (_pushingLocation) return;
    if (currentJob.value == null) return;
    final now = DateTime.now();
    final lastAt = _lastPushAt;
    if (lastAt != null) {
      final sinceMs = now.difference(lastAt).inMilliseconds;
      if (sinceMs < _minPushIntervalMs) return;
      final lastP = _lastPushedPoint;
      final movedEnough =
          lastP == null || greatCircleDistance(lastP, point) >= _minPushDistanceM;
      final keepalive = sinceMs >= _keepaliveMs;
      if (!movedEnough && !keepalive) return;
    }
    _pushingLocation = true;
    try {
      await Get.find<DriversRepository>().pushLocation(
        lat: point.lat,
        lng: point.lng,
        headingDeg: pos.heading >= 0 ? pos.heading : null,
        speedMps: pos.speed >= 0 ? pos.speed : null,
        accuracyM: pos.accuracy,
      );
      _lastPushAt = now;
      _lastPushedPoint = point;
    } catch (_) {
      //? swallow — transient miss is harmless, next tick retries
    } finally {
      _pushingLocation = false;
    }
  }

  Future<void> _refetchRoute(MapPoint origin) async {
    final destination = currentDestination;
    if (destination == null) return;
    _refetching = true;
    try {
      route.value = await _computeRoute(origin, destination);
    } finally {
      _refetching = false;
    }
  }

  @override
  void onClose() {
    _positionWorker?.dispose();
    LocationService.instance.stop();
    super.onClose();
  }
}
