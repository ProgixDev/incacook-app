import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/payout_readiness.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';
import 'package:incacook/features/delivery/controllers/driver_location_mode_coordinator.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/controllers/incoming_order_controller.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/delivery/domain/delivery_map_policy.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_top_buttons.dart';
import 'package:incacook/features/delivery/presentation/widgets/incoming_order_sheet.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/payments/presentation/widgets/payout_setup_banner.dart';
import 'package:incacook/core/utils/log.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  late final DeliveryRouteController _route;
  late final DeliveryDriverController _driver;
  late final DriverLocationModeCoordinator<OrderDetail> _locationMode;
  late final IncomingOrderController _incoming;
  GoogleMapController? _map;
  Worker? _routeWorker;
  Worker? _incomingWorker;
  Worker? _jobWorker;
  Worker? _onlineWorker;
  Worker? _onlineErrorWorker;
  bool _modalOpen = false;
  Set<Marker> _markers = const {};
  Set<Marker> _onlineMarkers = const {};
  Set<Polyline> _polylines = const {};

  @override
  void initState() {
    super.initState();
    _route = Get.put(DeliveryRouteController());
    _driver = Get.put(DeliveryDriverController());
    _locationMode = DriverLocationModeCoordinator<OrderDetail>(
      online: _driver.isOnline,
      activeJob: _route.currentJob,
      location: LocationService.instance,
      onError: (error) => logWarning(
        '[DriverLocationMode] failed to apply location mode: $error',
      ),
    );
    unawaited(_locationMode.start());
    _incoming = Get.put(IncomingOrderController());
    _incomingWorker = ever<OrderDetail?>(
      _incoming.pendingOrder,
      _onPendingOrderChanged,
    );
    _onlineWorker = ever<bool>(_driver.isOnline, _onOnlineChanged);
    _onlineErrorWorker = ever<String?>(
      _driver.lastError,
      _onOnlineErrorChanged,
    );
    unawaited(_restoreDriverSession());
  }

  /// Re-hydrates the driver's session on (re)entry so it survives an app
  /// restart: restore any in-progress delivery first (so resumed polling
  /// doesn't offer a new order over the top of it), then restore the online
  /// status. Both read from the backend — local state always boots to
  /// offline / no-job. Best-effort throughout.
  Future<void> _restoreDriverSession() async {
    // Restore the active delivery FIRST so its itinerary paints as fast as
    // possible on open: [DeliveryRouteController.bootstrap] reads the current
    // GPS fix and computes the route straight away, without waiting on the
    // slower profile refresh below.
    await _restoreActiveJob();
    if (!mounted) return;
    try {
      // Refresh the profile so `driverAccount.isOnline` reflects the server,
      // not the (possibly stale) snapshot cached at login.
      await UserController.instance.refreshFromServer();
    } catch (_) {
      // Fall back to whatever profile snapshot we already have.
    }
    if (!mounted) return;
    await _driver.restoreOnlineState();
  }

  Future<void> _restoreActiveJob() async {
    if (_route.currentJob.value != null) return;
    try {
      final active = await DeliveriesRepository.instance.activeMine();
      final stage = active?.restoredStage;
      if (active == null || stage == null || !mounted) return;
      final job = IncomingOrderController.hydrateFromSummary(active);
      await _route.restoreJob(job, deliveryId: active.id, stage: stage);
    } catch (_) {
      // A failed restore just leaves the driver on the idle map; the next
      // available-poll (once online) still works.
    }
  }

  @override
  void dispose() {
    _routeWorker?.dispose();
    _incomingWorker?.dispose();
    _jobWorker?.dispose();
    _onlineWorker?.dispose();
    _onlineErrorWorker?.dispose();
    _locationMode.dispose();
    super.dispose();
  }

  Future<void> _onOnlineChanged(bool online) async {
    if (!online) {
      if (!mounted) return;
      setState(() => _onlineMarkers = const {});
      return;
    }
    await _refreshOnlineMarker();
  }

  void _onOnlineErrorChanged(String? message) {
    if (message == null || message.isEmpty || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _onPendingOrderChanged(OrderDetail? order) async {
    if (order == null || _modalOpen || !mounted) return;
    _modalOpen = true;
    try {
      // Gate "Accepter" on the backend claim rule, which is KYC only — Stripe
      // payout onboarding does NOT block claiming (it's required at cashout).
      final canClaim = UserController.instance.canDriverClaim;
      final accepted = await showIncomingOrderModal(
        context,
        order: order,
        canClaim: canClaim,
      );
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(_claimErrorMessage(e))));
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

  /// Maps a claim failure to a clear French message — never the raw backend
  /// error. A 403 payout-onboarding rejection becomes the "set up payments"
  /// hint; anything else is a generic retry message.
  String _claimErrorMessage(Object error) {
    if (error is ApiFailure) {
      final isPayout =
          error.code == 'INCACOOK_PAYOUT_ONBOARDING_INCOMPLETE' ||
          (error.statusCode == 403 &&
              error.message.toLowerCase().contains(
                'stripe connect onboarding',
              ));
      if (isPayout) return AppTexts.incomingOrderPayoutRequired;
    }
    return AppTexts.incomingOrderClaimFailed;
  }

  /// Opens Stripe Connect payout onboarding, then refreshes the driver profile
  /// so the claim gate re-evaluates without an app restart (the next offer's
  /// "Accepter" is enabled once onboarding is complete).
  Future<void> _configurePayments() async {
    if (!mounted) return;
    await PayoutOnboardingService.instance.openOnboarding(context);
    try {
      await UserController.instance.refreshFromServer();
    } catch (_) {
      // Best-effort refresh; the home banner / next poll will retry.
    }
  }

  Future<void> _onMapCreated(GoogleMapController map) async {
    _map = map;
    _routeWorker = ever<MapRoute?>(_route.route, _onRouteChanged);
    _jobWorker = ever<OrderDetail?>(_route.currentJob, _onJobChanged);

    //? A job may already be active when the map (re)mounts — `ever` only
    //? fires on change, so paint the current state once up front.
    final hasActiveJob = _route.currentJob.value != null;
    final existing = _route.route.value;
    if (hasActiveJob) {
      unawaited(_onJobChanged(_route.currentJob.value));
      if (existing != null) unawaited(_onRouteChanged(existing));
    }
    if (shouldCenterDriverOnMapOpen(
      hasActiveJob: hasActiveJob,
      hasRoute: existing != null,
    )) {
      //? Open on the driver's current position instead of the Paris default.
      //? Once an active route exists, route framing owns the camera.
      unawaited(_centerInitialCamera(allowActiveJob: hasActiveJob));
    }
    if (_driver.isOnline.value) unawaited(_refreshOnlineMarker());
  }

  /// One-shot camera snap to the driver's current position on first map load.
  /// Reads the live fix when the stream is already running, otherwise triggers
  /// a one-off [LocationService.getCurrent] (which also prompts for permission).
  /// Silent on failure. For an idle open it bails if a job became active while
  /// the fix was in flight; active restoration opts in until a route is ready.
  Future<void> _centerInitialCamera({required bool allowActiveJob}) async {
    var pos = _route.currentDriverPosition;
    if (pos == null) {
      final current = await LocationService.instance.getCurrent();
      if (current != null) {
        pos = MapPoint(lat: current.latitude, lng: current.longitude);
      }
    }
    final map = _map;
    if (pos == null || map == null || !mounted) return;
    if (!allowActiveJob && _route.currentJob.value != null) return;
    await map.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.lat, pos.lng), 15),
    );
  }

  Future<void> _refreshOnlineMarker() async {
    var pos = _route.currentDriverPosition;
    if (pos == null) {
      final current = await LocationService.instance.getCurrent();
      if (current != null) {
        pos = MapPoint(lat: current.latitude, lng: current.longitude);
      }
    }
    if (pos == null || !mounted) return;
    final onlinePosition = pos;
    setState(() {
      _onlineMarkers = {
        Marker(
          markerId: const MarkerId('driver-online'),
          position: LatLng(onlinePosition.lat, onlinePosition.lng),
          infoWindow: const InfoWindow(title: 'Vous etes en ligne'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      };
    });
  }

  /// Job accepted → drop the seller + client markers immediately (so the
  /// emplacements show even if the route fetch is slow/unavailable).
  /// Job cleared → wipe the whole overlay.
  Future<void> _onJobChanged(OrderDetail? job) async {
    if (job == null) {
      if (mounted) {
        setState(() {
          _markers = const {};
          _polylines = const {};
        });
      }
      return;
    }
    final pickup = _route.pickup;
    final dropoff = _route.dropoff;
    final driver = _route.currentDriverPosition;
    String fmt(MapPoint? p) => p == null
        ? 'MISSING'
        : '(${p.lat.toStringAsFixed(5)},${p.lng.toStringAsFixed(5)})';
    // Driver's own position shows as the native location puck (configure()),
    // so it isn't a circle marker — log it for completeness.
    logInfo(
      '[TrackingMap](driver) pickup=${fmt(pickup)}, dropoff=${fmt(dropoff)}, '
      'driver=${driver == null ? "puck-pending" : fmt(driver)}',
    );
    if (pickup == null && dropoff == null) {
      logWarning(
        '[TrackingMap](driver) both stop coords missing — markers not drawn '
        '(seller/client not geocoded).',
      );
      return;
    }
    if (!mounted) return;
    // Draw whichever stops we have. Previously a single missing coordinate
    // (e.g. an un-geocoded dropoff) skipped ALL markers AND the camera frame,
    // leaving the map on its Paris default — the "line drawn but I see nothing"
    // symptom. Now we frame around whatever real points exist.
    setState(() {
      _markers = {
        if (pickup != null)
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickup.lat, pickup.lng),
            infoWindow: const InfoWindow(title: 'Vendeur'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        if (dropoff != null)
          Marker(
            markerId: const MarkerId('dropoff'),
            position: LatLng(dropoff.lat, dropoff.lng),
            infoWindow: const InfoWindow(title: 'Client'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
      };
    });
    await _framePoints([?pickup, ?dropoff]);
  }

  Future<void> _onRouteChanged(MapRoute? route) async {
    //? Null route = job cleared; the job worker handles the reset.
    if (route == null) return;
    if (!mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('active-route'),
          points: route.points.map((p) => LatLng(p.lat, p.lng)).toList(),
          color: const Color(0xFF0066FF),
          width: 6,
        ),
      };
    });
    await _framePoints(route.points);
  }

  Future<void> _centerOnDriver() async {
    final map = _map;
    if (map == null) return;

    var pos = _route.currentDriverPosition;
    if (pos == null) {
      final current = await LocationService.instance.getCurrent();
      if (current != null) {
        pos = MapPoint(lat: current.latitude, lng: current.longitude);
      }
    }

    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activez la localisation pour centrer la carte.'),
        ),
      );
      return;
    }

    await map.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.lat, pos.lng), 14),
    );
  }

  /// Fits the camera to the whole active route — driver, pickup, dropoff and
  /// the drawn polyline — on demand (the map only frames automatically when the
  /// route/job first changes). Uses the computed route points (which already
  /// include the driver→seller→client itinerary) and falls back to the known
  /// stops when the polyline hasn't been computed yet.
  Future<void> _fitActiveRoute() async {
    final points = _route.route.value?.points;
    if (points != null && points.isNotEmpty) {
      await _framePoints(points);
      return;
    }
    final stops = <MapPoint>[
      if (_route.currentDriverPosition != null) _route.currentDriverPosition!,
      if (_route.pickup != null) _route.pickup!,
      if (_route.dropoff != null) _route.dropoff!,
    ];
    if (stops.isNotEmpty) await _framePoints(stops);
  }

  Future<void> _framePoints(List<MapPoint> points, {bool retry = true}) async {
    final map = _map;
    if (map == null || points.isEmpty) return;
    if (points.length == 1) {
      await map.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(points.first.lat, points.first.lng),
          14,
        ),
      );
      return;
    }

    var minLat = points.first.lat;
    var maxLat = points.first.lat;
    var minLng = points.first.lng;
    var maxLng = points.first.lng;
    for (final point in points) {
      if (point.lat < minLat) minLat = point.lat;
      if (point.lat > maxLat) maxLat = point.lat;
      if (point.lng < minLng) minLng = point.lng;
      if (point.lng > maxLng) maxLng = point.lng;
    }

    try {
      await map.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80,
        ),
      );
    } catch (_) {
      // `newLatLngBounds` throws on the native side when the map has no
      // concrete size yet (common on the first frame right after accept) or
      // when two frame animations race. Retry once after layout settles, then
      // fall back to centring on the midpoint so the route/markers are never
      // left off-screen on the Paris default view — the reported
      // "zoom in, line drawn, then nothing when I zoom out" bug.
      if (retry) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        await _framePoints(points, retry: false);
        return;
      }
      await map.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
          12,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522),
              zoom: 11,
            ),
            markers: {..._markers, ..._onlineMarkers},
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Obx(
                () => _driver.isOnline.value
                    ? const _OnlineConfirmedPill()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Obx(
            () => DeliveryTopButtons(
              onGpsTap: _centerOnDriver,
              onFitRouteTap:
                  _route.currentJob.value != null ? _fitActiveRoute : null,
            ),
          ),
          //* Payout setup nudge — sits just under the top buttons until the
          //* driver completes Stripe Connect Express onboarding. Hidden once
          //* payouts are ready so it disappears right after onboarding (no
          //* app restart — driven by the reactive UserController).
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
                child: Obx(
                  () => UserController.instance.driverPayoutReady
                      ? const SizedBox.shrink()
                      : PayoutSetupBanner(
                          onTap: _configurePayments,
                          // Details already with Stripe → swap the setup
                          // CTA for "verification in progress".
                          pendingVerification:
                              UserController.instance.payoutSetupState ==
                              PayoutSetupState.pendingVerification,
                          // D6: the last status check itself failed —
                          // distinct from "not done yet".
                          reconcileFailed: PayoutOnboardingService
                              .instance
                              .reconcileFailed
                              .value,
                        ),
                ),
              ),
            ),
          ),
          const DeliveryBottomSheet(),
        ],
      ),
    );
  }
}

class _OnlineConfirmedPill extends StatelessWidget {
  const _OnlineConfirmedPill();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF00A85A)),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A85A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'En ligne - pret a recevoir des courses',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
