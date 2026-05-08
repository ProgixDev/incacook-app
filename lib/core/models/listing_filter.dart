import 'package:incacook/core/enums/food_enums.dart';

class ListingFilter {
  const ListingFilter({
    this.category,
    this.cuisines = const {},
    this.diets = const {},
    this.dishTypes = const {},
    this.allergensToExclude = const {},
    this.maxDistanceKm,
    this.inStockOnly = false,
  });

  final SellerCategory? category;
  final Set<CuisineType> cuisines;
  final Set<DietaryTag> diets;
  final Set<DishType> dishTypes;
  final Set<Allergen> allergensToExclude;
  final double? maxDistanceKm;
  final bool inStockOnly;

  static const double standardRadiusKm = 10.0;

  double get effectiveMaxRadiusKm =>
      maxDistanceKm ?? (category?.maxRadiusKm ?? standardRadiusKm);

  List<DishType> get applicableDishTypes =>
      category == null ? const [] : DishType.valuesFor(category!);

  bool get isEmpty =>
      category == null &&
      cuisines.isEmpty &&
      diets.isEmpty &&
      dishTypes.isEmpty &&
      allergensToExclude.isEmpty &&
      maxDistanceKm == null &&
      !inStockOnly;

  ListingFilter copyWith({
    SellerCategory? category,
    bool clearCategory = false,
    Set<CuisineType>? cuisines,
    Set<DietaryTag>? diets,
    Set<DishType>? dishTypes,
    Set<Allergen>? allergensToExclude,
    double? maxDistanceKm,
    bool clearMaxDistance = false,
    bool? inStockOnly,
  }) {
    return ListingFilter(
      category: clearCategory ? null : (category ?? this.category),
      cuisines: cuisines ?? this.cuisines,
      diets: diets ?? this.diets,
      dishTypes: dishTypes ?? this.dishTypes,
      allergensToExclude: allergensToExclude ?? this.allergensToExclude,
      maxDistanceKm:
          clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }
}
