import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class UserTypeCard extends StatelessWidget {
  const UserTypeCard({
    super.key,
    required this.animation,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String animation;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final fg = selected ? colors.selectedOnSurface : scheme.onSurface;
    final radius = BorderRadius.circular(AppSizes.cardRadiusLg);

    return GestureDetector(
      onTap: onTap,
      child: FrostedSurface(
        borderRadius: radius,
        //* selected state: swap the soft frosted border for a primary-green
        //* ring so the chosen card pops without changing widget identity
        //* (keeps the Lottie animation playing through selection toggles).
        border: selected ? Border.all(color: scheme.primary, width: 1.5) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: selected ? colors.selectedSurface : Colors.transparent,
            borderRadius: radius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Lottie.asset(animation, fit: BoxFit.contain)),
              const Gap(AppSizes.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(AppSizes.xs),
            ],
          ),
        ),
      ),
    );
  }
}
