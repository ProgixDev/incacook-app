import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/constants/image_strings.dart';
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
  ScreenCoordinate? _destinationScreenCoord;

  Worker? _positionWorker;

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
  }

  @override
  void dispose() {
    _positionWorker?.dispose();
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

  Future<void> _refreshPolyline() async {
    if (_polylineManager == null || !mounted) return;
    final coords = [
      Position(_driver.lng, _driver.lat),
      Position(_destination.lng, _destination.lat),
    ];
    if (_polyline == null) {
      final scheme = Theme.of(context).colorScheme;
      _polyline = await _polylineManager!.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineWidth: 4.0,
          lineColor: scheme.onSurface.toARGB32(),
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
    final results = await _map!.pixelsForCoordinates([
      Point(coordinates: Position(_driver.lng, _driver.lat)),
      Point(coordinates: Position(_destination.lng, _destination.lat)),
    ]);
    if (!mounted) return;
    setState(() {
      _driverScreenCoord = results[0];
      _destinationScreenCoord = results[1];
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

        if (_destinationScreenCoord != null)
          Positioned(
            left: _destinationScreenCoord!.x - _destinationSize / 2,
            top: _destinationScreenCoord!.y,
            width: _destinationSize,
            height: _destinationSize,
            child: const _DestinationMarker(),
          ),

        if (_driverScreenCoord != null)
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

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.onSurface,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.home_rounded, color: scheme.surface, size: 22),
        ),
        //? tiny tail to look like a pin pointing down
        Container(width: 2, height: 4, color: scheme.onSurface),
      ],
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
