// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signin_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SigninRequest _$SigninRequestFromJson(Map<String, dynamic> json) =>
    _SigninRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SigninRequestToJson(_SigninRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};
