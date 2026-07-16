import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/auth/opening_hours.dart';

part 'seller_account.freezed.dart';
part 'seller_account.g.dart';

/// The wizard-owned slice of a seller's account. Nested inside [User]
/// when `role == SELLER`. Distinct from
/// [SellerProfile] in `lib/core/models/seller_profile.dart`, which is
/// the buyer-facing read aggregate (stats / listings / reviews).
///
/// Mirrors the `PUT /v1/sellers/me/profile` (§3.14) and
/// `PUT /v1/sellers/me/business` (§3.15) response shapes — fields are
/// nullable / empty until the wizard fires those endpoints.
@freezed
abstract class SellerAccount with _$SellerAccount {
  const factory SellerAccount({
    SellerCategory? category,
    String? displayName,
    String? bio,
    String? profilePhotoUrl,
    String? dateOfBirth,
    String? neighborhood,
    int? deliveryRadiusKm,
    int? deliveryFeeCents,
    int? prepMinMinutes,
    int? prepMaxMinutes,
    bool? hygieneCommitment,
    bool? faitMaisonCommitment,

    // Business slice (§3.15) — null for fait-maison sellers.
    SellerBusinessRecord? business,

    // Cuisine slice (§3.16).
    @Default(<CuisineType>[]) List<CuisineType> cuisines,
    @Default(<DishType>[]) List<DishType> dishTypes,

    // Server-derived gate. True once profile + addresses + cuisines +
    // charter are complete AND `kycStatus == APPROVED`.
    @Default(false) bool canList,

    // Mandatory platform subscription ($4/mo). `subscriptionActive` is the
    // gate the app uses to unlock seller features; status + renewal date
    // drive the dashboard / paywall copy. Mirrors SellerProfileResponseDto.
    @Default('NONE') String subscriptionStatus,
    @Default(false) bool subscriptionActive,
    String? subscriptionCurrentPeriodEnd,

    // Stripe Connect payout gate. Mirrors SellerProfileResponseDto and is
    // refreshed by /v1/users/me after hosted onboarding returns to the app.
    @Default(false) bool stripeOnboardingCompleted,

    // Split Stripe Connect facts (DEC-4). Nullable so "old server didn't
    // send them" stays distinguishable from an explicit false — readiness
    // then falls back to [stripeOnboardingCompleted]. Derivation lives in
    // `payout_readiness.dart` ([SellerPayoutReadiness]).
    bool? detailsSubmitted,
    bool? chargesEnabled,
    bool? payoutsEnabled,
  }) = _SellerAccount;

  factory SellerAccount.fromJson(Map<String, dynamic> json) =>
      _$SellerAccountFromJson(json);
}

/// Mirrors the `SellerBusiness` response from §3.15. Opening hours are
/// returned alongside the business as a list, replaced atomically when
/// the wizard PUTs new hours.
@freezed
abstract class SellerBusinessRecord with _$SellerBusinessRecord {
  const factory SellerBusinessRecord({
    required String userId,
    required String businessName,
    required String siret,
    String? facadeUrl,
    String? legalForm,
    String? createdAt,
    String? updatedAt,
    @Default(<OpeningHoursRow>[]) List<OpeningHoursRow> openingHours,
  }) = _SellerBusinessRecord;

  factory SellerBusinessRecord.fromJson(Map<String, dynamic> json) =>
      _$SellerBusinessRecordFromJson(json);
}
