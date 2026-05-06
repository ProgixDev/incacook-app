import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/palette.dart';

class CustomTextFormFieldTheme {
  CustomTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    prefixIconColor: LightPalette.onSurfaceVariant,
    suffixIconColor: LightPalette.onSurfaceVariant,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: LightPalette.onSurface,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: LightPalette.onSurfaceVariant,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: LightPalette.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: LightPalette.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: LightPalette.onSurface),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: BrandColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 2, color: BrandColors.warning),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    prefixIconColor: DarkPalette.onSurfaceVariant,
    suffixIconColor: DarkPalette.onSurfaceVariant,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DarkPalette.onSurface,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DarkPalette.onSurfaceVariant,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: DarkPalette.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: DarkPalette.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: DarkPalette.onSurface),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 1, color: BrandColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(width: 2, color: BrandColors.warning),
    ),
  );
}
