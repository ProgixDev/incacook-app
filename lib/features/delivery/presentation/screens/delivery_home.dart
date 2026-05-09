import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/controllers/incoming_order_controller.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_top_buttons.dart';
import 'package:incacook/features/delivery/presentation/widgets/incoming_order_sheet.dart';
import 'package:incacook/features/delivery/utils/delivery_map_painter.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/features/payments/presentation/widgets/payout_setup_banner.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  late final DeliveryRouteController _route;
  late final IncomingOrderController _incoming;
  DeliveryMapPainter? _painter;
  Worker? _routeWorker;
  Worker? _incomingWorker;
  bool _modalOpen = false;

  @override
  void initState() {
    super.initState();
    _route = Get.put(DeliveryRouteController());
    Get.put(DeliveryDriverController());
    _incoming = Get.put(IncomingOrderController());
    _incomingWorker = ever<OrderDetail?>(
      _incoming.pendingOrder,
      _onPendingOrderChanged,
    );
  }

  @override
  void dispose() {
    _routeWorker?.dispose();
    _incomingWorker?.dispose();
    super.dispose();
  }

  Future<void> _onPendingOrderChanged(OrderDetail? order) async {
    if (order == null || _modalOpen || !mounted) return;
    _modalOpen = true;
    try {
      final accepted = await showIncomingOrderModal(context, order: order);
      if (accepted == true) {
        await _route.acceptJob(order);
        _incoming.resolve(accepted: true);
      } else {
        _incoming.resolve(accepted: false);
      }
    } finally {
      _modalOpen = false;
    }
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
    //? bootstrap deferred to DeliveryRouteController.acceptJob — the screen
    //? has no job until the driver accepts one.
  }

  Future<void> _onRouteChanged(MapRoute? route) async {
    final pickup = _route.pickup;
    final dropoff = _route.dropoff;
    if (route == null || pickup == null || dropoff == null) return;
    await _painter?.renderRoute(route, pickup: pickup, dropoff: dropoff);
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
          //* Payout setup nudge — sits just under the top buttons until the
          //* driver completes Stripe Connect Express onboarding. Tap is
          //* stubbed until the StripeConnectService lands.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  72,
                  AppSizes.md,
                  0,
                ),
                child: PayoutSetupBanner(
                  onTap: () => _onPayoutSetupTap(context),
                ),
              ),
            ),
          ),
          const DeliveryBottomSheet(),
        ],
      ),
    );
  }

  void _onPayoutSetupTap(BuildContext context) {
    // Stub — replace with the Stripe Connect onboarding flow once the
    // StripeConnectService + PayoutOnboardingScreen ship.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppTexts.payoutGatingSnackbarDriver),
      ),
    );
  }
}
