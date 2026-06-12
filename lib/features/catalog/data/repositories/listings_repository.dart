import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/catalog/data/models/requests/create_listing_request.dart';
import 'package:incacook/features/catalog/data/models/requests/list_listings_query.dart';
import 'package:incacook/features/catalog/data/models/requests/update_listing_availability_request.dart';
import 'package:incacook/features/catalog/data/models/requests/update_listing_request.dart';

/// Repository for everything under `/v1/listings/*` and
/// `/v1/sellers/me/listings`.
///
/// All methods throw [ApiFailure] on non-2xx; callers branch on
/// `code` (`INCACOOK_PRICE_CAP_EXCEEDED`, `INCACOOK_FORBIDDEN`, etc.
/// — see `flutter-listings-api.md` §7).
class ListingsRepository extends GetxService {
  ListingsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static ListingsRepository get instance => Get.find();

  final ApiClient _api;

  // --- Buyer-feed cache ---------------------------------------------------
  // Keyed by the exact query (same filters + location → same key). Toggling
  // cuisine/category chips back and forth, or returning to a combo within the
  // TTL, is served from memory with no network call. Static so it survives
  // screen rebuilds and is shared across repo instances.
  static const Duration _feedTtl = Duration(minutes: 2);
  static final Map<String, _FeedCacheEntry> _feedCache = {};
  static final Map<String, Future<({List<Listing> items, Pagination? pagination})>>
      _feedInFlight = {};

  String _feedKey(ListListingsQuery query) {
    final params = query.toQueryParameters();
    final entries = params.entries.where((e) => e.value != null).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// Synchronous peek: returns a *fresh* cached feed for [query], or null.
  /// Lets the UI render instantly (no spinner / no fetch) on a cache hit.
  ({List<Listing> items, Pagination? pagination})? peekFeed(
    ListListingsQuery query,
  ) {
    final entry = _feedCache[_feedKey(query)];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt) >= _feedTtl) return null;
    return entry.result;
  }

  /// Drops all cached feed pages — call after an action that can change what
  /// the buyer feed returns (e.g. a seller publishing/editing a listing).
  static void invalidateFeedCache() {
    _feedCache.clear();
    _feedInFlight.clear();
  }

  /// `POST /v1/listings` (§5.1) — creates a listing. Seller resolved
  /// from JWT; KYC must be APPROVED.
  Future<Listing> create(CreateListingRequest req) async {
    final result = await _api.post<Listing>(
      '${ApiConstants.apiPrefix}/listings',
      body: req.toJson(),
      decoder: (json) => Listing.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `PATCH /v1/listings/:id` (§5.2) — partial update. Caller must own
  /// the listing; KYC must be APPROVED.
  ///
  /// Sending [UpdateListingRequest.extras] replaces the entire extras
  /// array; omitting it leaves them unchanged.
  Future<Listing> update(String id, UpdateListingRequest req) async {
    final result = await _api.patch<Listing>(
      '${ApiConstants.apiPrefix}/listings/$id',
      body: req.toJson(),
      decoder: (json) => Listing.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `DELETE /v1/listings/:id` (§5.3) — soft delete. Sets `deletedAt`
  /// and forces `isAvailable = false`; the row stays in the DB so
  /// existing orders can resolve the historical name + price.
  Future<void> delete(String id) async {
    await _api.delete<void>(
      '${ApiConstants.apiPrefix}/listings/$id',
      decoder: (_) {},
    );
  }

  /// `PATCH /v1/listings/:id/availability` (§5.4) — quick on/off
  /// toggle without re-sending the whole listing. Returns the full
  /// updated listing.
  Future<Listing> setAvailability(String id, {required bool isAvailable}) async {
    final req = UpdateListingAvailabilityRequest(isAvailable: isAvailable);
    final result = await _api.patch<Listing>(
      '${ApiConstants.apiPrefix}/listings/$id/availability',
      body: req.toJson(),
      decoder: (json) => Listing.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/listings` (§5.5) — paginated buyer feed.
  ///
  /// Empty [query] (or all-null fields) returns every visible listing.
  /// [Pagination.hasMore] in the returned tuple signals there's at
  /// least one more page; advance with `offset + limit`.
  ///
  /// Items returned here carry the buyer-feed-only fields
  /// (`sellerName`, `distanceKm`, `inRange`, `rating`, `reviewCount`)
  /// in addition to the standard [Listing] shape. `extras` is always
  /// empty on feed items — fetch detail via [getById] for the full
  /// add-on list.
  Future<({List<Listing> items, Pagination? pagination})> getFeed(
    ListListingsQuery query, {
    bool forceRefresh = false,
  }) async {
    final key = _feedKey(query);
    if (!forceRefresh) {
      final cached = peekFeed(query);
      if (cached != null) return cached;
      // Dedup: if an identical query is already in flight, await that one
      // instead of firing a second request.
      final pending = _feedInFlight[key];
      if (pending != null) return pending;
    }
    final future = _fetchAndCacheFeed(key, query);
    if (!forceRefresh) _feedInFlight[key] = future;
    return future;
  }

  Future<({List<Listing> items, Pagination? pagination})> _fetchAndCacheFeed(
    String key,
    ListListingsQuery query,
  ) async {
    try {
      final result = await _api.get<List<Listing>>(
        '${ApiConstants.apiPrefix}/listings',
        queryParameters: query.toQueryParameters(),
        decoder: (json) => (json! as List<dynamic>)
            .map((e) => Listing.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      final res = (items: result.data, pagination: result.pagination);
      _feedCache[key] = _FeedCacheEntry(res, DateTime.now());
      return res;
    } finally {
      _feedInFlight.remove(key);
    }
  }

  /// `GET /v1/listings/:id` (§5.6) — full listing detail including
  /// `extras`. Any authenticated user can fetch; soft-deleted listings
  /// return 404 (`INCACOOK_NOT_FOUND`).
  Future<Listing> getById(String id) async {
    final result = await _api.get<Listing>(
      '${ApiConstants.apiPrefix}/listings/$id',
      decoder: (json) => Listing.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/sellers/me/listings` (§5.7) — the authenticated seller's
  /// own listings, including `isAvailable = false` and expired entries
  /// that wouldn't appear in the buyer feed. Soft-deleted entries are
  /// excluded. Sorted by `createdAt` descending.
  ///
  /// Not paginated server-side today — if a seller hits high listing
  /// counts in practice we'll add pagination here.
  Future<List<Listing>> getMyListings() async {
    final result = await _api.get<List<Listing>>(
      '${ApiConstants.apiPrefix}/sellers/me/listings',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => Listing.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }
}

/// One cached buyer-feed page + when it was fetched (for TTL expiry).
class _FeedCacheEntry {
  _FeedCacheEntry(this.result, this.fetchedAt);

  final ({List<Listing> items, Pagination? pagination}) result;
  final DateTime fetchedAt;
}
