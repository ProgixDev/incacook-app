import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.2),
      ),
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
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Row(
                  children: [
                    const Icon(Icons.mail, size: 14, color: AppColors.primary),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        'arselene.test@gmail.com',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
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
            icon: const Icon(
              Iconsax.edit_2,
              size: 20,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
