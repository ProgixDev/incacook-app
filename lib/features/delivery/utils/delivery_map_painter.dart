import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/services/map/models/map_route.dart';

/// Owns the polyline/circle annotation managers for the delivery map and
/// renders routes, markers, and camera framing. Stateless beyond the managers
/// it holds and a "have we rendered yet?" flag — route/point data flows in
/// from the caller.
class DeliveryMapPainter {
  DeliveryMapPainter({
    required this.map,
    required this.polylineManager,
    required this.circleManager,
    required this.pointManager,
  });

  final MapboxMap map;
  final PolylineAnnotationManager polylineManager;
  final CircleAnnotationManager circleManager;
  // Text labels ("Vendeur" / "Client") that name each stop's role.
  final PointAnnotationManager pointManager;

  //* Camera is auto-framed once per job (on the first route render);
  //* later re-routes replace the polyline without yanking the camera.
  bool _framed = false;

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

  /// Draws (or redraws) the two trip stops — seller pickup + customer
  /// dropoff. Called on job accept so the driver immediately sees both
  /// emplacements, even before (or without) a fetched route. Clears any
  /// previous markers first so back-to-back jobs don't stack.
  Future<void> showStops({
    required MapPoint pickup,
    required MapPoint dropoff,
  }) async {
    await circleManager.deleteAll();
    await pointManager.deleteAll();
    await _drawMarkers(pickup: pickup, dropoff: dropoff);
    //? Frame both stops and own the framing for this job — the driver's
    //? live route can originate far away (real GPS), so we keep the camera
    //? on the two Paris stops rather than letting the route reframe to a
    //? continent-spanning bounding box.
    await _framePoints([pickup, dropoff]);
    _framed = true;
  }

  /// Draws the route polyline to the current destination, replacing any
  /// previous one (so a re-route — e.g. pickup→dropoff leg switch — wipes
  /// the stale line). Frames the camera once per job on the first route.
  Future<void> showRoute(MapRoute route) async {
    await polylineManager.deleteAll();
    await _drawRoute(route);
    if (!_framed) {
      await _framePoints(route.points);
      _framed = true;
    }
  }

  /// Wipes every overlay (markers + polyline) and resets the framing
  /// flag. Call when a job ends so the finished trip doesn't linger on
  /// the map into the idle dashboard or the next accepted job.
  Future<void> reset() async {
    await polylineManager.deleteAll();
    await circleManager.deleteAll();
    await pointManager.deleteAll();
    _framed = false;
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

    //* Role labels above each dot so the driver knows which is which.
    await _drawLabel(pickup, 'Vendeur', 0xFFE8823B);
    await _drawLabel(dropoff, 'Client', 0xFFFF3B30);
  }

  Future<void> _drawLabel(MapPoint at, String text, int color) async {
    await pointManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(at.lng, at.lat)),
        textField: text,
        textColor: color,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 1.6,
        textSize: 13.0,
        // Lift the label above the 10px circle (offset is in ems).
        textOffset: [0.0, -1.6],
      ),
    );
  }

  /// Centres the camera on the bounding-box midpoint of [points] (a route
  /// path or just the two stops).
  Future<void> _framePoints(List<MapPoint> points) async {
    if (points.isEmpty) return;
    var minLng = points.first.lng, maxLng = minLng;
    var minLat = points.first.lat, maxLat = minLat;
    for (final p in points) {
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
