import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';

enum SellerCategory {
  @JsonValue('FAIT_MAISON')
  faitMaison(
    label: AppTexts.homeCategorySocial,
    shortLabel: AppTexts.homeCategorySocialShort,
    imagePath: AppImages.homeMade,
    maxRadiusKm: 10.0,
  ),
  @JsonValue('TRAITEUR')
  traiteur(
    label: AppTexts.homeCategoryTraiteur,
    shortLabel: AppTexts.homeCategoryTraiteurShort,
    imagePath: AppImages.bulk,
    maxRadiusKm: 50.0,
  ),
  @JsonValue('RESTAURANT')
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
  @JsonValue('ORIENTALE')
  orientale(label: AppTexts.cuisineOrientale, iconPath: AppImages.eastern),
  @JsonValue('FRANCAISE')
  francaise(label: AppTexts.cuisineFrancaise, iconPath: AppImages.french),
  @JsonValue('AFRICAINE')
  africaine(label: AppTexts.cuisineAfricaine, iconPath: AppImages.african),
  @JsonValue('PORTUGAISE')
  portugaise(label: AppTexts.cuisinePortugaise, iconPath: AppImages.portuguese),
  @JsonValue('ITALIENNE')
  italienne(label: AppTexts.cuisineItalienne, iconPath: AppImages.italian),
  @JsonValue('ESPAGNOLE')
  espagnole(label: AppTexts.cuisineEspagnole, iconPath: AppImages.spanish),
  @JsonValue('LATINE')
  latine(label: AppTexts.cuisineLatine, iconPath: AppImages.latin);

  const CuisineType({required this.label, required this.iconPath});

  final String label;
  final String iconPath;
}

enum DietaryTag {
  @JsonValue('HALAL')
  halal(
    label: AppTexts.dietaryHalal,
    color: Color(0xFF8E44AD),
    iconPath: AppImages.halal,
  ),
  @JsonValue('VEGAN')
  vegan(
    label: AppTexts.dietaryVegan,
    color: Color(0xFF2E7D32),
    iconPath: AppImages.vegan,
  ),
  @JsonValue('GLUTEN_FREE')
  glutenFree(
    label: AppTexts.dietaryGlutenFree,
    color: Color(0xFF1976D2),
    iconPath: AppImages.glutenFree,
  ),
  @JsonValue('CASHER')
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
  @JsonValue('ENTREE')
  entree(
    label: AppTexts.dishStarter,
    iconPath: AppImages.appetizer,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  @JsonValue('PLAT')
  plat(
    label: AppTexts.dishMain,
    iconPath: AppImages.dish,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  @JsonValue('DESSERT')
  dessert(
    label: AppTexts.dishDessert,
    iconPath: AppImages.dessert,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
  ),
  @JsonValue('COCKTAIL_DINATOIRE')
  cocktailDinatoire(
    label: AppTexts.dishCocktail,
    iconPath: AppImages.cocktail,
    availableFor: {SellerCategory.traiteur},
  ),
  @JsonValue('BOISSON')
  boisson(
    label: AppTexts.dishDrink,
    iconPath: AppImages.cocktail,
    availableFor: {SellerCategory.traiteur, SellerCategory.restaurant},
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
  @JsonValue('GLUTEN')
  gluten(label: AppTexts.allergenGluten),
  @JsonValue('CRUSTACES')
  crustaces(label: AppTexts.allergenCrustaceans),
  @JsonValue('OEUFS')
  oeufs(label: AppTexts.allergenEggs),
  @JsonValue('POISSONS')
  poissons(label: AppTexts.allergenFish),
  @JsonValue('ARACHIDES')
  arachides(label: AppTexts.allergenPeanuts),
  @JsonValue('SOJA')
  soja(label: AppTexts.allergenSoy),
  @JsonValue('LAIT')
  lait(label: AppTexts.allergenMilk),
  @JsonValue('FRUITS_A_COQUE')
  fruitsACoque(label: AppTexts.allergenNuts),
  @JsonValue('CELERI')
  celeri(label: AppTexts.allergenCelery),
  @JsonValue('MOUTARDE')
  moutarde(label: AppTexts.allergenMustard),
  @JsonValue('SESAME')
  sesame(label: AppTexts.allergenSesame),
  @JsonValue('SULFITES')
  sulfites(label: AppTexts.allergenSulfites),
  @JsonValue('LUPIN')
  lupin(label: AppTexts.allergenLupin),
  @JsonValue('MOLLUSQUES')
  mollusques(label: AppTexts.allergenMolluscs);

  const Allergen({required this.label});

  final String label;
}
