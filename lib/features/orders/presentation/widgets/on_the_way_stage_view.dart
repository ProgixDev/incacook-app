import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/orders/controllers/order_tracking_controller.dart';

/// Buyer-side live tracking map. Renders the three trip points as **native
/// Mapbox annotations** (geo-anchored, reliable — no screen-projection overlay
/// and no image assets that can silently fail to load on a device/emulator):
///   * Seller / pickup  — orange dot, label "Retrait"
///   * Client / dropoff — green dot, label "Livraison"
///   * Driver / live    — blue dot, label "Livreur" (only once a driver is
///     assigned and has a real fix)
/// Plus the routed polyline for the active leg: driver → seller → client before
/// pickup, driver → client after. The driver dot slides live from socket fixes;
/// the camera frames every real point and is NOT re-fitted on each driver tick.
/// No coordinate is ever faked — an unset (0,0) point is simply not drawn.
class OnTheWayStageView extends StatefulWidget {
  const OnTheWayStageView({super.key});

  @override
  State<OnTheWayStageView> createState() => _OnTheWayStageViewState();
}

class _OnTheWayStageViewState extends State<OnTheWayStageView> {
  // Marker colours.
  static const int _sellerColor = 0xFFE8823B; // orange
  static const int _clientColor = 0xFF34C759; // green
  static const int _driverColor = 0xFF1E66FF; // blue
  static const int _routeColor = 0xFF0066FF; // bold blue line

  final OrderTrackingController _controller = OrderTrackingController.instance;

  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _pointManager;

  PolylineAnnotation? _polyline;

  // Live-updated driver handles (seller/client are static for the trip).
  CircleAnnotation? _driverCircle;
  PointAnnotation? _driverLabel;
  bool _framedWithDriver = false;

  Worker? _positionWorker;
  Worker? _phaseWorker;
  Worker? _snapshotWorker;

  // Cached Mapbox-routed line for the current leg. Refreshed on map init and
  // on phase flips; driver-only ticks reuse it (no extra Directions calls).
  MapRoute? _routeForCurrentLeg;
  TrackingPhase? _routedPhase;
  bool _fetchingRoute = false;

  MapPoint get _driver => _controller.driverPosition.value;
  MapPoint get _seller => _controller.pickupPoint;
  MapPoint get _client => _controller.dropoffPoint;

  // A point is "real" once the snapshot has filled it; the (0,0) sentinel is
  // never drawn (no fake coordinates, no null-island markers).
  bool _isReal(MapPoint p) => p.lng != 0 || p.lat != 0;
  bool get _hasDriverFix => _controller.hasAssignedDriver && _isReal(_driver);

  Point _pt(MapPoint p) => Point(coordinates: Position(p.lng, p.lat));

  /// Ordered stops the route line connects for the current phase (real only):
  ///   * awaitingPickup → driver → seller → client (whole upcoming trip, so the
  ///     buyer sees the path joining all three at once)
  ///   * enRoute        → driver → client (seller already visited; its marker
  ///     stays on the map as a completed stop)
  List<MapPoint> get _routeStops {
    final ordered = _controller.phase.value == TrackingPhase.awaitingPickup
        ? <MapPoint>[_driver, _seller, _client]
        : <MapPoint>[_driver, _client];
    return ordered.where(_isReal).toList();
  }

  /// Every real point the camera should frame (seller + client + driver-if-
  /// assigned). Seller/client stay framed even after pickup so all three
  /// remain visible.
  List<MapPoint> get _cameraPoints => <MapPoint>[
        if (_isReal(_seller)) _seller,
        if (_isReal(_client)) _client,
        if (_hasDriverFix) _driver,
      ];

  /// Neutral initial viewport (average of known points, else central Paris).
  /// This is only the empty-map centre before [_fitCamera] reframes to the real
  /// points — it is a viewport default, never a marker.
  MapPoint get _initialCenter {
    final pts = _cameraPoints;
    if (pts.isEmpty) return const MapPoint(lng: 2.3522, lat: 48.8566);
    final lng = pts.map((p) => p.lng).reduce((a, b) => a + b) / pts.length;
    final lat = pts.map((p) => p.lat).reduce((a, b) => a + b) / pts.length;
    return MapPoint(lng: lng, lat: lat);
  }

  @override
  void initState() {
    super.initState();
    // Driver moved → slide the driver dot + refresh the route line. No camera
    // jump, no full marker rebuild, no new Directions call.
    _positionWorker = ever<MapPoint>(_controller.driverPosition, (_) async {
      await _updateDriverMarker();
      await _refreshPolyline();
    });
    // Phase flipped (food picked up) → rebuild markers + route + reframe once.
    _phaseWorker = ever<TrackingPhase>(_controller.phase, (_) async {
      await _redrawAllMarkers();
      await _refreshPolyline();
      await _fitCamera();
    });
    // Snapshot resolved after the map was built → draw the now-known points.
    _snapshotWorker = ever<bool>(_controller.snapshotReady, (ready) async {
      if (!ready) return;
      await _redrawAllMarkers();
      await _refreshPolyline();
      await _fitCamera();
    });
  }

  @override
  void dispose() {
    _positionWorker?.dispose();
    _phaseWorker?.dispose();
    _snapshotWorker?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );

    _polylineManager = await map.annotations.createPolylineAnnotationManager();
    _circleManager = await map.annotations.createCircleAnnotationManager();
    _pointManager = await map.annotations.createPointAnnotationManager();

