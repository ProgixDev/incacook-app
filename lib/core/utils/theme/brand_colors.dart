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

  //* IncaCook brand
  static const Color primary = Color(0xFF00C263); // vibrant green
  static const Color secondary = Color(0xFFC8553D); // terracotta accent

  //* semantic — success uses a deeper emerald so it stays distinct from
  //* the brand primary green ("brand green" vs "system success green").
  static const Color success = Color(0xFF0E8E4E);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
