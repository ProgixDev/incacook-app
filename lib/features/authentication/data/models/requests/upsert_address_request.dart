import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/address_record.dart';

part 'upsert_address_request.freezed.dart';
part 'upsert_address_request.g.dart';

/// Body of `PUT /v1/users/me/addresses/:kind` (§3.12).
///
/// [lat]/[lng] are optional but strongly recommended — the seller pickup
/// case denormalizes them onto `SellerProfile.location` for radius
/// queries on the listing feed.
@freezed
abstract class UpsertAddressRequest with _$UpsertAddressRequest {
  const factory UpsertAddressRequest({
    required String fullAddress,
    required String city,
    required String postalCode,
    AddressType? type,
    String? customLabel,
    String? apartment,
    String? floor,
    String? digicode,
    String? deliveryNotes,
    double? lat,
    double? lng,
  }) = _UpsertAddressRequest;

  factory UpsertAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$UpsertAddressRequestFromJson(json);
}
