// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_preferences_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuyerPreferencesRequest _$BuyerPreferencesRequestFromJson(
  Map<String, dynamic> json,
) => _BuyerPreferencesRequest(
  dietaryTags:
      (json['dietary_tags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
          .toList() ??
      const <DietaryTag>[],
  allergens:
      (json['allergens'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
          .toList() ??
      const <Allergen>[],
);

Map<String, dynamic> _$BuyerPreferencesRequestToJson(
  _BuyerPreferencesRequest instance,
) => <String, dynamic>{
  'dietary_tags': instance.dietaryTags
      .map((e) => _$DietaryTagEnumMap[e]!)
      .toList(),
  'allergens': instance.allergens.map((e) => _$AllergenEnumMap[e]!).toList(),
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
