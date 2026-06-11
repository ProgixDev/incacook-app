// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_listing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateListingRequest _$CreateListingRequestFromJson(
  Map<String, dynamic> json,
) => _CreateListingRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrls: (json['imageUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  priceCents: (json['priceCents'] as num).toInt(),
  originalPriceCents: (json['originalPriceCents'] as num?)?.toInt(),
  discountPercent: (json['discountPercent'] as num?)?.toInt(),
  portionsLeft: (json['portionsLeft'] as num?)?.toInt(),
  cuisineTypes:
      (json['cuisineTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CuisineTypeEnumMap, e))
          .toList() ??
      const <CuisineType>[],
  dishTypes:
      (json['dishTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DishTypeEnumMap, e))
          .toList() ??
      const <DishType>[],
  dietaryTags:
      (json['dietaryTags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
          .toList() ??
      const <DietaryTag>[],
  allergens:
      (json['allergens'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
          .toList() ??
      const <Allergen>[],
  otherAllergens: json['otherAllergens'] as String?,
  declaresNoAllergens: json['declaresNoAllergens'] as bool? ?? false,
  isAvailable: json['isAvailable'] as bool?,
  isVeg: json['isVeg'] as bool?,
  menuCategory: json['menuCategory'] as String?,
  fulfillment: $enumDecode(_$FulfillmentEnumMap, json['fulfillment']),
  prepMinutes: (json['prepMinutes'] as num).toInt(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  extras:
      (json['extras'] as List<dynamic>?)
          ?.map((e) => ListingExtraRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListingExtraRequest>[],
  termsAccepted: json['termsAccepted'] as bool? ?? false,
);

Map<String, dynamic> _$CreateListingRequestToJson(
  _CreateListingRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'imageUrls': instance.imageUrls,
  'priceCents': instance.priceCents,
  'originalPriceCents': ?instance.originalPriceCents,
  'discountPercent': ?instance.discountPercent,
  'portionsLeft': ?instance.portionsLeft,
  'cuisineTypes': instance.cuisineTypes
      .map((e) => _$CuisineTypeEnumMap[e]!)
      .toList(),
  'dishTypes': instance.dishTypes.map((e) => _$DishTypeEnumMap[e]!).toList(),
  'dietaryTags': instance.dietaryTags
      .map((e) => _$DietaryTagEnumMap[e]!)
      .toList(),
  'allergens': instance.allergens.map((e) => _$AllergenEnumMap[e]!).toList(),
  'otherAllergens': ?instance.otherAllergens,
  'declaresNoAllergens': instance.declaresNoAllergens,
  'isAvailable': ?instance.isAvailable,
  'isVeg': ?instance.isVeg,
  'menuCategory': ?instance.menuCategory,
  'fulfillment': _$FulfillmentEnumMap[instance.fulfillment]!,
  'prepMinutes': instance.prepMinutes,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'extras': instance.extras.map((e) => e.toJson()).toList(),
  'termsAccepted': instance.termsAccepted,
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

const _$DietaryTagEnumMap = {
  DietaryTag.halal: 'HALAL',
  DietaryTag.vegan: 'VEGAN',
  DietaryTag.glutenFree: 'GLUTEN_FREE',
  DietaryTag.casher: 'CASHER',
};

const _$AllergenEnumMap = {
  Allergen.gluten: 'GLUTEN',
  Allergen.crustaces: 'CRUSTACES',
  Allergen.oeufs: 'OEUFS',
  Allergen.poissons: 'POISSONS',
  Allergen.arachides: 'ARACHIDES',
  Allergen.soja: 'SOJA',
  Allergen.lait: 'LAIT',
  Allergen.fruitsACoque: 'FRUITS_A_COQUE',
  Allergen.celeri: 'CELERI',
  Allergen.moutarde: 'MOUTARDE',
  Allergen.sesame: 'SESAME',
  Allergen.sulfites: 'SULFITES',
  Allergen.lupin: 'LUPIN',
  Allergen.mollusques: 'MOLLUSQUES',
};

const _$FulfillmentEnumMap = {
  Fulfillment.delivery: 'DELIVERY',
  Fulfillment.pickup: 'PICKUP',
  Fulfillment.both: 'BOTH',
};
