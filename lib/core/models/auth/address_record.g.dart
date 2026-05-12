// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddressRecord _$AddressRecordFromJson(Map<String, dynamic> json) =>
    _AddressRecord(
      id: json['id'] as String,
      type: $enumDecodeNullable(_$AddressTypeEnumMap, json['type']),
      customLabel: json['custom_label'] as String?,
      fullAddress: json['full_address'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      apartment: json['apartment'] as String?,
      floor: json['floor'] as String?,
      digicode: json['digicode'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AddressRecordToJson(_AddressRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': ?_$AddressTypeEnumMap[instance.type],
      'custom_label': ?instance.customLabel,
      'full_address': instance.fullAddress,
      'city': instance.city,
      'postal_code': instance.postalCode,
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
