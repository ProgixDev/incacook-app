import 'package:flutter/material.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

enum SellerCategory {
  faitMaison(
    label: AppTexts.homeCategorySocial,
    imagePath: AppImages.homeMade,
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
