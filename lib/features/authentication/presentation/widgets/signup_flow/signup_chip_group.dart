import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

/// Multi- or single-select chip group for tag-style fields (cuisine
/// types, dietary preferences, allergens, etc.).
///
/// Each chip is a [FrostedSurface] pill — unselected reads as frosted
/// glass, selected cross-fades into [AppColorExtensions.selectedSurface]
/// using the same tween pattern as the home's category circles.
///
/// [leadingOf] is a generic widget-builder so callers can place an
/// `Image.asset` (PNG icon), an `Icon`, or any other small leading
/// glyph in front of the label. Returning null skips the leading slot.
class SignupChipGroup<T> extends StatelessWidget {
  const SignupChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
    this.leadingOf,
    this.singleSelect = false,
  });

  final List<T> options;
  final List<T> selected;
  final String Function(T) labelOf;
  final Widget? Function(T)? leadingOf;
  final ValueChanged<T> onToggle;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        final leading = leadingOf?.call(option);
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            // Tint cross-fades from the frosted glass tint to the brand
            // pill fill — same recipe as [_SubcategoryCircle] in the
            // home's category hub so the two surfaces feel related.
            final tint = Color.lerp(
              colors.frostedTint,
              colors.selectedSurface,
              t,
            );
            final borderColor = Color.lerp(
              scheme.outlineVariant.withValues(alpha: 0.45),
              colors.selectedSurface,
              t,
            )!;
            final textColor = Color.lerp(
              scheme.onSurface,
              colors.selectedOnSurface,
              t,
            )!;
            return GestureDetector(
              onTap: () => onToggle(option),
              behavior: HitTestBehavior.opaque,
              child: FrostedSurface(
                borderRadius: BorderRadius.circular(999),
                tint: tint,
                border: Border.all(color: borderColor, width: 1),
                child: SizedBox(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm + 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leading != null) ...[
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: leading,
                            ),
                          ),
                          const Gap(AppSizes.xs + 2),
                        ],
                        Text(
                          labelOf(option),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
