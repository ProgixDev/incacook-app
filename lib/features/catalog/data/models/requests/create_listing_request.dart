import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/features/catalog/data/models/requests/listing_extra_request.dart';

part 'create_listing_request.freezed.dart';
part 'create_listing_request.g.dart';

/// Body of `POST /v1/listings` — see `flutter-listings-api.md` §5.1.
///
/// `category` is **not** in this DTO: the server derives it from the
/// authenticated seller's profile. Same for `sellerId`.
///
/// Money is in cents — convert the form's euro decimal to cents at
/// submit time: `(double.parse(price) * 100).round()`.
///
/// Category-conditional required fields (server-enforced):
/// - fait_maison: [portionsLeft] required `> 0`; [expiresAt] required
///   and in the future; [dishTypes] must be empty.
/// - restaurant / traiteur: [portionsLeft] and [expiresAt] optional;
///   [dishTypes] must be a subset of [DishType.valuesFor].
@freezed
abstract class CreateListingRequest with _$CreateListingRequest {
  const factory CreateListingRequest({
    required String name,
    String? description,
    required List<String> imageUrls,
    required int priceCents,
    int? originalPriceCents,
    int? discountPercent,
    int? portionsLeft,
    @Default(<CuisineType>[]) List<CuisineType> cuisineTypes,
    @Default(<DishType>[]) List<DishType> dishTypes,
    @Default(<DietaryTag>[]) List<DietaryTag> dietaryTags,
    @Default(<Allergen>[]) List<Allergen> allergens,
    String? otherAllergens,
    bool? isAvailable,
    bool? isVeg,
    String? menuCategory,
    required Fulfillment fulfillment,
    required int prepMinutes,
    DateTime? expiresAt,
    @Default(<ListingExtraRequest>[]) List<ListingExtraRequest> extras,
  }) = _CreateListingRequest;

  factory CreateListingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateListingRequestFromJson(json);
}
