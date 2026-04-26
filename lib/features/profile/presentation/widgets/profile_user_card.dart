import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.2),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          //* avatar
          CustomCircularImage(image: AppImages.profilePic, size: 64),
          const Gap(AppSizes.md),

          //* name + address
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.profileSampleName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Row(
                  children: [
                    Icon(Icons.mail, size: 14, color: scheme.primary),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        'arselene.test@gmail.com',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //* edit button
          IconButton(
            onPressed: onEdit,
            tooltip: AppTexts.profileEditAccount,
            icon: Icon(
              Iconsax.edit_2,
              size: 20,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
