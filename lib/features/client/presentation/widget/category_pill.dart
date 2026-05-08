import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

/// Horizontal capsule-shaped pill: icon + label, frosted by default and
/// cross-fades to the brand "selected" surface when tapped.
///
/// Used by the home screen's category hub and the map filter bar — every
/// horizontally-scrolling category chip in the app should look the same.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.iconPath,
    required this.selected,
    this.onTap,
  });

  final String label;
  final String iconPath;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      //* tween 0 → 1 on selection toggle; lerp the tint and text color so
      //* the pill cross-fades into its selected look instead of snapping.
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: selected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final bgTint = Color.lerp(
            colors.frostedTint,
            colors.selectedSurface,
            t,
          );
          final fg = Color.lerp(
            scheme.onSurface,
            colors.selectedOnSurface,
            t,
          )!;
          return FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            tint: bgTint,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const Gap(AppSizes.xs + 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
