// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_address_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpsertAddressRequest _$UpsertAddressRequestFromJson(
  Map<String, dynamic> json,
) => _UpsertAddressRequest(
  fullAddress: json['full_address'] as String,
  city: json['city'] as String,
  postalCode: json['postal_code'] as String,
  type: $enumDecodeNullable(_$AddressTypeEnumMap, json['type']),
  customLabel: json['custom_label'] as String?,
  apartment: json['apartment'] as String?,
  floor: json['floor'] as String?,
  digicode: json['digicode'] as String?,
  deliveryNotes: json['delivery_notes'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UpsertAddressRequestToJson(
  _UpsertAddressRequest instance,
) => <String, dynamic>{
  'full_address': instance.fullAddress,
  'city': instance.city,
  'postal_code': instance.postalCode,
  'type': ?_$AddressTypeEnumMap[instance.type],
  'custom_label': ?instance.customLabel,
  'apartment': ?instance.apartment,
  'floor': ?instance.floor,
  'digicode': ?instance.digicode,
  'delivery_notes': ?instance.deliveryNotes,
  'lat': ?instance.lat,
  'lng': ?instance.lng,
};

const _$AddressTypeEnumMap = {
  AddressType.home: 'HOME',
  AddressType.work: 'WORK',
  AddressType.other: 'OTHER',
};
