import 'package:flutter/material.dart';

/// Colors that are part of the brand identity and stay identical in both
/// light and dark mode. Use these for logo accents, primary CTAs, and the
/// universal semantic palette (success / warning / error / info).
///
/// Mode-variant tokens (surfaces, text, borders) live in [LightPalette] /
/// [DarkPalette]. Project-specific tokens that don't fit Material's
/// [ColorScheme] live in [AppColorExtensions].
class BrandColors {
  BrandColors._();

  static const Color primary = Color(0xFF2E81E6);
  static const Color secondary = Color(0xFF072646);

  //* semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
