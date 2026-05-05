import 'package:flutter/material.dart';

/// Project-specific colors that don't fit Material's [ColorScheme].
///
/// Carries:
/// - [frostedTint] — translucent layer painted over the blur in
///   `FrostedSurface` to keep contrast.
/// - [decorBlobTint] — fill color for the top-right decorative blob.
/// - [selectedSurface] / [selectedOnSurface] — solid fill + matching
///   foreground for "selected" pills/chips (filter button active state,
///   category pill selected, nav-menu selected item, etc.).
/// - [barrierOverlay] — modal sheet barrier color paired with
///   `showBlurredModalBottomSheet`. Dark mode wants a stronger overlay.
///
/// Read via the [BuildContext.appColors] extension below for ergonomic access.
@immutable
class AppColorExtensions extends ThemeExtension<AppColorExtensions> {
  const AppColorExtensions({
    required this.frostedTint,
    required this.decorBlobTint,
    required this.selectedSurface,
    required this.selectedOnSurface,
    required this.barrierOverlay,
  });

  final Color frostedTint;
  final Color decorBlobTint;
  final Color selectedSurface;
  final Color selectedOnSurface;
  final Color barrierOverlay;

  factory AppColorExtensions.light() => const AppColorExtensions(
    //? frostedTint: cream surface @ ~40% so frosted blur reads as
    //? "more cream" over varied content (decor blob, photos).
    frostedTint: Color(0x66FFF8F4),
    //? decorBlobTint: peach — harmonizes with cream base and green CTAs,
    //? carries warmth without competing with the brand green.
    decorBlobTint: Color(0xFF00C263),
    //? selectedSurface uses the dark logo-brown so "selected" pills are
    //? distinct from primary green CTAs and from terracotta secondary
    //? accents — three brand colors with three clear roles.
    selectedSurface: Color(0xFF00C263),
    selectedOnSurface: Color(0xFFFFF8F4),
    barrierOverlay: Color(0x2E000000),
  );

  factory AppColorExtensions.dark() => const AppColorExtensions(
    frostedTint: Color(0x66332A22),
    //? darker green so the brand reads as the same hue family as light
    //? mode without blasting saturated #00C263 against a dark backdrop.
    decorBlobTint: Color(0xFF0E8E4E),
    //? Inverted: cream "selected" pill on warm-dark surface.
    selectedSurface: Color(0xFFFFF0E0),
    selectedOnSurface: Color(0xFF0E8E4E),
    barrierOverlay: Color(0x4D000000),
  );

  @override
  AppColorExtensions copyWith({
    Color? frostedTint,
    Color? decorBlobTint,
    Color? selectedSurface,
    Color? selectedOnSurface,
    Color? barrierOverlay,
  }) {
    return AppColorExtensions(
      frostedTint: frostedTint ?? this.frostedTint,
      decorBlobTint: decorBlobTint ?? this.decorBlobTint,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      selectedOnSurface: selectedOnSurface ?? this.selectedOnSurface,
      barrierOverlay: barrierOverlay ?? this.barrierOverlay,
    );
  }

  @override
  AppColorExtensions lerp(
    covariant ThemeExtension<AppColorExtensions>? other,
    double t,
  ) {
    if (other is! AppColorExtensions) return this;
    return AppColorExtensions(
      frostedTint: Color.lerp(frostedTint, other.frostedTint, t)!,
      decorBlobTint: Color.lerp(decorBlobTint, other.decorBlobTint, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      selectedOnSurface: Color.lerp(
        selectedOnSurface,
        other.selectedOnSurface,
        t,
      )!,
      barrierOverlay: Color.lerp(barrierOverlay, other.barrierOverlay, t)!,
    );
  }
}

/// Ergonomic theme + extension access on [BuildContext].
///
/// - `context.appColors.frostedTint` instead of
///   `Theme.of(context).extension<AppColorExtensions>()!.frostedTint`.
/// - `context.isDark` replaces the scattered
///   `Theme.of(context).brightness == Brightness.dark` checks.
extension AppColorExtensionsX on BuildContext {
  AppColorExtensions get appColors =>
      Theme.of(this).extension<AppColorExtensions>() ??
      AppColorExtensions.light();

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
