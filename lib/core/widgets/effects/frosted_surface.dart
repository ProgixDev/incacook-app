import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';

/// Frosted-glass surface used across the app (search bar, filter button,
/// appbar buttons, cart badge, address tiles, settings cards…).
///
/// The blur strength is centralized here. The tint and border colors are
/// theme-driven — read from [AppColorExtensions.frostedTint] /
/// [ColorScheme.outlineVariant] so they swap automatically in dark mode.
/// Pass an explicit [tint] to override (e.g. selected pill states).
///
/// Use [shape: BoxShape.circle] for round buttons; otherwise provide
/// [borderRadius] for rounded rectangles.
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    required this.child,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.tint,
    this.border,
    this.padding,
  });

  final Widget child;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? tint;
  final BoxBorder? border;
  final EdgeInsets? padding;

  /// Centralized blur strength applied behind every frosted surface.
  /// Static (not theme-driven) since blur intensity doesn't vary by mode.
  static const double blurSigma = 14.0;

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    final colors = context.appColors;
    final effectiveTint = tint ?? colors.frostedTint;
    final effectiveBorder =
        border ??
        Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
            alpha: 0.45,
          ),
          width: 0.8,
        );

    final filtered = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveTint,
          shape: shape,
          borderRadius: isCircle ? null : borderRadius,
          border: effectiveBorder,
        ),
        child: child,
      ),
    );

    if (isCircle) return ClipOval(child: filtered);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: filtered,
    );
  }
}
