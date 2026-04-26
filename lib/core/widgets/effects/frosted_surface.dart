import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:homemade/core/constants/colors.dart';

/// Frosted-glass surface used across the home screen UI (search bar,
/// Filtres button, appbar buttons, cart badge…).
///
/// The blur strength and translucent tint live on this class — change them
/// here and every consumer updates in lockstep.
///
/// Pass [shape: BoxShape.circle] for round buttons; otherwise provide
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
  static const double blurSigma = 14.0;

  /// Default translucent tint painted over the blur — keeps icons/text legible.
  static const Color defaultTint = Color(0x66FEFEF3);

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    final effectiveTint = tint ?? defaultTint;
    final effectiveBorder =
        border ??
        Border.all(color: AppColors.white.withValues(alpha: 0.35), width: 0.8);

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
