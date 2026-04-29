import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';

import 'package:homemade/core/services/location/location_service.dart';
import 'package:homemade/core/services/map/mapbox_directions_client.dart';
import 'package:homemade/core/services/map/models/map_route.dart';
import 'package:homemade/core/utils/geo/distance.dart';
import 'package:homemade/features/orders/data/order_mock_data.dart';
import 'package:homemade/features/orders/domain/order_detail.dart';

/// Owns the active delivery's route state and the position-driven re-fetch
/// logic. Created when the delivery screen mounts; auto-disposed when the
/// route is popped (default GetX smart management).
class DeliveryRouteController extends GetxController {
  static DeliveryRouteController get instance => Get.find();

  //* Mock active order — pickup + dropoff drive the markers and route.
  final OrderDetail order = OrderMockData.demoOrder();

  MapPoint get pickup => order.seller.location;
  MapPoint get dropoff => order.deliveryDetails!.address.coordinate!;

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

  /// Reads the driver's current position, fetches the initial route to
  /// [dropoff], and starts streaming the live position so [_onPositionUpdate]
  /// can detect off-route deviation.
  Future<void> bootstrap() async {
    final pos = await LocationService.instance.getCurrent();
    if (pos == null) return;

    final origin = MapPoint(lng: pos.longitude, lat: pos.latitude);
    try {
      route.value = await Get.find<MapboxDirectionsClient>().getRoute(
        origin: origin,
        destination: dropoff,
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
    _refetching = true;
    try {
      route.value = await Get.find<MapboxDirectionsClient>().getRoute(
        origin: origin,
        destination: dropoff,
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
