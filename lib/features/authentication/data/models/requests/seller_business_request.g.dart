// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_business_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerBusinessRequest _$SellerBusinessRequestFromJson(
  Map<String, dynamic> json,
) => _SellerBusinessRequest(
  businessName: json['business_name'] as String,
  siret: json['siret'] as String,
  facadeUrl: json['facade_url'] as String?,
  legalForm: json['legal_form'] as String?,
  openingHours:
      (json['opening_hours'] as List<dynamic>?)
          ?.map((e) => OpeningHoursRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OpeningHoursRow>[],
);

Map<String, dynamic> _$SellerBusinessRequestToJson(
  _SellerBusinessRequest instance,
) => <String, dynamic>{
  'business_name': instance.businessName,
  'siret': instance.siret,
  'facade_url': ?instance.facadeUrl,
  'legal_form': ?instance.legalForm,
  'opening_hours': instance.openingHours.map((e) => e.toJson()).toList(),
};
