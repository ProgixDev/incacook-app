import 'package:flutter/material.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/text_strings.dart';

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
  orientale(label: AppTexts.cuisineOrientale),
  francaise(label: AppTexts.cuisineFrancaise),
  africaine(label: AppTexts.cuisineAfricaine),
  portugaise(label: AppTexts.cuisinePortugaise),
  italienne(label: AppTexts.cuisineItalienne),
  espagnole(label: AppTexts.cuisineEspagnole),
  latine(label: AppTexts.cuisineLatine);

  const CuisineType({required this.label});

  final String label;
}

enum DietaryTag {
  halal(label: AppTexts.dietaryHalal, color: Color(0xFF8E44AD)),
  vegetarien(label: AppTexts.dietaryVegetarian, color: Color(0xFF558B2F)),
  vegan(label: AppTexts.dietaryVegan, color: Color(0xFF2E7D32)),
  glutenFree(label: AppTexts.dietaryGlutenFree, color: Color(0xFF1976D2)),
  casher(label: AppTexts.dietaryKosher, color: Color(0xFF6A1B9A));

  const DietaryTag({required this.label, required this.color});

  final String label;
  final Color color;
}

enum DishType {
  entree(
    label: AppTexts.dishStarter,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  plat(
    label: AppTexts.dishMain,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  dessert(
    label: AppTexts.dishDessert,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  cocktailDinatoire(
    label: AppTexts.dishCocktail,
    availableFor: {SellerCategory.traiteur},
  );

  const DishType({required this.label, required this.availableFor});

  final String label;
  final Set<SellerCategory> availableFor;

  bool isAvailableFor(SellerCategory category) =>
      availableFor.contains(category);

  static List<DishType> valuesFor(SellerCategory category) =>
      DishType.values.where((d) => d.isAvailableFor(category)).toList();
}

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
  mollusques(label: AppTexts.allergenMolluscs),
  autres(label: AppTexts.allergenOther),
  aucun(label: AppTexts.allergenNone);

  const Allergen({required this.label});

  final String label;

  bool get isFreeText => this == Allergen.autres;
  bool get isExclusive => this == Allergen.aucun;
}
