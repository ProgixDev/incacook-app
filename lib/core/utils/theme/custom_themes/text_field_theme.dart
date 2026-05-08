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
    borderSide: const BorderSide(width: 0.5, color: BrandColors.primary),
  );

  //? Lock the content insets so they don't change when focus toggles
  //? between [InputBorder.none] (unfocused/error) and the outline-style
  //? [_focusedBorder]. Flutter picks different default insets per border
  //? *type*, which would otherwise pull the text leftward when the field
  //? loses focus.
  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding: _contentPadding,
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
    contentPadding: _contentPadding,
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
