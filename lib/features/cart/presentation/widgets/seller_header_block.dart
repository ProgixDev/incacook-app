import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';

class SellerHeaderBlock extends StatelessWidget {
  const SellerHeaderBlock({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final metaStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.cartSellerLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSizes.sm),
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                listing.imagePath,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(AppSizes.md - 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.sellerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: Image.asset(
                          listing.category.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Gap(4),
                      Text(listing.category.label, style: metaStyle),
                      const Gap(6),
                      Text('·', style: metaStyle),
                      const Gap(6),
                      Text(
                        '${listing.distanceKm.toStringAsFixed(1)}km',
                        style: metaStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
