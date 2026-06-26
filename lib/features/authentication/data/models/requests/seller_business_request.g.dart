// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_business_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerBusinessRequest _$SellerBusinessRequestFromJson(
  Map<String, dynamic> json,
) => _SellerBusinessRequest(
  businessName: json['businessName'] as String,
  siret: json['siret'] as String?,
  facadeUrl: json['facadeUrl'] as String?,
  legalForm: json['legalForm'] as String?,
  openingHours:
      (json['openingHours'] as List<dynamic>?)
          ?.map((e) => OpeningHoursRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OpeningHoursRow>[],
);

Map<String, dynamic> _$SellerBusinessRequestToJson(
  _SellerBusinessRequest instance,
) => <String, dynamic>{
  'businessName': instance.businessName,
  'siret': ?instance.siret,
  'facadeUrl': ?instance.facadeUrl,
  'legalForm': ?instance.legalForm,
  'openingHours': instance.openingHours.map((e) => e.toJson()).toList(),
};
