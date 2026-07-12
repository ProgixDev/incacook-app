import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

/// Frosted role / vehicle / option card used by the welcome user-type
/// picker, the signup role page, and the driver vehicle page.
///
/// [media] is the visual element rendered above the title — a
/// [Lottie] for animated illustrations or an [Image] for PNG icons.
/// Selection swaps the soft frosted border for a primary-green ring
/// while keeping the same widget identity (so any animation in [media]
/// keeps playing through selection toggles).
class UserTypeCard extends StatelessWidget {
  const UserTypeCard({
    super.key,
    required this.media,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final Widget media;
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
              Expanded(child: media),
              const Gap(AppSizes.sm),
              // On very narrow cards (e.g. iPhone 7, where the role grid sizes
              // cards down) long labels like "Restaurateur / Cuisinier" used to
              // wrap mid-word and ellipsize. Scale the whole label down to fit
              // the card width instead so the role name always reads in full.
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              const Gap(AppSizes.xs),
            ],
          ),
        ),
      ),
    );
  }
}
