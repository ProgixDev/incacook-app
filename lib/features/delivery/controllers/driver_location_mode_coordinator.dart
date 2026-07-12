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

  Worker? _onlineWorker;
  Worker? _jobWorker;
  LocationMode? _requestedMode;
  LocationMode? _appliedMode;
  Completer<void>? _settling;

  Future<void> start() {
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

  void dispose() {
    _onlineWorker?.dispose();
    _jobWorker?.dispose();
    _onlineWorker = null;
    _jobWorker = null;
  }
}
