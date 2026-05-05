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

  //* Cream-based surfaces — the IncaCook background lives here. Surface
  //* and background are intentionally identical so the page feels seamless;
  //* containerLow/High step warmer-darker for cards and chip tracks.
  static const Color background = Color(0xFFFFF8F4);
  static const Color surface = Color(0xFFFFF8F4);
  static const Color surfaceContainerLow = Color(0xFFF8EFE8);
  static const Color surfaceContainerHigh = Color(0xFFF0E5DC);

  //* Dark warm brown for text/icons — pulled directly from the IncaCook
  //* logo's "Inca" half so type and brand mark share the same dark tone.
  static const Color onSurface = Color(0xFF2B1713);
  static const Color onSurfaceVariant = Color(0xFF6B554B);

  static const Color outline = Color(0xFFC9B6A8);
  static const Color outlineVariant = Color(0xFFE5D6CB);
}

class DarkPalette {
  DarkPalette._();

  //* Warm dark — the inverse of the cream base. Pure neutral grey would
  //* read cold and clash with the warm cream/green palette in light mode.
  static const Color background = Color(0xFF1C1714);
  static const Color surface = Color(0xFF1C1714);
  static const Color surfaceContainerLow = Color(0xFF272019);
  static const Color surfaceContainerHigh = Color(0xFF332A22);

  static const Color onSurface = Color(0xFFFFF0E0);
  static const Color onSurfaceVariant = Color(0xFFB8A28F);

  static const Color outline = Color(0xFF5A4A3D);
  static const Color outlineVariant = Color(0xFF3F342B);
}
