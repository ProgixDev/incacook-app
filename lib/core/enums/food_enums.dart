import 'package:flutter/material.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';

enum SellerCategory {
  faitMaison(
    label: AppTexts.homeCategorySocial,
    shortLabel: AppTexts.homeCategorySocialShort,
    imagePath: AppImages.homeMade,
    maxRadiusKm: 10.0,
  ),
  traiteur(
    label: AppTexts.homeCategoryTraiteur,
    shortLabel: AppTexts.homeCategoryTraiteurShort,
    imagePath: AppImages.bulk,
    maxRadiusKm: 50.0,
  ),
  restaurant(
    label: AppTexts.homeCategoryRestaurant,
    shortLabel: AppTexts.homeCategoryRestaurantShort,
    imagePath: AppImages.restaurants,
    maxRadiusKm: 10.0,
  );

  const SellerCategory({
    required this.label,
    required this.shortLabel,
    required this.imagePath,
    required this.maxRadiusKm,
  });

  final String label;
  final String shortLabel;
  final String imagePath;
  final double maxRadiusKm;
}

enum CuisineType {
  orientale(label: AppTexts.cuisineOrientale, iconPath: AppImages.eastern),
  francaise(label: AppTexts.cuisineFrancaise, iconPath: AppImages.french),
  africaine(label: AppTexts.cuisineAfricaine, iconPath: AppImages.african),
  portugaise(label: AppTexts.cuisinePortugaise, iconPath: AppImages.portuguese),
  italienne(label: AppTexts.cuisineItalienne, iconPath: AppImages.italian),
  espagnole(label: AppTexts.cuisineEspagnole, iconPath: AppImages.spanish),
  latine(label: AppTexts.cuisineLatine, iconPath: AppImages.latin);

  const CuisineType({required this.label, required this.iconPath});

  final String label;
  final String iconPath;
}

enum DietaryTag {
  halal(
    label: AppTexts.dietaryHalal,
    color: Color(0xFF8E44AD),
    iconPath: AppImages.halal,
  ),
  vegan(
    label: AppTexts.dietaryVegan,
    color: Color(0xFF2E7D32),
    iconPath: AppImages.vegan,
  ),
  glutenFree(
    label: AppTexts.dietaryGlutenFree,
    color: Color(0xFF1976D2),
    iconPath: AppImages.glutenFree,
  ),
  casher(
    label: AppTexts.dietaryKosher,
    color: Color(0xFF6A1B9A),
    iconPath: AppImages.casher,
  );

  const DietaryTag({
    required this.label,
    required this.color,
    required this.iconPath,
  });

  final String label;
  final Color color;
  final String iconPath;
}

enum DishType {
  entree(
    label: AppTexts.dishStarter,
    iconPath: AppImages.appetizer,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  plat(
    label: AppTexts.dishMain,
    iconPath: AppImages.dish,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  dessert(
    label: AppTexts.dishDessert,
    iconPath: AppImages.dessert,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  cocktailDinatoire(
    label: AppTexts.dishCocktail,
    iconPath: AppImages.cocktail,
    availableFor: {SellerCategory.traiteur},
  );

  const DishType({
    required this.label,
    required this.iconPath,
    required this.availableFor,
  });

  final String label;
  final String iconPath;
  final Set<SellerCategory> availableFor;

  bool isAvailableFor(SellerCategory category) =>
      availableFor.contains(category);

  static List<DishType> valuesFor(SellerCategory category) =>
      DishType.values.where((d) => d.isAvailableFor(category)).toList();
}

/// The 14 EU-mandated allergen categories. Free-text "other" allergens
/// belong on the listing as `otherAllergens: String?`. An empty list means
/// the listing declares no allergens.
enum Allergen {
  gluten(label: AppTexts.allergenGluten),
  crustaces(label: AppTexts.allergenCrustaceans),
  oeufs(label: AppTexts.allergenEggs),
  poissons(label: AppTexts.allergenFish),
  arachides(label: AppTexts.allergenPeanuts),
  soja(label: AppTexts.allergenSoy),
  lait(label: AppTexts.allergenMilk),
  fruitsACoque(label: AppTexts.allergenNuts),
  celeri(label: AppTexts.allergenCelery),
  moutarde(label: AppTexts.allergenMustard),
  sesame(label: AppTexts.allergenSesame),
  sulfites(label: AppTexts.allergenSulfites),
  lupin(label: AppTexts.allergenLupin),
  mollusques(label: AppTexts.allergenMolluscs);

  const Allergen({required this.label});

  final String label;
}
