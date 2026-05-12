import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';

part 'buyer_preferences_request.freezed.dart';
part 'buyer_preferences_request.g.dart';

/// Body of `PUT /v1/buyers/me/preferences` (§3.13). Replaces both
/// arrays in a single call; either may be empty (the wizard step is
/// user-skippable).
@freezed
abstract class BuyerPreferencesRequest with _$BuyerPreferencesRequest {
  const factory BuyerPreferencesRequest({
    @Default(<DietaryTag>[]) List<DietaryTag> dietaryTags,
    @Default(<Allergen>[]) List<Allergen> allergens,
  }) = _BuyerPreferencesRequest;

  factory BuyerPreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$BuyerPreferencesRequestFromJson(json);
}
