// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  sellerId: json['sellerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
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
  isAvailable: json['isAvailable'] as bool? ?? true,
  isVeg: json['isVeg'] as bool? ?? false,
  menuCategory: json['menuCategory'] as String?,
  category: $enumDecode(_$SellerCategoryEnumMap, json['category']),
  fulfillment: $enumDecode(_$FulfillmentEnumMap, json['fulfillment']),
  prepMinutes: (json['prepMinutes'] as num).toInt(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  extras:
      (json['extras'] as List<dynamic>?)
          ?.map((e) => ListingExtra.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ListingExtra>[],
  sellerName: json['sellerName'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  inRange: json['inRange'] as bool?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'sellerId': instance.sellerId,
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
  'isAvailable': instance.isAvailable,
  'isVeg': instance.isVeg,
  'menuCategory': ?instance.menuCategory,
  'category': _$SellerCategoryEnumMap[instance.category]!,
  'fulfillment': _$FulfillmentEnumMap[instance.fulfillment]!,
  'prepMinutes': instance.prepMinutes,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'extras': instance.extras.map((e) => e.toJson()).toList(),
  'sellerName': ?instance.sellerName,
  'distanceKm': ?instance.distanceKm,
  'inRange': ?instance.inRange,
  'rating': ?instance.rating,
  'reviewCount': ?instance.reviewCount,
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
