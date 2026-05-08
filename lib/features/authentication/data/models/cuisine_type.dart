import 'package:incacook/core/constants/image_strings.dart';

/// Cuisine specialties a seller can declare. Each value carries the PNG
/// asset path used by the home's category-hub circles so the signup
/// chips render the same iconography as the feed filters.
enum CuisineType {
  orientale(AppImages.eastern, 'Orientale'),
  francaise(AppImages.french, 'Française'),
  africaine(AppImages.african, 'Africaine'),
  portugaise(AppImages.portuguese, 'Portugaise'),
  italienne(AppImages.italian, 'Italienne'),
  espagnole(AppImages.spanish, 'Espagnole'),
  latine(AppImages.latin, 'Latine');

  const CuisineType(this.iconPath, this.label);

  final String iconPath;
  final String label;
}
