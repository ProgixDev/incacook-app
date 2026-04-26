import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const Gap(AppSizes.md),
        SizedBox(
          width: DeviceUtils.getScreenWidth(context),
          height: DeviceUtils.getScreenHeight(context) * 0.2,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => Container(
              width: DeviceUtils.getScreenWidth(context) * 0.7,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCircularImage(
                        image: AppImages.profilePic,
                        size: 40,
                      ),
                      const Gap(AppSizes.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alice Johnson',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const Gap(AppSizes.xs),
                          Text(
                            '2 days ago',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Iconsax.star, size: 14, color: Colors.amber),
                          const Gap(4),
                          Text(
                            '5.0',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(AppSizes.xs),
                  Text(
                    'Great seller! The food was delicious and arrived on time. Highly recommend!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            separatorBuilder: (context, index) => const Gap(AppSizes.sm),
            itemCount: 3,
          ),
        ),
      ],
    );
  }
}
