import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/services/map/mapbox_directions_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/orders/controllers/order_tracking_controller.dart';

class OnTheWayStageView extends StatefulWidget {
  const OnTheWayStageView({super.key});

  @override
  State<OnTheWayStageView> createState() => _OnTheWayStageViewState();
}

class _OnTheWayStageViewState extends State<OnTheWayStageView> {
  static const double _driverSize = 56;
  static const double _destinationSize = 48;

  final OrderTrackingController _controller = OrderTrackingController.instance;

  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  PolylineAnnotation? _polyline;

  ScreenCoordinate? _driverScreenCoord;
  ScreenCoordinate? _sellerScreenCoord;
  ScreenCoordinate? _clientScreenCoord;

  Worker? _positionWorker;
  Worker? _phaseWorker;

  // Cached Mapbox-routed line for the current leg. Refreshed on map
  // init AND on phase flips (driver -> seller becomes driver -> buyer).
  // Position-only ticks don't refetch — would burn Mapbox quota.
  MapRoute? _routeForCurrentLeg;
  TrackingPhase? _routedPhase;
  bool _fetchingRoute = false;

  MapPoint get _driver => _controller.driverPosition.value;
  MapPoint get _destination => _controller.destination;

  MapPoint get _center => MapPoint(
    lng: (_driver.lng + _destination.lng) / 2,
    lat: (_driver.lat + _destination.lat) / 2,
  );

  @override
  void initState() {
    super.initState();
    _positionWorker = ever<MapPoint>(_controller.driverPosition, (_) async {
      await _refreshPolyline();
      await _projectMarkers();
    });
    // When the trip phase flips (IN_DELIVERY arrives), the destination
    // getter swaps from seller -> buyer dropoff. Re-render the
    // polyline + marker projections so the map switches legs.
    _phaseWorker = ever<TrackingPhase>(_controller.phase, (_) async {
      await _refreshPolyline();
      await _projectMarkers();
    });
  }

  @override
  void dispose() {
    _positionWorker?.dispose();
    _phaseWorker?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );

    _polylineManager = await map.annotations.createPolylineAnnotationManager();
    await _refreshPolyline();
    await _projectMarkers();
  }

  /// Draws/updates the polyline for the active leg.
  ///   - If the phase changed since the last route fetch (or we don't
  ///     have one yet), call Mapbox Directions for a fresh routed line.
  ///   - Otherwise, fall back to a straight line between driver and
  ///     destination (cheap update for the driver-tick path).
  /// Errors fall back to the straight line so the map always has
  /// something visible.
  Future<void> _refreshPolyline() async {
    if (_polylineManager == null || !mounted) return;
    final phase = _controller.phase.value;

    final needsRouteFetch = _routedPhase != phase && !_fetchingRoute;
    if (needsRouteFetch) {
      _fetchingRoute = true;
      try {
        final client = Get.isRegistered<MapboxDirectionsClient>()
            ? Get.find<MapboxDirectionsClient>()
            : MapboxDirectionsClient();
        _routeForCurrentLeg = await client.getRoute(
          origin: _driver,
          destination: _destination,
        );
        _routedPhase = phase;
      } catch (_) {
        // Mapbox rejected (token, network, no route) — caller will
        // fall through to the straight-line path below.
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
        : <Position>[
            Position(_driver.lng, _driver.lat),
            Position(_destination.lng, _destination.lat),
          ];

    if (_polyline == null) {
      // Use a bold blue so the route stands out on both light + dark
      // styles — same blue as Mapbox's own turn-by-turn UI.
      _polyline = await _polylineManager!.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineWidth: 6.0,
          lineColor: 0xFF0066FF,
        ),
      );
    } else {
      _polyline!.geometry = LineString(coordinates: coords);
      await _polylineManager!.update(_polyline!);
    }
  }

  void _onCameraChange(CameraChangedEventData _) {
    unawaited(_projectMarkers());
  }

  Future<void> _projectMarkers() async {
    if (_map == null) return;
    final pickup = _controller.pickupPoint;
    final dropoff = _controller.dropoffPoint;
    final results = await _map!.pixelsForCoordinates([
      Point(coordinates: Position(_driver.lng, _driver.lat)),
      Point(coordinates: Position(pickup.lng, pickup.lat)),
      Point(coordinates: Position(dropoff.lng, dropoff.lat)),
    ]);
    if (!mounted) return;
    setState(() {
      _driverScreenCoord = results[0];
      _sellerScreenCoord = results[1];
      _clientScreenCoord = results[2];
    });
  }

  @override
  Widget build(BuildContext context) {
    final styleUri = context.isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT;

    return Stack(
      children: [
        MapWidget(
          styleUri: styleUri,
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(_center.lng, _center.lat)),
            zoom: 14.0,
          ),
          onMapCreated: _onMapCreated,
          onCameraChangeListener: _onCameraChange,
        ),

        // Seller (pickup) marker — active while heading there, dimmed to
        // a "completed pickup" once the driver is en route to the client.
        if (_sellerScreenCoord != null)
          Positioned(
            left: _sellerScreenCoord!.x - _destinationSize / 2,
            top: _sellerScreenCoord!.y,
            width: _destinationSize,
            height: _destinationSize,
            child: _StopMarker(
              icon: Icons.storefront_rounded,
              active: _controller.phase.value == TrackingPhase.awaitingPickup,
            ),
          ),

        // Client (dropoff) marker — secondary while the driver is still
        // at/heading to the seller, active once the food is picked up.
        if (_clientScreenCoord != null)
          Positioned(
            left: _clientScreenCoord!.x - _destinationSize / 2,
            top: _clientScreenCoord!.y,
            width: _destinationSize,
            height: _destinationSize,
            child: _StopMarker(
              icon: Icons.home_rounded,
              active: _controller.phase.value == TrackingPhase.enRoute,
            ),
          ),

        // Driver marker only once a real driver is assigned — never a fake
        // dot before assignment.
        if (_driverScreenCoord != null && _controller.hasAssignedDriver)
          Positioned(
            left: _driverScreenCoord!.x - _driverSize / 2,
            top: _driverScreenCoord!.y - _driverSize / 2,
            width: _driverSize,
            height: _driverSize,
            child: const _DriverMarker(),
          ),
      ],
    );
  }
}

/// A trip stop pin (seller pickup or client dropoff). [active] marks the
/// leg the driver is currently on — drawn in full primary; the other
/// stop is dimmed so it reads as upcoming/completed but stays visible.
class _StopMarker extends StatelessWidget {
  const _StopMarker({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active ? scheme.primary : scheme.onSurfaceVariant;
    return Opacity(
      opacity: active ? 1.0 : 0.55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: scheme.surface, size: 22),
          ),
          //? tiny tail to look like a pin pointing down
          Container(width: 2, height: 4, color: bg),
        ],
      ),
    );
  }
}

class _DriverMarker extends StatelessWidget {
  const _DriverMarker();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFFE8823B),
        backgroundImage: AssetImage(AppImages.profilePic),
      ),
    );
  }
}
