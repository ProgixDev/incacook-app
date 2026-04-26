import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/custom_themes/appbar_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:homemade/core/utils/theme/custom_themes/text_theme.dart';
import 'package:homemade/core/utils/theme/palette.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';

class CustomAppTheme {
  CustomAppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    scaffoldBackgroundColor: LightPalette.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: BrandColors.primary,
      secondary: BrandColors.secondary,
      surface: LightPalette.surface,
      surfaceContainerLow: LightPalette.surfaceContainerLow,
      surfaceContainerHigh: LightPalette.surfaceContainerHigh,
      onSurface: LightPalette.onSurface,
      onSurfaceVariant: LightPalette.onSurfaceVariant,
      outline: LightPalette.outline,
      outlineVariant: LightPalette.outlineVariant,
      error: BrandColors.error,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppColorExtensions.light(),
    ],
    appBarTheme: CustomAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: CustomBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: CustomCheckboxTheme.lightCheckboxTheme,
    chipTheme: CustomChipTheme.lightChipTheme,
    elevatedButtonTheme: CustomElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: CustomOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: CustomTextFormFieldTheme.lightInputDecorationTheme,
    textTheme: CustomTextTheme.lightTextTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DarkPalette.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: BrandColors.primary,
      secondary: BrandColors.secondary,
      surface: DarkPalette.surface,
      surfaceContainerLow: DarkPalette.surfaceContainerLow,
      surfaceContainerHigh: DarkPalette.surfaceContainerHigh,
      onSurface: DarkPalette.onSurface,
      onSurfaceVariant: DarkPalette.onSurfaceVariant,
      outline: DarkPalette.outline,
      outlineVariant: DarkPalette.outlineVariant,
      error: BrandColors.error,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppColorExtensions.dark(),
    ],
    appBarTheme: CustomAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: CustomBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: CustomCheckboxTheme.darkCheckboxTheme,
    chipTheme: CustomChipTheme.darkChipTheme,
    elevatedButtonTheme: CustomElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: CustomOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: CustomTextFormFieldTheme.darkInputDecorationTheme,
    textTheme: CustomTextTheme.darkTextTheme,
  );
}
