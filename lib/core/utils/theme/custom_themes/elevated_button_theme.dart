import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/palette.dart';

class CustomElevatedButtonTheme {
  CustomElevatedButtonTheme._();

  //*light theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: LightPalette.surface, //? button text color
      backgroundColor: BrandColors.primary,
      disabledForegroundColor: LightPalette.onSurfaceVariant,
      disabledBackgroundColor: LightPalette.outline,
      side: const BorderSide(color: BrandColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: LightPalette.surface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );

  //*dark theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: DarkPalette.onSurface,
      backgroundColor: BrandColors.primary,
      disabledForegroundColor: DarkPalette.onSurfaceVariant,
      disabledBackgroundColor: DarkPalette.outline,
      side: const BorderSide(color: BrandColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: DarkPalette.onSurface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );
}
