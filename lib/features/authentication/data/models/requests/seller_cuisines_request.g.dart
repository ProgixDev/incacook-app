// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_cuisines_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SellerCuisinesRequest _$SellerCuisinesRequestFromJson(
  Map<String, dynamic> json,
) => _SellerCuisinesRequest(
  cuisines: (json['cuisines'] as List<dynamic>)
      .map((e) => $enumDecode(_$CuisineTypeEnumMap, e))
      .toList(),
  dishTypes: (json['dishTypes'] as List<dynamic>)
      .map((e) => $enumDecode(_$DishTypeEnumMap, e))
      .toList(),
);

Map<String, dynamic> _$SellerCuisinesRequestToJson(
  _SellerCuisinesRequest instance,
) => <String, dynamic>{
  'cuisines': instance.cuisines.map((e) => _$CuisineTypeEnumMap[e]!).toList(),
  'dishTypes': instance.dishTypes.map((e) => _$DishTypeEnumMap[e]!).toList(),
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
