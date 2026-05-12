// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverAccount _$DriverAccountFromJson(Map<String, dynamic> json) =>
    _DriverAccount(
      vehicleType: $enumDecodeNullable(
        _$DriverVehicleTypeEnumMap,
        json['vehicle_type'],
      ),
      dateOfBirth: json['date_of_birth'] as String?,
      zones:
          (json['zones'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      canDeliver: json['can_deliver'] as bool? ?? false,
    );

Map<String, dynamic> _$DriverAccountToJson(_DriverAccount instance) =>
    <String, dynamic>{
      'vehicle_type': ?_$DriverVehicleTypeEnumMap[instance.vehicleType],
      'date_of_birth': ?instance.dateOfBirth,
      'zones': instance.zones,
      'can_deliver': instance.canDeliver,
    };

const _$DriverVehicleTypeEnumMap = {
  DriverVehicleType.bicycle: 'BICYCLE',
  DriverVehicleType.scooter: 'SCOOTER',
  DriverVehicleType.car: 'CAR',
};
