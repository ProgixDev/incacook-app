import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/core/enums/order_enums.dart';

class FoodListing {
  const FoodListing({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.sellerName,
    required this.category,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.portionsLeft,
    required this.fulfillment,
    required this.price,
    required this.expiresAt,
    this.originalPrice,
    this.dietaryTags = const [],
    this.cuisineType,
    this.dishType,
    this.allergens = const [],
  });

  final String id;
  final String name;
  final String imagePath;
  final String sellerName;
  final SellerCategory category;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final List<DietaryTag> dietaryTags;
  final int portionsLeft;
  final Fulfillment fulfillment;
  final double price;
  final double? originalPrice;
  final DateTime expiresAt;
  final CuisineType? cuisineType;
  final DishType? dishType;
  final List<Allergen> allergens;
}
