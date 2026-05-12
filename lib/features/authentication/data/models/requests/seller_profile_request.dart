import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/enums/food_enums.dart';

part 'seller_profile_request.freezed.dart';
part 'seller_profile_request.g.dart';

/// Body of `PUT /v1/sellers/me/profile` (§3.14).
///
/// Setting [category] to FAIT_MAISON on the first PUT auto-flips
/// `kycStatus` from PENDING to APPROVED server-side. [profilePhotoUrl]
/// is the `path` returned by `POST /v1/uploads` (§3.19), not a raw URL.
@freezed
abstract class SellerProfileRequest with _$SellerProfileRequest {
  const factory SellerProfileRequest({
    required SellerCategory category,
    required String displayName,
    String? bio,
    required String profilePhotoUrl,
    required String dateOfBirth,  // YYYY-MM-DD
    String? neighborhood,
    int? deliveryRadiusKm,
    int? deliveryFeeCents,
    int? prepMinMinutes,
    int? prepMaxMinutes,
    bool? hygieneCommitment,
    bool? faitMaisonCommitment,
  }) = _SellerProfileRequest;

  factory SellerProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$SellerProfileRequestFromJson(json);
}
