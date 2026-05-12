// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_vehicle_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverVehicleRequest _$DriverVehicleRequestFromJson(
  Map<String, dynamic> json,
) => _DriverVehicleRequest(
  vehicleType: $enumDecode(_$DriverVehicleTypeEnumMap, json['vehicle_type']),
  dateOfBirth: json['date_of_birth'] as String?,
);

Map<String, dynamic> _$DriverVehicleRequestToJson(
  _DriverVehicleRequest instance,
) => <String, dynamic>{
  'vehicle_type': _$DriverVehicleTypeEnumMap[instance.vehicleType]!,
  'date_of_birth': ?instance.dateOfBirth,
};

const _$DriverVehicleTypeEnumMap = {
  DriverVehicleType.bicycle: 'BICYCLE',
  DriverVehicleType.scooter: 'SCOOTER',
  DriverVehicleType.car: 'CAR',
};
