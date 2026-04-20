import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';

class UrgentFoodCard extends StatelessWidget {
  const UrgentFoodCard({super.key, required this.listing, this.onTap});

  final FoodListing listing;
  final VoidCallback? onTap;

  String _formatRemaining(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return '${AppTexts.urgentPrefix} 0${AppTexts.urgentMinSuffix}';
    final totalMinutes = diff.inMinutes;
    if (totalMinutes < 60) {
      return '${AppTexts.urgentPrefix} $totalMinutes${AppTexts.urgentMinSuffix}';
    }
    final hours = totalMinutes ~/ 60;
    return '${AppTexts.urgentPrefix} $hours${AppTexts.urgentHourSuffix}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* food photo
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(listing.imagePath, fit: BoxFit.cover),
            ),

            //* content
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${listing.price.toStringAsFixed(0)}€',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    _formatRemaining(listing.expiresAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
