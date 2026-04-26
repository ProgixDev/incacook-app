import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/home/domain/kitchen.dart';
import 'package:homemade/features/home/presentation/widget/favorite_button.dart';
import 'package:homemade/features/home/presentation/widget/kitchen_meta_item.dart';
import 'package:homemade/features/home/presentation/widget/kitchen_tag_chip.dart';
import 'package:homemade/features/home/presentation/widget/rating_badge.dart';

class KitchenCard extends StatelessWidget {
  const KitchenCard({
    super.key,
    required this.kitchen,
    required this.isSaved,
    this.onTap,
    this.onToggleSaved,
  });

  final Kitchen kitchen;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //* image + overlays
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(kitchen.imagePath, fit: BoxFit.cover),
                  Positioned(
                    top: AppSizes.md - 4,
                    left: AppSizes.md - 4,
                    child: RatingBadge(
                      rating: kitchen.rating,
                      reviewCount: kitchen.reviewCount,
                    ),
                  ),
                  Positioned(
                    top: AppSizes.md - 4,
                    right: AppSizes.md - 4,
                    child: FavoriteButton(
                      isSaved: isSaved,
                      onTap: onToggleSaved,
                    ),
                  ),
                ],
              ),
            ),

            //* body
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                kitchen.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (kitchen.isVerified) ...[
                              const Gap(6),
                              const Icon(
                                Iconsax.tick_circle5,
                                size: 16,
                                color: Color(0xFF2E7D32),
                              ),
                            ],
                          ],
                        ),
                        const Gap(AppSizes.sm),
                        Wrap(
                          spacing: AppSizes.sm + 2,
                          runSpacing: 4,
                          children: [
                            if (kitchen.hasFreeDelivery)
                              KitchenMetaItem(
                                icon: Iconsax.truck_fast,
                                label: AppTexts.kitchenFreeDelivery,
                              ),
                            KitchenMetaItem(
                              icon: Iconsax.clock,
                              label: kitchen.deliveryTime,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSizes.sm),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(kitchen.chefImagePath),
                  ),
                ],
              ),
            ),

            //* tags
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: kitchen.tags
                    .map((t) => KitchenTagChip(label: t))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
