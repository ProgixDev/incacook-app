import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/services/map/models/map_route.dart';

/// Owns the polyline/circle annotation managers for the delivery map and
/// renders routes, markers, and camera framing. Stateless beyond the managers
/// it holds and a "have we rendered yet?" flag — route/point data flows in
/// from the caller.
class DeliveryMapPainter {
  DeliveryMapPainter({
    required this.map,
    required this.polylineManager,
    required this.circleManager,
  });

  final MapboxMap map;
  final PolylineAnnotationManager polylineManager;
  final CircleAnnotationManager circleManager;

  bool _hasRendered = false;

  /// One-shot map UI configuration — runs at map creation, before any
  /// annotation managers exist. Static because it's prerequisite to building
  /// a painter, not a method on one.
  static Future<void> configure(MapboxMap map) async {
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    await map.logo.updateSettings(
      LogoSettings(
        enabled: true,
        position: OrnamentPosition.TOP_RIGHT,
        marginRight: AppSizes.md,
      ),
    );
    await map.attribution.updateSettings(
      AttributionSettings(
        enabled: false,
        position: OrnamentPosition.BOTTOM_RIGHT,
        iconColor: 0xFF000000,
        marginBottom: AppSizes.md,
        clickable: false,
      ),
    );
    await map.compass.updateSettings(
      CompassSettings(
        enabled: false,
        position: OrnamentPosition.TOP_LEFT,
        marginTop: 80,
        marginLeft: 16,
      ),
    );
  }

  /// First call → markers + polyline + camera frame. Subsequent calls (from
  /// re-routing) → replace the polyline only.
  Future<void> renderRoute(
    MapRoute route, {
    required MapPoint pickup,
    required MapPoint dropoff,
  }) async {
    if (!_hasRendered) {
      await _drawMarkers(pickup: pickup, dropoff: dropoff);
      await _drawRoute(route);
      await _frameRoute(route);
      _hasRendered = true;
    } else {
      await polylineManager.deleteAll();
      await _drawRoute(route);
    }
  }

  Future<void> flyToDriver(MapPoint pos) async {
    await map.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(pos.lng, pos.lat)),
        zoom: 14.0,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _drawRoute(MapRoute route) async {
    final coords = route.points.map((p) => Position(p.lng, p.lat)).toList();
    await polylineManager.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coords),
        lineWidth: 6.0,
        lineColor: 0xFF0066FF,
      ),
    );
  }

  Future<void> _drawMarkers({
    required MapPoint pickup,
    required MapPoint dropoff,
  }) async {
    //* Pickup — seller's location (orange).
    await circleManager.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(pickup.lng, pickup.lat)),
        circleRadius: 10.0,
        circleColor: 0xFFE8823B,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
    //* Dropoff — customer's address (red).
    await circleManager.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(dropoff.lng, dropoff.lat)),
        circleRadius: 10.0,
        circleColor: 0xFFFF3B30,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
  }

  /// Centres the camera on [route]'s bounding-box midpoint.
  Future<void> _frameRoute(MapRoute route) async {
    if (route.points.isEmpty) return;
    var minLng = route.points.first.lng, maxLng = minLng;
    var minLat = route.points.first.lat, maxLat = minLat;
    for (final p in route.points) {
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
    }
    await map.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position((minLng + maxLng) / 2, (minLat + maxLat) / 2),
        ),
        zoom: 12.5,
      ),
      MapAnimationOptions(duration: 800),
    );
  }
}
