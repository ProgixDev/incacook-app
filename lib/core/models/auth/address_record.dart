import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_record.freezed.dart';
part 'address_record.g.dart';

/// Server-shape address as returned by `PUT /v1/users/me/addresses/:kind`
/// (§3.12) and nested inside [BuyerAccount.defaultAddress].
///
/// Distinct from the UI-side [Address] in `lib/core/models/address.dart`,
/// which uses `MapPoint coordinate` for map rendering. Map between
/// the two at the repository boundary — UI keeps using the existing
/// [Address] type for pickers, this DTO is for the wire.
@freezed
abstract class AddressRecord with _$AddressRecord {
  const factory AddressRecord({
    required String id,
    AddressType? type,
    String? customLabel,
    required String fullAddress,
    required String city,
    required String postalCode,
    String? apartment,
    String? floor,
    String? digicode,
    String? deliveryNotes,
    double? lat,
    double? lng,
  }) = _AddressRecord;

  factory AddressRecord.fromJson(Map<String, dynamic> json) =>
      _$AddressRecordFromJson(json);
}

/// The address-kind path segment used by §3.12. URL-encoded:
/// `/v1/users/me/addresses/buyer-delivery` (hyphenated, lowercase).
enum AddressKind {
  buyerDelivery('buyer-delivery'),
  sellerPickup('seller-pickup'),
  driverHome('driver-home');

  const AddressKind(this.wire);
  final String wire;
}

/// Saved-address category for buyer addresses.
enum AddressType {
  @JsonValue('HOME')
  home,
  @JsonValue('WORK')
  work,
  @JsonValue('OTHER')
  other,
}
