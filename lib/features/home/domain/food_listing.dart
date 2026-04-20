import 'package:flutter/material.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

enum SellerCategory {
  social(
    label: AppTexts.homeCategorySocial,
    imagePath: AppImages.individual,
  ),
  traiteur(
    label: AppTexts.homeCategoryTraiteur,
    imagePath: AppImages.bulk,
  ),
  restaurant(
    label: AppTexts.homeCategoryRestaurant,
    imagePath: AppImages.restaurants,
  );

  const SellerCategory({required this.label, required this.imagePath});

  final String label;
  final String imagePath;
}

enum DietaryTag {
  halal(label: AppTexts.dietaryHalal, color: Color(0xFF8E44AD)),
  vegan(label: AppTexts.dietaryVegan, color: Color(0xFF2E7D32)),
  glutenFree(label: AppTexts.dietaryGlutenFree, color: Color(0xFF1976D2)),
  spicy(label: AppTexts.dietarySpicy, color: Color(0xFFC62828));

  const DietaryTag({required this.label, required this.color});

  final String label;
  final Color color;
}

enum Fulfillment { delivery, pickup, both }

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
}
