// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodListing _$FoodListingFromJson(Map<String, dynamic> json) => _FoodListing(
  id: json['id'] as String,
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  sellerName: json['sellerName'] as String,
  category: $enumDecode(_$SellerCategoryEnumMap, json['category']),
  price: (json['price'] as num).toDouble(),
  portionsLeft: (json['portionsLeft'] as num).toInt(),
  fulfillment: $enumDecode(_$FulfillmentEnumMap, json['fulfillment']),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
  prepMinutes: (json['prepMinutes'] as num?)?.toInt(),
  isAvailable: json['isAvailable'] as bool? ?? true,
  isVeg: json['isVeg'] as bool? ?? false,
  menuCategory: json['menuCategory'] as String?,
  dietaryTags:
      (json['dietaryTags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
          .toList() ??
      const <DietaryTag>[],
  cuisineType: $enumDecodeNullable(_$CuisineTypeEnumMap, json['cuisineType']),
  dishType: $enumDecodeNullable(_$DishTypeEnumMap, json['dishType']),
  allergens:
      (json['allergens'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
          .toList() ??
      const <Allergen>[],
  otherAllergens: json['otherAllergens'] as String?,
);

Map<String, dynamic> _$FoodListingToJson(
  _FoodListing instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'sellerName': instance.sellerName,
  'category': _$SellerCategoryEnumMap[instance.category]!,
  'price': instance.price,
  'portionsLeft': instance.portionsLeft,
  'fulfillment': _$FulfillmentEnumMap[instance.fulfillment]!,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'distanceKm': instance.distanceKm,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'originalPrice': ?instance.originalPrice,
  'discountPercent': instance.discountPercent,
  'prepMinutes': ?instance.prepMinutes,
  'isAvailable': instance.isAvailable,
  'isVeg': instance.isVeg,
  'menuCategory': ?instance.menuCategory,
  'dietaryTags': instance.dietaryTags
      .map((e) => _$DietaryTagEnumMap[e]!)
      .toList(),
  'cuisineType': ?_$CuisineTypeEnumMap[instance.cuisineType],
  'dishType': ?_$DishTypeEnumMap[instance.dishType],
  'allergens': instance.allergens.map((e) => _$AllergenEnumMap[e]!).toList(),
  'otherAllergens': ?instance.otherAllergens,
};

const _$SellerCategoryEnumMap = {
  SellerCategory.faitMaison: 'FAIT_MAISON',
  SellerCategory.traiteur: 'TRAITEUR',
  SellerCategory.restaurant: 'RESTAURANT',
};

const _$FulfillmentEnumMap = {
  Fulfillment.delivery: 'DELIVERY',
  Fulfillment.pickup: 'PICKUP',
  Fulfillment.both: 'BOTH',
};

const _$DietaryTagEnumMap = {
  DietaryTag.halal: 'HALAL',
  DietaryTag.vegan: 'VEGAN',
  DietaryTag.glutenFree: 'GLUTEN_FREE',
  DietaryTag.casher: 'CASHER',
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
