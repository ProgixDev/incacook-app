import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/palette.dart';

class CustomAppBarTheme {
  CustomAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: LightPalette.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: LightPalette.onSurface, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: LightPalette.onSurface,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DarkPalette.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: DarkPalette.onSurface, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: DarkPalette.onSurface,
    ),
  );
}
