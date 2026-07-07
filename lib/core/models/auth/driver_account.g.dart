// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverAccount _$DriverAccountFromJson(Map<String, dynamic> json) =>
    _DriverAccount(
      vehicleType: $enumDecodeNullable(
        _$DriverVehicleTypeEnumMap,
        json['vehicleType'],
      ),
      dateOfBirth: json['dateOfBirth'] as String?,
      zones:
          (json['zones'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      canDeliver: json['canDeliver'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String? ?? 'PENDING',
      stripeOnboardingCompleted:
          json['stripeOnboardingCompleted'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$DriverAccountToJson(_DriverAccount instance) =>
    <String, dynamic>{
      'vehicleType': ?_$DriverVehicleTypeEnumMap[instance.vehicleType],
      'dateOfBirth': ?instance.dateOfBirth,
      'zones': instance.zones,
      'canDeliver': instance.canDeliver,
      'kycStatus': instance.kycStatus,
      'stripeOnboardingCompleted': instance.stripeOnboardingCompleted,
      'isOnline': instance.isOnline,
    };

const _$DriverVehicleTypeEnumMap = {
  DriverVehicleType.bicycle: 'BICYCLE',
  DriverVehicleType.scooter: 'SCOOTER',
  DriverVehicleType.car: 'CAR',
};
