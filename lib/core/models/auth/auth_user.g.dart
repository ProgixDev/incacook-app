// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  emailConfirmedAt: json['email_confirmed_at'] as String?,
  phoneConfirmedAt: json['phone_confirmed_at'] as String?,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': ?instance.phone,
  'email_confirmed_at': ?instance.emailConfirmedAt,
  'phone_confirmed_at': ?instance.phoneConfirmedAt,
};
