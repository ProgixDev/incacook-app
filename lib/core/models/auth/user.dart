import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/buyer_account.dart';
import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/models/auth/seller_account.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// The IncaCook user aggregate, as returned by `POST /v1/users` (§3.3)
/// and `GET /v1/users/me` (§3.22).
///
/// Exactly one of [buyerAccount] / [sellerAccount] / [driverAccount] is
/// non-null at any time, matching [role]. The wire keys are
/// `buyerProfile` / `sellerProfile` / `driverProfile` — renamed here so
/// `SellerProfile` doesn't collide with the buyer-facing read aggregate
/// at `lib/core/models/seller_profile.dart`.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? phone,
    required UserRole role,
    required String firstName,
    required String lastName,
    String? avatarPath,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    String? createdAt,
    @JsonKey(name: 'buyerProfile') BuyerAccount? buyerAccount,
    @JsonKey(name: 'sellerProfile') SellerAccount? sellerAccount,
    @JsonKey(name: 'driverProfile') DriverAccount? driverAccount,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
