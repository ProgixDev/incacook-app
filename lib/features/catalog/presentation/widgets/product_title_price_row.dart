import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/misc/price_display.dart';
import 'package:homemade/core/constants/sizes.dart';

class ProductTitlePriceRow extends StatelessWidget {
  const ProductTitlePriceRow({
    super.key,
    required this.titleLeading,
    required this.titleMid,
    required this.titleTrailing,
    required this.shortDescription,
    required this.price,
    required this.rating,
    required this.reviewsCount,
  });

  final String titleLeading;
  final String titleMid;
  final String titleTrailing;
  final String shortDescription;
  final String price;
  final double rating;
  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* title + short description
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$titleLeading ', style: base),
                    TextSpan(
                      text: '$titleMid ',
                      style: base?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: titleTrailing, style: base),
                  ],
                ),
              ),
              const Gap(AppSizes.xs),
              Text(
                shortDescription,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Gap(AppSizes.sm),

        //* price + rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PriceDisplay(price: double.parse(price)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.star1, size: 14, color: Color(0xFFFFC107)),
                const Gap(4),
                Text(
                  rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  '($reviewsCount+Review)',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
