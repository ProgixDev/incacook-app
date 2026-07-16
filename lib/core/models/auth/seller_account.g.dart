// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerAccount _$SellerAccountFromJson(
  Map<String, dynamic> json,
) => _SellerAccount(
  category: $enumDecodeNullable(_$SellerCategoryEnumMap, json['category']),
  displayName: json['displayName'] as String?,
  bio: json['bio'] as String?,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  neighborhood: json['neighborhood'] as String?,
  deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toInt(),
  deliveryFeeCents: (json['deliveryFeeCents'] as num?)?.toInt(),
  prepMinMinutes: (json['prepMinMinutes'] as num?)?.toInt(),
  prepMaxMinutes: (json['prepMaxMinutes'] as num?)?.toInt(),
  hygieneCommitment: json['hygieneCommitment'] as bool?,
  faitMaisonCommitment: json['faitMaisonCommitment'] as bool?,
  business: json['business'] == null
      ? null
      : SellerBusinessRecord.fromJson(json['business'] as Map<String, dynamic>),
  cuisines:
      (json['cuisines'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CuisineTypeEnumMap, e))
          .toList() ??
      const <CuisineType>[],
  dishTypes:
      (json['dishTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DishTypeEnumMap, e))
          .toList() ??
      const <DishType>[],
  canList: json['canList'] as bool? ?? false,
  subscriptionStatus: json['subscriptionStatus'] as String? ?? 'NONE',
  subscriptionActive: json['subscriptionActive'] as bool? ?? false,
  subscriptionCurrentPeriodEnd: json['subscriptionCurrentPeriodEnd'] as String?,
  stripeOnboardingCompleted:
      json['stripeOnboardingCompleted'] as bool? ?? false,
  detailsSubmitted: json['detailsSubmitted'] as bool?,
  chargesEnabled: json['chargesEnabled'] as bool?,
  payoutsEnabled: json['payoutsEnabled'] as bool?,
);

Map<String, dynamic> _$SellerAccountToJson(
  _SellerAccount instance,
) => <String, dynamic>{
  'category': ?_$SellerCategoryEnumMap[instance.category],
  'displayName': ?instance.displayName,
  'bio': ?instance.bio,
  'profilePhotoUrl': ?instance.profilePhotoUrl,
  'dateOfBirth': ?instance.dateOfBirth,
  'neighborhood': ?instance.neighborhood,
  'deliveryRadiusKm': ?instance.deliveryRadiusKm,
  'deliveryFeeCents': ?instance.deliveryFeeCents,
  'prepMinMinutes': ?instance.prepMinMinutes,
  'prepMaxMinutes': ?instance.prepMaxMinutes,
  'hygieneCommitment': ?instance.hygieneCommitment,
  'faitMaisonCommitment': ?instance.faitMaisonCommitment,
  'business': ?instance.business?.toJson(),
  'cuisines': instance.cuisines.map((e) => _$CuisineTypeEnumMap[e]!).toList(),
  'dishTypes': instance.dishTypes.map((e) => _$DishTypeEnumMap[e]!).toList(),
  'canList': instance.canList,
  'subscriptionStatus': instance.subscriptionStatus,
  'subscriptionActive': instance.subscriptionActive,
  'subscriptionCurrentPeriodEnd': ?instance.subscriptionCurrentPeriodEnd,
  'stripeOnboardingCompleted': instance.stripeOnboardingCompleted,
  'detailsSubmitted': ?instance.detailsSubmitted,
  'chargesEnabled': ?instance.chargesEnabled,
  'payoutsEnabled': ?instance.payoutsEnabled,
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
  DishType.boisson: 'BOISSON',
};

_SellerBusinessRecord _$SellerBusinessRecordFromJson(
  Map<String, dynamic> json,
) => _SellerBusinessRecord(
  userId: json['userId'] as String,
  businessName: json['businessName'] as String,
  siret: json['siret'] as String,
  facadeUrl: json['facadeUrl'] as String?,
  legalForm: json['legalForm'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  openingHours:
      (json['openingHours'] as List<dynamic>?)
          ?.map((e) => OpeningHoursRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OpeningHoursRow>[],
);

Map<String, dynamic> _$SellerBusinessRecordToJson(
  _SellerBusinessRecord instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'businessName': instance.businessName,
  'siret': instance.siret,
  'facadeUrl': ?instance.facadeUrl,
  'legalForm': ?instance.legalForm,
  'createdAt': ?instance.createdAt,
  'updatedAt': ?instance.updatedAt,
  'openingHours': instance.openingHours.map((e) => e.toJson()).toList(),
};
