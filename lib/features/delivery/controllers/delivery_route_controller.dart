import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';

import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/geo/distance.dart';
import 'package:incacook/features/orders/domain/order_detail.dart';
import 'package:incacook/features/orders/domain/order_stage.dart';

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

  int _offRouteHits = 0;
  bool _refetching = false;
  Worker? _positionWorker;

  /// Sets the active job and triggers route bootstrap. Replaces any in-flight
  /// job; callers should confirm before switching.
  Future<void> acceptJob(OrderDetail job) async {
    currentJob.value = job;
    currentStage.value = OrderStage.prepared;
    await bootstrap();
  }

  /// Advances the lifecycle to [next]. When the destination flips
  /// (arrivedPickup → onTheWay), re-fetches the route to [currentDestination].
  Future<void> advanceStage(OrderStage next) async {
    final prev = currentStage.value;
    currentStage.value = next;
    final destinationFlipped =
        prev == OrderStage.arrivedPickup && next == OrderStage.onTheWay;
    if (destinationFlipped) {
      final origin = currentDriverPosition;
      if (origin != null) await _refetchRoute(origin);
    }
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
  }

  /// Reads the driver's current position, fetches the initial route to
  /// [currentDestination], and starts streaming the live position so
  /// [_onPositionUpdate] can detect off-route deviation. No-op when no job is
  /// accepted.
  Future<void> bootstrap() async {
    final destination = currentDestination;
    if (destination == null) return;

    final pos = await LocationService.instance.getCurrent();
    if (pos == null) return;

    final origin = MapPoint(lng: pos.longitude, lat: pos.latitude);
    try {
      route.value = await Get.find<MapboxDirectionsClient>().getRoute(
        origin: origin,
        destination: destination,
      );
      await LocationService.instance.start();
      _startPositionWatcher();
    } catch (_) {
      //? swallow — no overlay; map still usable without a route.
    }
  }

  void _startPositionWatcher() {
    _positionWorker?.dispose();
    _positionWorker = ever<geo.Position?>(
      LocationService.instance.currentPosition,
      _onPositionUpdate,
    );
  }

  Future<void> _onPositionUpdate(geo.Position? pos) async {
    final current = route.value;
    if (pos == null || current == null || _refetching) return;

    final point = MapPoint(lng: pos.longitude, lat: pos.latitude);
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

  Future<void> _refetchRoute(MapPoint origin) async {
    final destination = currentDestination;
    if (destination == null) return;
    _refetching = true;
    try {
      route.value = await Get.find<MapboxDirectionsClient>().getRoute(
        origin: origin,
        destination: destination,
      );
    } catch (_) {
      //? swallow — try again on the next off-route trip
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
