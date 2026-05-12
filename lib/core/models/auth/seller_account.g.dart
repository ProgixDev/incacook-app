// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerAccount _$SellerAccountFromJson(Map<String, dynamic> json) =>
    _SellerAccount(
      category: $enumDecodeNullable(_$SellerCategoryEnumMap, json['category']),
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      neighborhood: json['neighborhood'] as String?,
      deliveryRadiusKm: (json['delivery_radius_km'] as num?)?.toInt(),
      deliveryFeeCents: (json['delivery_fee_cents'] as num?)?.toInt(),
      prepMinMinutes: (json['prep_min_minutes'] as num?)?.toInt(),
      prepMaxMinutes: (json['prep_max_minutes'] as num?)?.toInt(),
      hygieneCommitment: json['hygiene_commitment'] as bool?,
      faitMaisonCommitment: json['fait_maison_commitment'] as bool?,
      business: json['business'] == null
          ? null
          : SellerBusinessRecord.fromJson(
              json['business'] as Map<String, dynamic>,
            ),
      cuisines:
          (json['cuisines'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$CuisineTypeEnumMap, e))
              .toList() ??
          const <CuisineType>[],
      dishTypes:
          (json['dish_types'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DishTypeEnumMap, e))
              .toList() ??
          const <DishType>[],
      canList: json['can_list'] as bool? ?? false,
    );

Map<String, dynamic> _$SellerAccountToJson(
  _SellerAccount instance,
) => <String, dynamic>{
  'category': ?_$SellerCategoryEnumMap[instance.category],
  'display_name': ?instance.displayName,
  'bio': ?instance.bio,
  'profile_photo_url': ?instance.profilePhotoUrl,
  'date_of_birth': ?instance.dateOfBirth,
  'neighborhood': ?instance.neighborhood,
  'delivery_radius_km': ?instance.deliveryRadiusKm,
  'delivery_fee_cents': ?instance.deliveryFeeCents,
  'prep_min_minutes': ?instance.prepMinMinutes,
  'prep_max_minutes': ?instance.prepMaxMinutes,
  'hygiene_commitment': ?instance.hygieneCommitment,
  'fait_maison_commitment': ?instance.faitMaisonCommitment,
  'business': ?instance.business?.toJson(),
  'cuisines': instance.cuisines.map((e) => _$CuisineTypeEnumMap[e]!).toList(),
  'dish_types': instance.dishTypes.map((e) => _$DishTypeEnumMap[e]!).toList(),
  'can_list': instance.canList,
};

const _$SellerCategoryEnumMap = {
  SellerCategory.faitMaison: 'FAIT_MAISON',
  SellerCategory.traiteur: 'TRAITEUR',
  SellerCategory.restaurant: 'RESTAURANT',
};

const _$CuisineTypeEnumMap = {
  CuisineType.orientale: 'ORIENTALE',
  CuisineType.francaise: 'FRANCAISE',
  CuisineType.africaine: 'AFRICAINE',
  CuisineType.portugaise: 'PORTUGAISE',
  CuisineType.italienne: 'ITALIENNE',
  CuisineType.espagnole: 'ESPAGNOLE',
  CuisineType.latine: 'LATINE',
};

const _$DishTypeEnumMap = {
  DishType.entree: 'ENTREE',
  DishType.plat: 'PLAT',
  DishType.dessert: 'DESSERT',
  DishType.cocktailDinatoire: 'COCKTAIL_DINATOIRE',
};

_SellerBusinessRecord _$SellerBusinessRecordFromJson(
  Map<String, dynamic> json,
) => _SellerBusinessRecord(
  userId: json['user_id'] as String,
  businessName: json['business_name'] as String,
  siret: json['siret'] as String,
  facadeUrl: json['facade_url'] as String?,
  legalForm: json['legal_form'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  openingHours:
      (json['opening_hours'] as List<dynamic>?)
          ?.map((e) => OpeningHoursRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OpeningHoursRow>[],
);

Map<String, dynamic> _$SellerBusinessRecordToJson(
  _SellerBusinessRecord instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'business_name': instance.businessName,
  'siret': instance.siret,
  'facade_url': ?instance.facadeUrl,
  'legal_form': ?instance.legalForm,
  'created_at': ?instance.createdAt,
  'updated_at': ?instance.updatedAt,
  'opening_hours': instance.openingHours.map((e) => e.toJson()).toList(),
};
