import 'package:get/get.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/listing_filter.dart';
import 'package:incacook/features/client/domain/food_listing.dart';

class FilterController extends GetxController {
  static FilterController get instance => Get.isRegistered<FilterController>()
      ? Get.find<FilterController>()
      : Get.put(FilterController(), permanent: true);

  final Rx<ListingFilter> filter = const ListingFilter().obs;

  bool get isEmpty => filter.value.isEmpty;

  int get activeCount {
    final f = filter.value;
    var count = 0;
    if (f.category != null) count++;
    count += f.cuisines.length;
    count += f.diets.length;
    count += f.dishTypes.length;
    if (f.maxDistanceKm != null) count++;
    if (f.inStockOnly) count++;
    return count;
  }

  void setCategory(SellerCategory? category) {
    final f = filter.value;
    final validDishes = category == null
        ? <DishType>{}
        : f.dishTypes.where((d) => d.isAvailableFor(category)).toSet();
    final maxRadius = category?.maxRadiusKm ?? ListingFilter.standardRadiusKm;
    final clampedRadius =
        f.maxDistanceKm != null && f.maxDistanceKm! > maxRadius
        ? maxRadius
        : f.maxDistanceKm;
    filter.value = f.copyWith(
      category: category,
      clearCategory: category == null,
      dishTypes: validDishes,
      maxDistanceKm: clampedRadius,
      clearMaxDistance: clampedRadius == null,
    );
  }

  void toggleCuisine(CuisineType cuisine) {
    final next = Set<CuisineType>.from(filter.value.cuisines);
    next.contains(cuisine) ? next.remove(cuisine) : next.add(cuisine);
    filter.value = filter.value.copyWith(cuisines: next);
  }

  void toggleDiet(DietaryTag diet) {
    final next = Set<DietaryTag>.from(filter.value.diets);
    next.contains(diet) ? next.remove(diet) : next.add(diet);
    filter.value = filter.value.copyWith(diets: next);
  }

  void toggleDishType(DishType dish) {
    final next = Set<DishType>.from(filter.value.dishTypes);
    next.contains(dish) ? next.remove(dish) : next.add(dish);
    filter.value = filter.value.copyWith(dishTypes: next);
  }

  void setMaxDistance(double? km) {
    filter.value = filter.value.copyWith(
      maxDistanceKm: km,
      clearMaxDistance: km == null,
    );
  }

  void setInStockOnly(bool value) {
    filter.value = filter.value.copyWith(inStockOnly: value);
  }

  void reset() {
    filter.value = const ListingFilter();
  }

  /// Apply current filter to a listing collection.
  /// Cuisines/dish-types use OR semantics (any match). Diets use AND
  /// semantics — listings must carry every selected dietary tag, since
  /// dietary needs are restrictive.
  List<FoodListing> apply(List<FoodListing> source) {
    final f = filter.value;
    if (f.isEmpty) return source;
    return source.where((l) {
      if (f.category != null && l.category != f.category) return false;
      if (f.cuisines.isNotEmpty &&
          (l.cuisineType == null || !f.cuisines.contains(l.cuisineType))) {
        return false;
      }
      if (f.diets.isNotEmpty &&
          !f.diets.every((d) => l.dietaryTags.contains(d))) {
        return false;
      }
      if (f.dishTypes.isNotEmpty &&
          (l.dishType == null || !f.dishTypes.contains(l.dishType))) {
        return false;
      }
      if (f.maxDistanceKm != null && l.distanceKm > f.maxDistanceKm!) {
        return false;
      }
      if (f.inStockOnly && l.portionsLeft <= 0) return false;
      return true;
    }).toList();
  }
}
