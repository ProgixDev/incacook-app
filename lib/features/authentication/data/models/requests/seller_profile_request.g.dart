// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerProfileRequest _$SellerProfileRequestFromJson(
  Map<String, dynamic> json,
) => _SellerProfileRequest(
  category: $enumDecode(_$SellerCategoryEnumMap, json['category']),
  displayName: json['display_name'] as String,
  bio: json['bio'] as String?,
  profilePhotoUrl: json['profile_photo_url'] as String,
  dateOfBirth: json['date_of_birth'] as String,
  neighborhood: json['neighborhood'] as String?,
  deliveryRadiusKm: (json['delivery_radius_km'] as num?)?.toInt(),
  deliveryFeeCents: (json['delivery_fee_cents'] as num?)?.toInt(),
  prepMinMinutes: (json['prep_min_minutes'] as num?)?.toInt(),
  prepMaxMinutes: (json['prep_max_minutes'] as num?)?.toInt(),
  hygieneCommitment: json['hygiene_commitment'] as bool?,
  faitMaisonCommitment: json['fait_maison_commitment'] as bool?,
);

Map<String, dynamic> _$SellerProfileRequestToJson(
  _SellerProfileRequest instance,
) => <String, dynamic>{
  'category': _$SellerCategoryEnumMap[instance.category]!,
  'display_name': instance.displayName,
  'bio': ?instance.bio,
  'profile_photo_url': instance.profilePhotoUrl,
  'date_of_birth': instance.dateOfBirth,
  'neighborhood': ?instance.neighborhood,
  'delivery_radius_km': ?instance.deliveryRadiusKm,
  'delivery_fee_cents': ?instance.deliveryFeeCents,
  'prep_min_minutes': ?instance.prepMinMinutes,
  'prep_max_minutes': ?instance.prepMaxMinutes,
  'hygiene_commitment': ?instance.hygieneCommitment,
  'fait_maison_commitment': ?instance.faitMaisonCommitment,
};

const _$SellerCategoryEnumMap = {
  SellerCategory.faitMaison: 'FAIT_MAISON',
  SellerCategory.traiteur: 'TRAITEUR',
  SellerCategory.restaurant: 'RESTAURANT',
};
