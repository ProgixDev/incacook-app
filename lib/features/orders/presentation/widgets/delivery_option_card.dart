import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/images/responsive_image_asset.dart';

class DeliveryOptionCard extends StatelessWidget {
  const DeliveryOptionCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.subtitle,
    required this.tertiary,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.disabledMessage,
    this.tertiaryIsHighlight = false,
  });

  final String iconPath;
  final String label;
  final String subtitle;
  final String tertiary;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final String? disabledMessage;
  final bool tertiaryIsHighlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final selectedFg = colors.selectedOnSurface;
    final unselectedFg = scheme.onSurface;
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSizes.md - 2),
          decoration: BoxDecoration(
            color: selected ? colors.selectedSurface : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //* Fixed image size — small enough to fit two cards side by
              //* side on narrow phones (~111dp interior on a 320dp device),
              //* and predictable enough for IntrinsicHeight on the parent
              //* Row to equalise the two cards' heights.
              ResponsiveImageAsset(
                assetPath: iconPath,
                width: 96,
                height: 96,
              ),
              const Gap(AppSizes.md - 2),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? selectedFg : unselectedFg,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? selectedFg : unselectedFg,
                ),
              ),
              const Gap(2),
              Text(
                tertiary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tertiaryIsHighlight
                      ? const Color(0xFF2E7D32)
                      : selected
                      ? selectedFg
                      : unselectedFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (disabledMessage != null) ...[
                const Gap(4),
                Text(
                  disabledMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFC05D3B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
