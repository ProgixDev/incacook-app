import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/opening_hours.dart';

part 'seller_business_request.freezed.dart';
part 'seller_business_request.g.dart';

/// Body of `PUT /v1/sellers/me/business` (§3.15). Fait-maison sellers
/// get 400 here — they don't have a storefront. [siret] is 14 digits,
/// Luhn-checked server-side; it is OPTIONAL (null) for Traiteur and required
/// only for Sauve Ton Panier (enforced server-side by category).
/// [facadeUrl] is a `/v1/uploads` path.
@freezed
abstract class SellerBusinessRequest with _$SellerBusinessRequest {
  const factory SellerBusinessRequest({
    required String businessName,
    String? siret,
    String? facadeUrl,
    String? legalForm,
    @Default(<OpeningHoursRow>[]) List<OpeningHoursRow> openingHours,
  }) = _SellerBusinessRequest;

  factory SellerBusinessRequest.fromJson(Map<String, dynamic> json) =>
      _$SellerBusinessRequestFromJson(json);
}
