import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';

/// Sort options for the buyer feed — see `flutter-listings-api.md` §5.5.
///
/// Default is `distance` when buyer location is known, else `newest`.
/// Requesting `distance` without a buyer point silently falls back to
/// `newest` server-side.
enum ListingFeedSort {
  distance('distance'),
  newest('newest'),
  priceAsc('price_asc'),
  priceDesc('price_desc');

  const ListingFeedSort(this.wireValue);
  final String wireValue;
}

/// Query parameters for `GET /v1/listings` — the buyer feed.
///
/// Every field is optional; omit a field to disable that filter
/// dimension. An empty filter returns every visible listing
/// (`flutter-listings-api.md` §5.5: "Empty filter = all visible
/// listings").
///
/// Lists are serialized as CSV (`cuisineTypes=ORIENTALE,FRANCAISE`)
/// per the doc. Money is in cents.
class ListListingsQuery {
  const ListListingsQuery({
    this.category,
    this.cuisineTypes,
    this.dishTypes,
    this.fulfillment,
    this.dietary,
    this.avoidAllergens,
    this.isVeg,
    this.minPriceCents,
    this.maxPriceCents,
    this.maxDistanceKm,
    this.search,
    this.lat,
    this.lng,
    this.sort,
    this.limit,
    this.offset,
  });

  final SellerCategory? category;
  final List<CuisineType>? cuisineTypes;
  final List<DishType>? dishTypes;
  final Fulfillment? fulfillment;
  final List<DietaryTag>? dietary;
  final List<Allergen>? avoidAllergens;
  final bool? isVeg;
  final int? minPriceCents;
  final int? maxPriceCents;
  final double? maxDistanceKm;
  final String? search;
  final double? lat;
  final double? lng;
  final ListingFeedSort? sort;
  final int? limit;
  final int? offset;

  /// Maps to the `queryParameters` map Dio sends on the wire. Drops
  /// nulls and empty lists so the server treats them as "no filter on
  /// this dimension" per the doc.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = _enumWire(category!);
    if (cuisineTypes != null && cuisineTypes!.isNotEmpty) {
      params['cuisineTypes'] = cuisineTypes!.map(_enumWire).join(',');
    }
    if (dishTypes != null && dishTypes!.isNotEmpty) {
      params['dishTypes'] = dishTypes!.map(_enumWire).join(',');
    }
    if (fulfillment != null) params['fulfillment'] = _enumWire(fulfillment!);
    if (dietary != null && dietary!.isNotEmpty) {
      params['dietary'] = dietary!.map(_enumWire).join(',');
    }
    if (avoidAllergens != null && avoidAllergens!.isNotEmpty) {
      params['avoidAllergens'] = avoidAllergens!.map(_enumWire).join(',');
    }
    if (isVeg != null) params['isVeg'] = isVeg;
    if (minPriceCents != null) params['minPriceCents'] = minPriceCents;
    if (maxPriceCents != null) params['maxPriceCents'] = maxPriceCents;
    if (maxDistanceKm != null) {
      params['maxDistanceKm'] = maxDistanceKm!.toStringAsFixed(1);
    }
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (sort != null) params['sort'] = sort!.wireValue;
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    return params;
  }

  /// Reads the `@JsonValue` wire form off an enum value by walking the
  /// enum's declared name. Falls back to the Dart enum name if no
  /// `@JsonValue` annotation is present (handled by enum convention).
  static String _enumWire(Enum value) {
    //? Every enum used here declares an @JsonValue matching this
    //? upper-snake-case form (see `food_enums.dart` and
    //? `order_enums.dart`). Convert `cocktailDinatoire` → `COCKTAIL_DINATOIRE`
    //? for the wire.
    final raw = value.name;
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (i > 0 && ch == ch.toUpperCase() && ch != ch.toLowerCase()) {
        buf.write('_');
      }
      buf.write(ch.toUpperCase());
    }
    return buf.toString();
  }
}
