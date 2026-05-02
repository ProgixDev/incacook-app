import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:homemade/core/services/map/models/map_route.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:homemade/features/delivery/controllers/delivery_route_controller.dart';
import 'package:homemade/features/delivery/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:homemade/features/delivery/presentation/widgets/delivery_top_buttons.dart';
import 'package:homemade/features/delivery/utils/delivery_map_painter.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  late final DeliveryRouteController _route;
  DeliveryMapPainter? _painter;
  Worker? _routeWorker;

  @override
  void initState() {
    super.initState();
    _route = Get.put(DeliveryRouteController());
    Get.put(DeliveryDriverController());
  }

  @override
  void dispose() {
    _routeWorker?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await DeliveryMapPainter.configure(map);

    final polylineManager = await map.annotations
        .createPolylineAnnotationManager();
    final circleManager = await map.annotations.createCircleAnnotationManager();
    _painter = DeliveryMapPainter(
      map: map,
      polylineManager: polylineManager,
      circleManager: circleManager,
    );

    _routeWorker = ever<MapRoute?>(_route.route, _onRouteChanged);
    await _route.bootstrap();
  }

  Future<void> _onRouteChanged(MapRoute? route) async {
    if (route == null) return;
    await _painter?.renderRoute(
      route,
      pickup: _route.pickup,
      dropoff: _route.dropoff,
    );
  }

  Future<void> _centerOnDriver() async {
    final pos = _route.currentDriverPosition;
    if (pos != null) await _painter?.flyToDriver(pos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapWidget(
            styleUri: context.isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(2.3522, 48.8566)),
              zoom: 11.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          DeliveryTopButtons(onGpsTap: _centerOnDriver),
          const DeliveryBottomSheet(),
        ],
      ),
    );
  }
}
