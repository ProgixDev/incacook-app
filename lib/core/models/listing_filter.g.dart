// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingFilter _$ListingFilterFromJson(Map<String, dynamic> json) =>
    _ListingFilter(
      category: $enumDecodeNullable(_$SellerCategoryEnumMap, json['category']),
      cuisines:
          (json['cuisines'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$CuisineTypeEnumMap, e))
              .toSet() ??
          const <CuisineType>{},
      diets:
          (json['diets'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
              .toSet() ??
          const <DietaryTag>{},
      dishTypes:
          (json['dishTypes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DishTypeEnumMap, e))
              .toSet() ??
          const <DishType>{},
      allergensToExclude:
          (json['allergensToExclude'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
              .toSet() ??
          const <Allergen>{},
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble(),
      inStockOnly: json['inStockOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$ListingFilterToJson(
  _ListingFilter instance,
) => <String, dynamic>{
  'category': ?_$SellerCategoryEnumMap[instance.category],
  'cuisines': instance.cuisines.map((e) => _$CuisineTypeEnumMap[e]!).toList(),
  'diets': instance.diets.map((e) => _$DietaryTagEnumMap[e]!).toList(),
  'dishTypes': instance.dishTypes.map((e) => _$DishTypeEnumMap[e]!).toList(),
  'allergensToExclude': instance.allergensToExclude
      .map((e) => _$AllergenEnumMap[e]!)
      .toList(),
  'maxDistanceKm': ?instance.maxDistanceKm,
  'inStockOnly': instance.inStockOnly,
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

const _$DietaryTagEnumMap = {
  DietaryTag.halal: 'HALAL',
  DietaryTag.vegan: 'VEGAN',
  DietaryTag.glutenFree: 'GLUTEN_FREE',
  DietaryTag.casher: 'CASHER',
};

const _$DishTypeEnumMap = {
  DishType.entree: 'ENTREE',
  DishType.plat: 'PLAT',
  DishType.dessert: 'DESSERT',
  DishType.cocktailDinatoire: 'COCKTAIL_DINATOIRE',
  DishType.boisson: 'BOISSON',
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
