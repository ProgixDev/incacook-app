import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';

part 'seller_cuisines_request.freezed.dart';
part 'seller_cuisines_request.g.dart';

/// Body of `PUT /v1/sellers/me/cuisines` (§3.16). Replaces both sets in
/// a single transaction. Each array must have ≥1 element — empty
/// arrays return 400.
@freezed
abstract class SellerCuisinesRequest with _$SellerCuisinesRequest {
  const factory SellerCuisinesRequest({
    required List<CuisineType> cuisines,
    required List<DishType> dishTypes,
  }) = _SellerCuisinesRequest;

  factory SellerCuisinesRequest.fromJson(Map<String, dynamic> json) =>
      _$SellerCuisinesRequestFromJson(json);
}
