// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_charter_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcceptCharterRequest _$AcceptCharterRequestFromJson(
  Map<String, dynamic> json,
) => _AcceptCharterRequest(
  charter: $enumDecode(_$CharterEnumMap, json['charter']),
  version: json['version'] as String,
);

Map<String, dynamic> _$AcceptCharterRequestToJson(
  _AcceptCharterRequest instance,
) => <String, dynamic>{
  'charter': _$CharterEnumMap[instance.charter]!,
  'version': instance.version,
};

const _$CharterEnumMap = {
  Charter.cgu: 'CGU',
  Charter.cgv: 'CGV',
  Charter.hygiene: 'HYGIENE',
  Charter.faitMaison: 'FAIT_MAISON',
  Charter.punctuality: 'PUNCTUALITY',
  Charter.care: 'CARE',
};