    await _redrawAllMarkers();
    await _refreshPolyline();
    await _fitCamera();
    debugPrint(
      '[TrackingMap] view drawn — seller=${_isReal(_seller)} '
      'client=${_isReal(_client)} driver=$_hasDriverFix '
      'markers=${_cameraPoints.length}',
    );
  }

  /// (Re)draws all three markers. Clears first so phase flips / re-renders
  /// don't stack duplicates. The driver dot is drawn only when a real fix
  /// exists. Skips any unset (0,0) point.
  Future<void> _redrawAllMarkers() async {
    final cm = _circleManager, pm = _pointManager;
    if (cm == null || pm == null || !mounted) return;
    await cm.deleteAll();
    await pm.deleteAll();
    _driverCircle = null;
    _driverLabel = null;

    if (_isReal(_seller)) {
      await cm.create(_dot(_seller, _sellerColor));
      await _label(_seller, 'Retrait', _sellerColor);
    }
    if (_isReal(_client)) {
      await cm.create(_dot(_client, _clientColor));
      await _label(_client, 'Livraison', _clientColor);
    }
    if (_hasDriverFix) {
      _driverCircle = await cm.create(_dot(_driver, _driverColor, radius: 9));
      _driverLabel = await _label(_driver, 'Livreur', _driverColor);
    }
  }

  /// Slides the driver dot/label to the latest fix (creating them on the first
  /// fix). Cheap — no full rebuild, no Directions call, no camera jump (except
  /// a single reframe the first time the driver appears).
  Future<void> _updateDriverMarker() async {
    final cm = _circleManager, pm = _pointManager;
    if (cm == null || pm == null || !mounted || !_hasDriverFix) return;
    final geometry = _pt(_driver);
    final circle = _driverCircle, label = _driverLabel;
    if (circle != null && label != null) {
      circle.geometry = geometry;
      label.geometry = geometry;
      await cm.update(circle);
      await pm.update(label);
    } else {
      _driverCircle = await cm.create(_dot(_driver, _driverColor, radius: 9));
      _driverLabel = await _label(_driver, 'Livreur', _driverColor);
      if (!_framedWithDriver) {
        _framedWithDriver = true;
        await _fitCamera();
      }
    }
  }

  CircleAnnotationOptions _dot(MapPoint at, int color, {double radius = 11}) =>
      CircleAnnotationOptions(
        geometry: _pt(at),
        circleRadius: radius,
        circleColor: color,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      );

  Future<PointAnnotation> _label(MapPoint at, String text, int color) {
    return _pointManager!.create(
      PointAnnotationOptions(
        geometry: _pt(at),
        textField: text,
        textColor: color,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 1.6,
        textSize: 13.0,
        // Lift the label just above the dot (offset is in ems).
        textOffset: [0.0, -1.8],
      ),
    );
  }

  /// Draws/updates the polyline for the active leg through all its stops.
  ///   - On a phase change (or first draw) fetch a fresh routed line through
  ///     the stops; otherwise reuse the cached one (driver ticks never call
  ///     Mapbox Directions).
  ///   - Falls back to straight segments through the same stops so the path
  ///     between driver, seller and client is always drawn.
  Future<void> _refreshPolyline() async {
    if (_polylineManager == null || !mounted) return;
    final phase = _controller.phase.value;
    final stops = _routeStops;

    final needsRouteFetch = _routedPhase != phase && !_fetchingRoute;
    if (needsRouteFetch && stops.length >= 2) {
      _fetchingRoute = true;
      try {
        final client = Get.isRegistered<MapboxDirectionsClient>()
            ? Get.find<MapboxDirectionsClient>()
            : MapboxDirectionsClient();
        _routeForCurrentLeg = await client.getRouteThrough(stops);
        _routedPhase = phase;
      } catch (_) {
        // Mapbox rejected (token, network, no route) — fall through to the
        // straight-line path below.
        _routeForCurrentLeg = null;
      } finally {
        _fetchingRoute = false;
      }
      if (!mounted || _polylineManager == null) return;
    }

    final coords = _routeForCurrentLeg != null
        ? _routeForCurrentLeg!.points
            .map((p) => Position(p.lng, p.lat))
            .toList()
        : stops.map((p) => Position(p.lng, p.lat)).toList();
    if (coords.length < 2) return;

    if (_polyline == null) {
      _polyline = await _polylineManager!.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineWidth: 6.0,
          lineColor: _routeColor,
        ),
      );
    } else {
      _polyline!.geometry = LineString(coordinates: coords);
      await _polylineManager!.update(_polyline!);
    }
  }

  /// Frames the camera to every real point (seller + client + driver-if-known)
  /// so the whole path is on screen. Called on open, phase flip, and the first
  /// driver fix — never on every driver tick (that would yank the camera).
  Future<void> _fitCamera() async {
    final map = _map;
    if (map == null || !mounted) return;
    final pts = _cameraPoints;
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      await map.setCamera(CameraOptions(center: _pt(pts.first), zoom: 14.0));
      return;
    }
    try {
      final camera = await map.cameraForCoordinatesPadding(
        pts.map(_pt).toList(),
        CameraOptions(),
        // Extra bottom inset leaves room for the tracking bottom sheet.
        MbxEdgeInsets(top: 90, left: 60, bottom: 160, right: 60),
        16.0,
        null,
      );
      if (!mounted) return;
      await map.setCamera(camera);
    } catch (_) {
      // Keep the current camera on any framing error.
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleUri = context.isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT;
    final center = _initialCenter;
    return MapWidget(
      styleUri: styleUri,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(center.lng, center.lat)),
        zoom: 13.0,
      ),
      onMapCreated: _onMapCreated,
    );
  }
}
