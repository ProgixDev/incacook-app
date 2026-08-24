// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CharterAcceptance _$CharterAcceptanceFromJson(Map<String, dynamic> json) =>
    _CharterAcceptance(
      charter: $enumDecode(_$CharterEnumMap, json['charter']),
      version: json['version'] as String,
      acceptedAt: json['acceptedAt'] as String,
    );

Map<String, dynamic> _$CharterAcceptanceToJson(_CharterAcceptance instance) =>
    <String, dynamic>{
      'charter': _$CharterEnumMap[instance.charter]!,
      'version': instance.version,
      'acceptedAt': instance.acceptedAt,
    };

const _$CharterEnumMap = {
  Charter.cgu: 'CGU',
  Charter.cgv: 'CGV',
  Charter.hygiene: 'HYGIENE',
  Charter.faitMaison: 'FAIT_MAISON',
  Charter.punctuality: 'PUNCTUALITY',
  Charter.care: 'CARE',
  Charter.kycBiometric: 'KYC_BIOMETRIC',
};
