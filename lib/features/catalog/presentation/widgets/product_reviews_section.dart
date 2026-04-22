import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

class ProductReview {
  const ProductReview({
    required this.author,
    required this.avatarPath,
    required this.rating,
    required this.body,
    required this.time,
  });

  final String author;
  final String avatarPath;
  final double rating;
  final String body;
  final String time;
}

class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
    this.onSeeAll,
  });

  final double averageRating;
  final int totalReviews;
  final List<ProductReview> reviews;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          averageRating: averageRating,
          totalReviews: totalReviews,
          onSeeAll: onSeeAll,
        ),
        const Gap(AppSizes.md),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const Gap(AppSizes.md),
            itemBuilder: (context, index) =>
                _ReviewCard(review: reviews[index]),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.averageRating,
    required this.totalReviews,
    required this.onSeeAll,
  });

  final double averageRating;
  final int totalReviews;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.productReviewsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Row(
                children: [
                  const Icon(
                    Iconsax.star1,
                    color: Color(0xFFFFC107),
                    size: 14,
                  ),
                  const Gap(4),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    '${AppTexts.productReviewsBasedOn} $totalReviews ${AppTexts.productReviewsWordReviews}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                AppTexts.productReviewsSeeAll,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
              ),
              const Gap(2),
              const Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* header: avatar + name + time
          Row(
            children: [
              CustomCircularImage(
                image: review.avatarPath,
                size: 36,
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review.time,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSizes.sm),

          //* star row
          _StarRow(rating: review.rating),
          const Gap(AppSizes.sm),

          //* body
          Expanded(
            child: Text(
              review.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    const int total = 5;
    final filled = rating.round().clamp(0, total);

    return Row(
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isFilled ? Iconsax.star1 : Iconsax.star,
            size: 14,
            color: isFilled
                ? const Color(0xFFFFC107)
                : AppColors.grey.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
