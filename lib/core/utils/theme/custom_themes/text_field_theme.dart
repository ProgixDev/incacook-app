import 'package:flutter/material.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/utils/theme/palette.dart';

class CustomTextFormFieldTheme {
  CustomTextFormFieldTheme._();

  //? fields are visually framed by FrostedSurface — the InputDecorator stays
  //? borderless in resting/error states, and shows a brand-green pill border
  //? on focus to confirm input is captured.
  //? high radius keeps the focus outline pill-shaped regardless of the
  //? wrapping FrostedSurface's exact radius (32, 48, 999, …).
  static final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(999),
    borderSide: const BorderSide(width: 1.5, color: BrandColors.primary),
  );

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    prefixIconColor: BrandColors.primary,
    suffixIconColor: BrandColors.primary,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: LightPalette.onSurface,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: LightPalette.onSurfaceVariant,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: _focusedBorder,
    errorBorder: InputBorder.none,
    focusedErrorBorder: _focusedBorder,
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    prefixIconColor: BrandColors.primary,
    suffixIconColor: BrandColors.primary,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DarkPalette.onSurface,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DarkPalette.onSurfaceVariant,
    ),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: _focusedBorder,
    errorBorder: InputBorder.none,
    focusedErrorBorder: _focusedBorder,
  );
}
