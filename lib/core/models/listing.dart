import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/listing_extra.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// A dish offered for sale. Canonical shape returned by every listings
/// endpoint — see `flutter-listings-api.md` §4.
///
/// Money is in **cents** throughout (`priceCents`, `originalPriceCents`,
/// `priceDeltaCents` on [extras]). Convert at the edge — form inputs
/// parse euro decimals to cents on submit; display formatters render
/// cents back to euros.
///
/// Category-conditional fields:
/// - [portionsLeft] — non-null and `> 0` for fait_maison; null for
///   restaurant/traiteur means "cook to order".
/// - [expiresAt] — non-null and in the future for fait_maison; null for
///   restaurant/traiteur means "permanent menu item".
/// - [dishTypes] — empty for fait_maison; values from
///   [DishType.valuesFor] for restaurant/traiteur.
/// - [menuCategory] — restaurant/traiteur free-text sub-category;
///   ignored for fait_maison.
///
/// Buyer-feed-only fields ([sellerName], [distanceKm], [inRange],
/// [rating], [reviewCount]) are populated by `GET /v1/listings` but
/// absent from the detail and seller-dashboard responses. They're
/// nullable on the model so the same shape serves both reads.
@freezed
abstract class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String sellerId,
    required String name,
    String? description,
    @Default(<String>[]) List<String> imageUrls,

    required int priceCents,
    int? originalPriceCents,
    int? discountPercent,

    /// null = "cook to order" (restaurant/traiteur). Required + `> 0`
    /// for fait_maison.
    int? portionsLeft,

    @Default(<CuisineType>[]) List<CuisineType> cuisineTypes,
    @Default(<DishType>[]) List<DishType> dishTypes,
    @Default(<DietaryTag>[]) List<DietaryTag> dietaryTags,
    @Default(<Allergen>[]) List<Allergen> allergens,
    String? otherAllergens,

    @Default(true) bool isAvailable,
    @Default(false) bool isVeg,
    String? menuCategory,
    required SellerCategory category,

    required Fulfillment fulfillment,
    required int prepMinutes,

    /// null = permanent menu item (restaurant/traiteur). Required for
    /// fait_maison.
    DateTime? expiresAt,

    required DateTime createdAt,
    required DateTime updatedAt,

    /// Per-listing add-ons. Always empty on buyer-feed items — fetch
    /// detail via `GET /v1/listings/:id` to load the real extras.
    @Default(<ListingExtra>[]) List<ListingExtra> extras,

    //* Buyer-feed-only fields — present on items from `GET /v1/listings`,
    //* absent on the detail and seller-dashboard responses.
    String? sellerName,
    double? distanceKm,
    bool? inRange,
    double? rating,
    int? reviewCount,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}
