import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/auth/address_record.dart';

part 'buyer_account.freezed.dart';
part 'buyer_account.g.dart';

/// The wizard-owned slice of a buyer's account. Nested inside [User] when
/// `role == BUYER`. Fields are nullable / empty until the relevant
/// per-concept PUT fires (§3.13 buyer preferences, §3.12 address).
@freezed
abstract class BuyerAccount with _$BuyerAccount {
  const factory BuyerAccount({
    AddressRecord? defaultAddress,
    @Default(<DietaryTag>[]) List<DietaryTag> dietaryTags,
    @Default(<Allergen>[]) List<Allergen> allergens,
  }) = _BuyerAccount;

  factory BuyerAccount.fromJson(Map<String, dynamic> json) =>
      _$BuyerAccountFromJson(json);
}
