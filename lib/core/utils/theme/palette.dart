import 'package:flutter/material.dart';

/// Mode-variant raw color tokens. Both palettes expose the same field
/// names so callers can swap them based on `Theme.of(context).brightness`.
///
/// Usually you don't read these directly — the active values are surfaced
/// through `Theme.of(context).colorScheme`. Use these classes inside theme
/// configuration (e.g. building [ColorScheme] / [ThemeData]) where there
/// is no [BuildContext].

class LightPalette {
  LightPalette._();

  static const Color background = Color(0xFFF8E8D5);
  static const Color surface = Color(0xFFFEFEF3);
  static const Color surfaceContainerLow = Color(0xFFF4DCC2);
  static const Color surfaceContainerHigh = Color(0xFFFFFCF0);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF576062);
  static const Color outline = Color(0xFFCFC0AB);
  static const Color outlineVariant = Color(0xFFE5D6BF);
}

class DarkPalette {
  DarkPalette._();

  static const Color background = Color(0xFF1A1410);
  static const Color surface = Color(0xFF221A14);
  static const Color surfaceContainerLow = Color(0xFF2C231C);
  static const Color surfaceContainerHigh = Color(0xFF382D24);
  static const Color onSurface = Color(0xFFF4E8D8);
  static const Color onSurfaceVariant = Color(0xFFB8A990);
  static const Color outline = Color(0xFF4A3D32);
  static const Color outlineVariant = Color(0xFF38302A);
}
