// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Zone _$ZoneFromJson(Map<String, dynamic> json) => _Zone(
  id: json['id'] as String,
  name: json['name'] as String,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  city: json['city'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ZoneToJson(_Zone instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayOrder': instance.displayOrder,
  'isActive': instance.isActive,
  'city': ?instance.city,
  'lat': ?instance.lat,
  'lng': ?instance.lng,
};
