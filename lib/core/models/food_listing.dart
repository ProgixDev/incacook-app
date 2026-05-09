import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';

/// A dish offered for sale. Shared by buyer-facing screens (feed, product
/// detail, cart) and seller-facing screens (dashboard product list).
///
/// Field groups:
/// - **Identity / catalog**: id, name, imageUrl, price, originalPrice,
///   menuCategory, dietary/cuisine/dish/allergen metadata
/// - **Inventory**: portionsLeft, expiresAt, isAvailable, prepMinutes,
///   discountPercent
/// - **Seller-attached**: sellerName, category (platform-level
///   classification: faitMaison / traiteur / restaurant)
/// - **Buyer-side aggregates** (denormalized for the feed; computed from
///   joins on the backend): distanceKm, rating, reviewCount
class FoodListing {
  const FoodListing({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sellerName,
    required this.category,
    required this.price,
    required this.portionsLeft,
    required this.fulfillment,
    required this.expiresAt,
    this.distanceKm = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.originalPrice,
    this.discountPercent = 0,
    this.prepMinutes,
    this.isAvailable = true,
    this.isVeg = false,
    this.menuCategory,
    this.dietaryTags = const [],
    this.cuisineType,
    this.dishType,
    this.allergens = const [],
    this.otherAllergens,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String sellerName;
  final SellerCategory category;
  final double price;
  final double? originalPrice;
  final int portionsLeft;
  final Fulfillment fulfillment;
  final DateTime expiresAt;

  /// Seller-defined sub-category (e.g. "Pizza mixte", "Plat du jour"). Free
  /// text. Independent of the platform-level [category].
  final String? menuCategory;
  final int? prepMinutes;
  final int discountPercent;
  final bool isAvailable;
  /// Vegetarian indicator. Distinct from [DietaryTag.vegan] (stricter):
  /// vegetarian listings can contain dairy/eggs.
  final bool isVeg;

  // Buyer-side aggregates — denormalized at fetch time.
  final double distanceKm;
  final double rating;
  final int reviewCount;

  final List<DietaryTag> dietaryTags;
  final CuisineType? cuisineType;
  final DishType? dishType;
  final List<Allergen> allergens;
  /// Free-text "other" allergens not covered by [Allergen]'s 14 EU-mandated
  /// categories. Null/empty when the seller has nothing to declare here.
  final String? otherAllergens;

  FoodListing copyWith({bool? isAvailable, int? portionsLeft}) {
    return FoodListing(
      id: id,
      name: name,
      imageUrl: imageUrl,
      sellerName: sellerName,
      category: category,
      price: price,
      portionsLeft: portionsLeft ?? this.portionsLeft,
      fulfillment: fulfillment,
      expiresAt: expiresAt,
      distanceKm: distanceKm,
      rating: rating,
      reviewCount: reviewCount,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      prepMinutes: prepMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      isVeg: isVeg,
      menuCategory: menuCategory,
      dietaryTags: dietaryTags,
      cuisineType: cuisineType,
      dishType: dishType,
      allergens: allergens,
      otherAllergens: otherAllergens,
    );
  }
}
