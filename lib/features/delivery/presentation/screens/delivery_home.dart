import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/controllers/incoming_order_controller.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_top_buttons.dart';
import 'package:incacook/features/delivery/presentation/widgets/incoming_order_sheet.dart';
import 'package:incacook/features/delivery/utils/delivery_map_painter.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
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
  Worker? _jobWorker;
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
    _jobWorker?.dispose();
    super.dispose();
  }

  Future<void> _onPendingOrderChanged(OrderDetail? order) async {
    if (order == null || _modalOpen || !mounted) return;
    _modalOpen = true;
    try {
      final accepted = await showIncomingOrderModal(context, order: order);
      if (accepted == true) {
        final deliveryId = _incoming.pendingDeliveryId.value;
        if (deliveryId == null) {
          // No real id captured — likely a stale mock; just resolve.
          _incoming.resolve(accepted: false);
          return;
        }
        try {
          await DeliveriesRepository.instance.claim(deliveryId);
          await _route.acceptJob(order, deliveryId: deliveryId);
          _incoming.resolve(accepted: true);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Couldn\'t claim job: $e')),
            );
          }
          _incoming.resolve(accepted: false);
        }
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
    final pointManager = await map.annotations.createPointAnnotationManager();
    _painter = DeliveryMapPainter(
      map: map,
      polylineManager: polylineManager,
      circleManager: circleManager,
      pointManager: pointManager,
    );

    _routeWorker = ever<MapRoute?>(_route.route, _onRouteChanged);
    _jobWorker = ever<OrderDetail?>(_route.currentJob, _onJobChanged);

    //? A job may already be active when the map (re)mounts — `ever` only
    //? fires on change, so paint the current state once up front.
    if (_route.currentJob.value != null) {
      unawaited(_onJobChanged(_route.currentJob.value));
      final existing = _route.route.value;
      if (existing != null) unawaited(_onRouteChanged(existing));
    }
  }

  /// Job accepted → drop the seller + client markers immediately (so the
  /// emplacements show even if the route fetch is slow/unavailable).
  /// Job cleared → wipe the whole overlay.
  Future<void> _onJobChanged(OrderDetail? job) async {
    if (job == null) {
      await _painter?.reset();
      return;
    }
    final pickup = _route.pickup;
    final dropoff = _route.dropoff;
    if (pickup == null || dropoff == null) return;
    await _painter?.showStops(pickup: pickup, dropoff: dropoff);
  }

  Future<void> _onRouteChanged(MapRoute? route) async {
    //? Null route = job cleared; the job worker handles the reset.
    if (route == null) return;
    await _painter?.showRoute(route);
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
    // Opens Stripe Connect Express onboarding so the driver can add the
    // bank/debit card that receives their delivery earnings.
    PayoutOnboardingService.openOnboarding(context);
  }
}
