import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  String get _reviewsLabel {
    if (reviewCount >= 25) return '(${(reviewCount ~/ 25) * 25}+)';
    return '($reviewCount)';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(4),
          const Icon(Iconsax.star1, size: 12, color: Color(0xFFFFC107)),
          const Gap(4),
          Text(
            _reviewsLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
