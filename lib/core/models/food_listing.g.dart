// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodListing _$FoodListingFromJson(Map<String, dynamic> json) => _FoodListing(
  id: json['id'] as String,
  name: json['name'] as String,
  imageUrl: json['image_url'] as String,
  sellerName: json['seller_name'] as String,
  category: $enumDecode(_$SellerCategoryEnumMap, json['category']),
  price: (json['price'] as num).toDouble(),
  portionsLeft: (json['portions_left'] as num).toInt(),
  fulfillment: $enumDecode(_$FulfillmentEnumMap, json['fulfillment']),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  originalPrice: (json['original_price'] as num?)?.toDouble(),
  discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
  prepMinutes: (json['prep_minutes'] as num?)?.toInt(),
  isAvailable: json['is_available'] as bool? ?? true,
  isVeg: json['is_veg'] as bool? ?? false,
  menuCategory: json['menu_category'] as String?,
  dietaryTags:
      (json['dietary_tags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
          .toList() ??
      const <DietaryTag>[],
  cuisineType: $enumDecodeNullable(_$CuisineTypeEnumMap, json['cuisine_type']),
  dishType: $enumDecodeNullable(_$DishTypeEnumMap, json['dish_type']),
  allergens:
      (json['allergens'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
          .toList() ??
      const <Allergen>[],
  otherAllergens: json['other_allergens'] as String?,
);

Map<String, dynamic> _$FoodListingToJson(
  _FoodListing instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image_url': instance.imageUrl,
  'seller_name': instance.sellerName,
  'category': _$SellerCategoryEnumMap[instance.category]!,
  'price': instance.price,
  'portions_left': instance.portionsLeft,
  'fulfillment': _$FulfillmentEnumMap[instance.fulfillment]!,
  'expires_at': instance.expiresAt.toIso8601String(),
  'distance_km': instance.distanceKm,
  'rating': instance.rating,
  'review_count': instance.reviewCount,
  'original_price': ?instance.originalPrice,
  'discount_percent': instance.discountPercent,
  'prep_minutes': ?instance.prepMinutes,
  'is_available': instance.isAvailable,
  'is_veg': instance.isVeg,
  'menu_category': ?instance.menuCategory,
  'dietary_tags': instance.dietaryTags
      .map((e) => _$DietaryTagEnumMap[e]!)
      .toList(),
  'cuisine_type': ?_$CuisineTypeEnumMap[instance.cuisineType],
  'dish_type': ?_$DishTypeEnumMap[instance.dishType],
  'allergens': instance.allergens.map((e) => _$AllergenEnumMap[e]!).toList(),
  'other_allergens': ?instance.otherAllergens,
};

const _$SellerCategoryEnumMap = {
  SellerCategory.faitMaison: 'FAIT_MAISON',
  SellerCategory.traiteur: 'TRAITEUR',
  SellerCategory.restaurant: 'RESTAURANT',
};

const _$FulfillmentEnumMap = {
  Fulfillment.delivery: 'delivery',
  Fulfillment.pickup: 'pickup',
  Fulfillment.both: 'both',
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
