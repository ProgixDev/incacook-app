import 'dart:async';

import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/listing_mappers.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/features/catalog/data/models/requests/list_listings_query.dart';
import 'package:incacook/features/catalog/data/repositories/listings_repository.dart';
import 'package:incacook/features/map/domain/map_entry.dart';
import 'package:incacook/features/map/presentation/widget/map_filter_bar.dart';

/// Owns map state for [MapScreen]: the real backend listings (pinned by
/// seller location), the selected filter, the tapped pin, and the projected
/// screen coords for every visible pin (recomputed on each camera change).
/// The screen reads these reactively via [Obx] and stays UI-only.
class MapController extends GetxController {
  static MapController get instance => Get.isRegistered<MapController>()
      ? Get.find<MapController>()
      : Get.put(MapController());

  /// Map centre / user dot. Defaults to central Paris until the device
  /// location resolves; updated to the real position in [loadListings].
  final Rx<Position> userLocation = Position(2.3522, 48.8566).obs;
  static const double initialZoom = 14;
  static const Duration urgentWindow = Duration(hours: 2, minutes: 30);

  /// Real listings from `GET /v1/listings`, one pin each (only listings whose
  /// seller has geocoded coordinates). Filter applied via [visibleEntries].
  final RxList<MapEntry> entries = <MapEntry>[].obs;
  final RxBool loading = true.obs;

  // ── Reactive UI state ─────────────────────────────────────────────────

  final Rx<MapFilter> selectedFilter = MapFilter.all.obs;
  final RxnString selectedId = RxnString();

  /// Screen-space coordinates for each entry in [visibleEntries], in order.
  /// Null when projection isn't ready or the point is off-screen.
  final RxList<ScreenCoordinate?> pinScreenCoords = <ScreenCoordinate?>[].obs;
  final Rxn<ScreenCoordinate> userScreenCoord = Rxn<ScreenCoordinate>();

  // ── Map handle + projection generation ────────────────────────────────

  MapboxMap? _map;

  //* Bumped on every projection request; results from stale generations are
  //* dropped to avoid jitter when many camera events fire in quick succession.
  int _projectionGen = 0;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadListings());
  }

  /// Resolves the device location (best-effort), fetches the real feed, and
  /// builds a pin per listing that has seller coordinates. Never throws —
  /// on any failure the map simply shows no pins.
  Future<void> loadListings() async {
    loading.value = true;
    double? lat;
    double? lng;
    try {
      final loc = Get.isRegistered<LocationService>()
          ? LocationService.instance
          : Get.put(LocationService(), permanent: true);
      final pos = await loc.getCurrent();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
        userLocation.value = Position(lng, lat);
      }
    } catch (_) {
      // keep the fallback centre — never crash on location.
    }

    try {
      final query = (lat != null && lng != null)
          ? ListListingsQuery(
              lat: lat,
              lng: lng,
              sort: ListingFeedSort.distance,
              limit: 100,
            )
          : const ListListingsQuery(limit: 100);
      final result = await ListingsRepository().getFeed(query);
      entries.assignAll([
        for (final l in result.items)
          if (l.lat != null && l.lng != null)
            MapEntry(
              position: Position(l.lng!, l.lat!),
              listing: l.toFoodListing(),
              source: l,
            ),
      ]);
    } catch (_) {
      entries.clear();
    } finally {
      loading.value = false;
      if (lat != null && lng != null) unawaited(centerOnUser());
      unawaited(refreshScreenCoords());
    }
  }

  // ── Derived data ──────────────────────────────────────────────────────

  bool isUrgent(MapEntry e) =>
      e.listing.expiresAt.difference(DateTime.now()) <= urgentWindow;

  bool _matchesFilter(MapEntry e, MapFilter filter) {
    switch (filter) {
      case MapFilter.all:
        return true;
      case MapFilter.social:
        return e.listing.category == SellerCategory.faitMaison;
      case MapFilter.traiteur:
        return e.listing.category == SellerCategory.traiteur;
      case MapFilter.restaurant:
        return e.listing.category == SellerCategory.restaurant;
      case MapFilter.urgent:
        return isUrgent(e);
    }
  }

  List<MapEntry> get visibleEntries =>
      entries.where((e) => _matchesFilter(e, selectedFilter.value)).toList();

  // ── Map lifecycle / camera ────────────────────────────────────────────

  Future<void> onMapCreated(MapboxMap map) async {
    _map = map;
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    //* hide the bottom-right "i" attribution button (Mapbox TOS still
    //* requires attribution somewhere — surface it elsewhere if needed).
    await map.attribution.updateSettings(AttributionSettings(enabled: false));
    await map.setBounds(CameraBoundsOptions(minZoom: 11.0, maxZoom: 18.0));
    await refreshScreenCoords();
  }

  void onCameraChange(CameraChangedEventData _) {
    unawaited(refreshScreenCoords());
  }

  Future<void> refreshScreenCoords() async {
    final map = _map;
    if (map == null) return;

    final gen = ++_projectionGen;
    final visible = visibleEntries;

    final pinPoints = visible
        .map((e) => Point(coordinates: e.position))
        .toList();
    final userPoint = Point(coordinates: userLocation.value);

    final results = await map.pixelsForCoordinates([...pinPoints, userPoint]);
    if (gen != _projectionGen) return;

    pinScreenCoords.assignAll(results.sublist(0, visible.length));
    userScreenCoord.value = results.last;
  }

  Future<void> centerOnUser() async {
    await _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: userLocation.value),
        zoom: initialZoom,
      ),
      MapAnimationOptions(duration: 600),
    );
  }

  Future<void> flyToCurrentZoom(Position pos) async {
    final map = _map;
    if (map == null) return;
    final state = await map.getCameraState();
    await map.flyTo(
      CameraOptions(
        center: Point(coordinates: pos),
        zoom: state.zoom,
      ),
      MapAnimationOptions(duration: 400),
    );
  }

  // ── User actions ──────────────────────────────────────────────────────

  void setFilter(MapFilter f) {
    selectedFilter.value = f;
    unawaited(refreshScreenCoords());
  }

  void setSelected(String? id) => selectedId.value = id;
}
