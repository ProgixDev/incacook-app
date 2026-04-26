import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.selected,
    this.imagePath,
    this.icon,
    this.emoji,
    this.onTap,
  });

  final String label;
  final String? imagePath;
  final IconData? icon;
  final String? emoji;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        //* t == 0 → unselected look, t == 1 → selected. The tween rebuilds
        //* whenever [selected] flips and animates from the previous value.
        tween: Tween<double>(end: selected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final bgTint = Color.lerp(
            colors.frostedTint,
            colors.selectedSurface,
            t,
          );
          final contentColor = Color.lerp(
            scheme.onSurface,
            colors.selectedOnSurface,
            t,
          )!;
          final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: contentColor,
          );
          return FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            tint: bgTint,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(imagePath!, fit: BoxFit.contain),
                  ),
                  const Gap(AppSizes.sm),
                ] else if (icon != null) ...[
                  Icon(icon, size: 16, color: contentColor),
                  const Gap(AppSizes.sm - 2),
                ] else if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 16)),
                  const Gap(AppSizes.sm),
                ],
                Text(label, style: textStyle),
              ],
            ),
          );
        },
      ),
    );
  }
}
