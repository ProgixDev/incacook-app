import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';

/// Buyer dietary preferences. Mirrors the home screen's [DietaryTag] set
/// (halal / vegan / sans gluten / casher) so a buyer's saved preferences
/// align 1:1 with the filter chips on the feed. Each value carries the
/// PNG asset path used by the home's category circles.
enum Dietary {
  halal(AppImages.halal, AppTexts.dietaryHalal),
  vegan(AppImages.vegan, AppTexts.dietaryVegan),
  glutenFree(AppImages.glutenFree, AppTexts.dietaryGlutenFree),
  casher(AppImages.casher, AppTexts.dietaryKosher);

  const Dietary(this.iconPath, this.label);

  final String iconPath;
  final String label;
}
