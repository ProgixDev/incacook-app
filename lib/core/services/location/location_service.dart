import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.find();

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<LocationPermission> permission = LocationPermission.unableToDetermine
      .obs;

  /// Human-readable "City, Country" for the current location, reverse-geocoded
  /// by whoever resolves the position (e.g. the client home). Null until known
  /// — UI shows a fallback meanwhile.
  final Rxn<String> placeLabel = Rxn<String>();

  StreamSubscription<Position>? _positionSub;

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
    return Geolocator.getCurrentPosition();
  }

  //* Start streaming the user's position. Safe to call repeatedly — no-ops if
  //* already streaming. Returns false when permission/services aren't granted.
  Future<bool> start({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 5,
  }) async {
    if (_positionSub != null) return true;
    if (!await ensurePermission()) return false;

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            distanceFilter: distanceFilterMeters,
          ),
        ).listen(
          (pos) => currentPosition.value = pos,
          onError: (_) => currentPosition.value = null,
        );
    return true;
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    super.onClose();
  }
}
