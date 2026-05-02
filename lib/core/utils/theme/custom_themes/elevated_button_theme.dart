import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/palette.dart';

class CustomElevatedButtonTheme {
  CustomElevatedButtonTheme._();

  //? state-aware side: drop the border entirely when the button is
  //? disabled so it doesn't read as a brand-blue outline around a
  //? muted-grey fill.
  static final WidgetStateProperty<BorderSide?> _stateAwareSide =
      WidgetStateProperty.resolveWith<BorderSide?>(
        (states) => states.contains(WidgetState.disabled)
            ? BorderSide.none
            : const BorderSide(color: BrandColors.primary),
      );

  //*light theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: LightPalette.surface, //? button text color
      backgroundColor: BrandColors.primary,
      disabledForegroundColor: LightPalette.onSurfaceVariant,
      disabledBackgroundColor: LightPalette.outline,
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: LightPalette.surface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ).copyWith(side: _stateAwareSide),
  );

  //*dark theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: DarkPalette.onSurface,
      backgroundColor: BrandColors.primary,
      disabledForegroundColor: DarkPalette.onSurfaceVariant,
      disabledBackgroundColor: DarkPalette.outline,
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: DarkPalette.onSurface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ).copyWith(side: _stateAwareSide),
  );
}
