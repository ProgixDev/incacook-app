// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_zones_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverZonesRequest _$DriverZonesRequestFromJson(Map<String, dynamic> json) =>
    _DriverZonesRequest(
      zones: (json['zones'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DriverZonesRequestToJson(_DriverZonesRequest instance) =>
    <String, dynamic>{'zones': instance.zones};
