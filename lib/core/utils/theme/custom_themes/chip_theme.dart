import 'package:flutter/material.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/utils/theme/palette.dart';

class CustomChipTheme {
  CustomChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: LightPalette.outline.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: LightPalette.onSurface),
    selectedColor: BrandColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: LightPalette.surface,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: DarkPalette.outline.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: DarkPalette.onSurface),
    selectedColor: BrandColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: DarkPalette.onSurface,
  );
}
