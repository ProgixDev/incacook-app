import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/palette.dart';

class CustomOutlinedButtonTheme {
  CustomOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: LightPalette.onSurface,
      side: const BorderSide(color: BrandColors.primary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: LightPalette.onSurface,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: DarkPalette.onSurface,
      side: const BorderSide(color: BrandColors.primary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: DarkPalette.onSurface,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );
}
