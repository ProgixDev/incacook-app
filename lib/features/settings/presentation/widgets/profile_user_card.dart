import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    this.onEditProfile,
    this.onPreferences,
    this.onPayment,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onPreferences;
  final VoidCallback? onPayment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.5),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.lg,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //* avatar
          CustomCircularImage(image: AppImages.profilePic, size: 88),
          const Gap(AppSizes.md),

          //* name
          Text(
            AppTexts.profileSampleName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSizes.xs),

          //* email
          Text(
            'arselene.test@gmail.com',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSizes.lg),

          //* quick-action tiles
          Row(
            children: [
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.user_edit,
                  label: AppTexts.profileActionEditProfile,
                  onTap: onEditProfile,
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.heart,
                  label: AppTexts.profileActionPreferences,
                  onTap: onPreferences,
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.card,
                  label: AppTexts.profileActionPayment,
                  onTap: onPayment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.cardRadiusMd);

    return FrostedSurface(
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.md,
              horizontal: AppSizes.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: scheme.onSurface),
                const Gap(AppSizes.sm),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
