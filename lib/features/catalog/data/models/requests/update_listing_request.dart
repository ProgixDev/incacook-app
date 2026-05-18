import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/features/catalog/data/models/requests/listing_extra_request.dart';

part 'update_listing_request.freezed.dart';
part 'update_listing_request.g.dart';

/// Body of `PATCH /v1/listings/:id` — see `flutter-listings-api.md` §5.2.
///
/// All fields optional; only fields present in the wire payload are
/// applied to the listing (server merges `existing ⊕ dto`).
///
/// **[extras] is replace-all when present.** Sending `extras: [...]`
/// clears the existing add-ons and inserts the new array atomically.
/// Omit [extras] entirely to leave add-ons unchanged. Sending
/// `extras: []` (empty array) clears them all.
@freezed
abstract class UpdateListingRequest with _$UpdateListingRequest {
  const factory UpdateListingRequest({
    String? name,
    String? description,
    List<String>? imageUrls,
    int? priceCents,
    int? originalPriceCents,
    int? discountPercent,
    int? portionsLeft,
    List<CuisineType>? cuisineTypes,
    List<DishType>? dishTypes,
    List<DietaryTag>? dietaryTags,
    List<Allergen>? allergens,
    String? otherAllergens,
    bool? isAvailable,
    bool? isVeg,
    String? menuCategory,
    Fulfillment? fulfillment,
    int? prepMinutes,
    DateTime? expiresAt,
    List<ListingExtraRequest>? extras,
  }) = _UpdateListingRequest;

  factory UpdateListingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateListingRequestFromJson(json);
}
