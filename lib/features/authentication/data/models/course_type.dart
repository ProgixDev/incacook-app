import 'package:incacook/core/constants/image_strings.dart';

/// Dish-type course a seller can offer. Icons come from the home's
/// dish-type category set so the signup chips visually match the feed.
enum CourseType {
  entree(AppImages.appetizer, 'Entrée'),
  plat(AppImages.dish, 'Plat'),
  dessert(AppImages.dessert, 'Dessert'),
  cocktail(AppImages.cocktail, 'Cocktail dînatoire');

  const CourseType(this.iconPath, this.label);

  final String iconPath;
  final String label;
}
