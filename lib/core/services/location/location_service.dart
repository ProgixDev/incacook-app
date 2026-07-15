import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Platform behavior required by the driver's current work state.
enum LocationMode { off, foreground, background }

/// The single policy for choosing the driver's location behavior.
LocationMode desiredLocationMode({
  required bool online,
  required bool hasActiveJob,
}) {
  if (!online) return LocationMode.off;
  return hasActiveJob ? LocationMode.background : LocationMode.foreground;
}

abstract interface class LocationModeApplier {
  Future<void> applyMode(LocationMode mode);
}

class LocationService extends GetxService implements LocationModeApplier {
  static LocationService get instance => Get.find();

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<LocationPermission> permission =
      LocationPermission.unableToDetermine.obs;

  /// Human-readable "City, Country" for the current location, reverse-geocoded
  /// by whoever resolves the position (e.g. the client home). Null until known
  /// — UI shows a fallback meanwhile.
  final Rxn<String> placeLabel = Rxn<String>();

  StreamSubscription<Position>? _positionSub;

  /// Whether the current stream is running in background-persistent mode
  /// (Android foreground service / iOS background location updates). Tracked so
  /// [start] can restart the stream when the mode changes — e.g. idle-online
  /// (foreground) → active delivery (background).
  bool _backgroundMode = false;

  LocationMode _mode = LocationMode.off;

  LocationMode get mode => _mode;

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var current = await Geolocator.checkPermission();
    if (current == LocationPermission.denied) {
      current = await Geolocator.requestPermission();
    }
    permission.value = current;
    return current == LocationPermission.whileInUse ||
        current == LocationPermission.always;
  }

  //* One-shot read. Use for things like "where am I right now to compute a
  //* route from" — for live tracking, use [start] and read [currentPosition].
  Future<Position?> getCurrent() async {
    if (!await ensurePermission()) return null;
    final pos = await Geolocator.getCurrentPosition();
    currentPosition.value = pos;
    return pos;
  }

  //* Start streaming the user's position. Safe to call repeatedly — no-ops if
  //* already streaming in the requested mode. Pass [background] = true during an
  //* Active delivery to keep updates flowing while the app is backgrounded
  //* (Android foreground service + persistent notification; iOS background
  //* location) so Live tracking doesn't go dark and the driver can't
  //* "disappear" mid-delivery. Idle-online stays foreground-only to save
  //* battery (per ADR-0002). Returns false when permission/services aren't
  //* granted.
  Future<bool> start({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 5,
    bool background = false,
  }) async {
    // Already streaming and no restart warranted → nothing to do. Only an
    // UPGRADE (foreground → background) restarts; a foreground `start()` that
    // fires while a background stream is live is NOT allowed to implicitly tear
    // the foreground-service down (see [shouldRestartStream]).
    if (_positionSub != null &&
        !shouldRestartStream(
          currentBackground: _backgroundMode,
          requestedBackground: background,
        )) {
      return true;
    }
    if (!await ensurePermission()) return false;

    // Mode changed (idle-online → active delivery, an UPGRADE): restart the
    // stream so the platform settings — foreground service / background
    // updates — match.
    await _positionSub?.cancel();
    _positionSub = null;
    _backgroundMode = background;

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: _locationSettings(
            accuracy,
            distanceFilterMeters,
            background,
          ),
        ).listen(
          (pos) => currentPosition.value = pos,
          onError: (_) => currentPosition.value = null,
        );
    _mode = background ? LocationMode.background : LocationMode.foreground;
    return true;
  }

  @override
  Future<void> applyMode(LocationMode mode) async {
    switch (mode) {
      case LocationMode.off:
        await stop();
      case LocationMode.foreground:
        if (_backgroundMode) await stop();
        await start();
      case LocationMode.background:
        await start(background: true);
    }
  }

  /// Platform-specific stream settings. In [background] mode the Android
  /// foreground-service notification + wake lock keep the process alive, and
  /// iOS background location updates are enabled with the blue status indicator.
  LocationSettings _locationSettings(
    LocationAccuracy accuracy,
    int distanceFilterMeters,
    bool background,
  ) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
        foregroundNotificationConfig: background
            ? const ForegroundNotificationConfig(
                notificationTitle: 'Livraison en cours',
                notificationText:
                    'Suivi de votre position pour la livraison en cours.',
                enableWakeLock: true,
                setOngoing: true,
                // Without this, geolocator defaults to `@mipmap/ic_launcher` —
                // the full-colour PNG, which Android alpha-masks to a white
                // square. `ic_stat_notification` is the monochrome silhouette
                // the FCM path already uses.
                notificationIcon: AndroidResource(
                  name: 'ic_stat_notification',
                  defType: 'drawable',
                ),
              )
            : null,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
        allowBackgroundLocationUpdates: background,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: background,
      );
    }
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    );
  }

  /// Pure transition rule for [start] when a stream is already running: should
  /// the live stream be torn down and restarted in the requested mode?
  ///
  /// Only an UPGRADE (foreground → background) restarts — an active delivery
  /// needs the foreground service / background updates. The reverse is never an
  /// implicit downgrade: an online-restore's foreground `start()` firing right
  /// after an active-delivery's background `start()` (the relaunch-mid-delivery
  /// path) must NOT tear the background service down. An explicit downgrade goes
  /// through [stop] then [start].
  static bool shouldRestartStream({
    required bool currentBackground,
    required bool requestedBackground,
  }) => requestedBackground && !currentBackground;

  Future<void> stop() async {
    // Reset the mode flags synchronously (before the async cancel) so a
    // [start] triggered right after — e.g. re-arming idle GPS the instant a
    // delivery clears — sees a clean, non-streaming state instead of racing the
    // in-flight cancel.
    final sub = _positionSub;
    _positionSub = null;
    _backgroundMode = false;
    _mode = LocationMode.off;
    await sub?.cancel();
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    super.onClose();
  }
}
