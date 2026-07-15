import 'dart:async';

import 'package:get/get.dart';

import 'package:incacook/core/services/location/location_service.dart';

/// Owns the driver's location mode by observing the two domain facts that
/// determine it: online availability and active-delivery ownership.
class DriverLocationModeCoordinator<T extends Object> {
  DriverLocationModeCoordinator({
    required this.online,
    required this.activeJob,
    required this.location,
    this.onError,
  });

  final RxBool online;
  final Rxn<T> activeJob;
  final LocationModeApplier location;
  final void Function(Object error)? onError;

  /// The coordinator that currently owns the shared [LocationService] mode.
  ///
  /// [location] is an app-permanent singleton, so ownership of it has to be
  /// arbitrated globally. Two coordinators overlap whenever the delivery screen
  /// is replaced while already mounted — `Get.offAll(DeliveryHomeScreen)` on a
  /// dispatch push does exactly that, and the incoming screen's [start] races
  /// the outgoing screen's [dispose]. Without this, a late-landing release from
  /// the dead coordinator would switch off the live one's tracking.
  static Object? _owner;

  Worker? _onlineWorker;
  Worker? _jobWorker;
  LocationMode? _requestedMode;
  LocationMode? _appliedMode;
  Completer<void>? _settling;

  Future<void> start() {
    _owner = this;
    _onlineWorker ??= ever<bool>(online, (_) => unawaited(_reconcile()));
    _jobWorker ??= ever<T?>(activeJob, (_) => unawaited(_reconcile()));
    return _reconcile();
  }

  Future<void> get settled => _settling?.future ?? Future<void>.value();

  Future<void> _reconcile() {
    _requestedMode = desiredLocationMode(
      online: online.value,
      hasActiveJob: activeJob.value != null,
    );
    final inFlight = _settling;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<void>();
    _settling = completer;
    unawaited(_drain(completer));
    return completer.future;
  }

  Future<void> _drain(Completer<void> completer) async {
    try {
      while (_requestedMode != null) {
        final next = _requestedMode!;
        _requestedMode = null;
        if (next == _appliedMode) continue;
        try {
          await location.applyMode(next);
          _appliedMode = next;
        } catch (error) {
          onError?.call(error);
        }
      }
      completer.complete();
    } finally {
      if (identical(_settling, completer)) _settling = null;
    }
  }

  /// Disposes the observers and releases the location mode.
  ///
  /// The applier ([LocationService]) is app-permanent, so it outlives this
  /// coordinator. Dropping the workers without switching off would orphan a
  /// running foreground service with nothing left to ever stop it — the
  /// "Livraison en cours" notification would then survive re-entering the app,
  /// since a warm resume never re-runs [start]. Re-entry rebuilds the
  /// coordinator and reconciles back to the right mode, so releasing here is
  /// safe.
  ///
  /// Skips the release when another coordinator has already claimed the mode
  /// (see [_owner]) — that one's state is the live one, and switching off
  /// underneath it would kill tracking mid-delivery. Best-effort: teardown must
  /// never throw at the caller.
  void dispose() {
    _onlineWorker?.dispose();
    _jobWorker?.dispose();
    _onlineWorker = null;
    _jobWorker = null;
    _requestedMode = null;
    _appliedMode = null;
    if (!identical(_owner, this)) return;
    _owner = null;
    unawaited(
      Future<void>.sync(() => location.applyMode(LocationMode.off)).catchError(
        (Object error) => onError?.call(error),
      ),
    );
  }
}
