import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/seller_profile.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.reviews});

  final List<SellerReview> reviews;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
        const Gap(AppSizes.md),
        SizedBox(
          width: DeviceUtils.getScreenWidth(context),
          height: DeviceUtils.getScreenHeight(context) * 0.2,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => SizedBox(
              width: DeviceUtils.getScreenWidth(context) * 0.7,
              child: _ReviewCard(review: reviews[index]),
            ),
            separatorBuilder: (context, index) => const Gap(AppSizes.sm),
            itemCount: reviews.length,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SellerReview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatar = review.avatarUrl.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCircularImage(
                  image: avatar.isEmpty ? AppImages.profilePic : avatar,
                  size: 40,
                  isNetworkImage: avatar.startsWith('http'),
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(AppSizes.xs),
                      Text(
                        review.timeAgoLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSizes.sm),
                Row(
                  children: [
                    const Icon(Iconsax.star, size: 14, color: Colors.amber),
                    const Gap(4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(AppSizes.xs),
            Expanded(
              child: Text(
                review.body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
