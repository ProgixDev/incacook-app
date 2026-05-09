import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final radius = BorderRadius.circular(60);

    return GestureDetector(
      onTap: onTap,
      //* tween 0 → 1 on selection: lerps tint and text color so the card
      //* cross-fades into its selected state, matching the rest of the
      //* app's frosted-pill selection animation.
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
          final secondary = Color.lerp(
            scheme.onSurfaceVariant,
            colors.selectedOnSurface,
            t,
          )!;
          return FrostedSurface(
            borderRadius: radius,
            tint: bgTint,
            padding: const EdgeInsets.all(AppSizes.md - 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    (address.type ?? SavedAddressType.other).icon,
                    size: 20,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
                const Gap(AppSizes.md - 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        address.label,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                      ),
                      const Gap(2),
                      Text(
                        address.line1,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: secondary),
                      ),
                      Text(
                        address.line2,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: secondary),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSizes.sm),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSizes.sm - 2),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
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
