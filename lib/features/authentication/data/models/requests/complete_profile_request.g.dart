// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompleteProfileRequest _$CompleteProfileRequestFromJson(
  Map<String, dynamic> json,
) => _CompleteProfileRequest(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  acceptedCgu: json['accepted_cgu'] as bool,
  acceptedCgv: json['accepted_cgv'] as bool,
);

Map<String, dynamic> _$CompleteProfileRequestToJson(
  _CompleteProfileRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'role': _$UserRoleEnumMap[instance.role]!,
  'accepted_cgu': instance.acceptedCgu,
  'accepted_cgv': instance.acceptedCgv,
};

const _$UserRoleEnumMap = {
  UserRole.buyer: 'BUYER',
  UserRole.seller: 'SELLER',
  UserRole.driver: 'DRIVER',
};
