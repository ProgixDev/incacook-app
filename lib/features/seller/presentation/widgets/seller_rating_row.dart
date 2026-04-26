import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/seller/domain/seller_rating.dart';

/// Renders a single criterion: emoji + label + value on the top row,
/// a filled bar in the middle, and a small caption beneath.
class SellerRatingRow extends StatelessWidget {
  const SellerRatingRow({super.key, required this.rating});

  final SellerRating rating;

  @override
  Widget build(BuildContext context) {
    final accent = rating.criterion.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Gap(AppSizes.sm),
            Expanded(
              child: Text(
                rating.criterion.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              rating.formattedValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Gap(AppSizes.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: rating.fillRatio,
            minHeight: 8,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
        const Gap(AppSizes.xs + 2),
        Text(
          rating.subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
