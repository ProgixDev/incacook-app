import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/enums/food_enums.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/map/presentation/widget/map_pin.dart';

class MapListingSheet extends StatelessWidget {
  const MapListingSheet({
    super.key,
    required this.listing,
    required this.onViewDetail,
    required this.onOrder,
  });

  final FoodListing listing;
  final VoidCallback onViewDetail;
  final VoidCallback onOrder;

  String _expiryLabel() {
    final h = listing.expiresAt.hour.toString().padLeft(2, '0');
    final m = listing.expiresAt.minute.toString().padLeft(2, '0');
    return '${AppTexts.feedExpireAt} $h:$m';
  }

  String _portionsLabel() {
    final word = listing.portionsLeft == 1
        ? AppTexts.feedPortion
        : AppTexts.feedPortions;
    return '${listing.portionsLeft} $word';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* drag handle
              // Center(
              //   child: Container(
              //     width: 42,
              //     height: 4,
              //     decoration: BoxDecoration(
              //       color: AppColors.lightGrey,
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //   ),
              // ),
              const Gap(AppSizes.md),

              //* thumb + primary info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                    child: Image.asset(
                      listing.imagePath,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                        ),
                        const Gap(4),
                        _SellerLine(listing: listing),
                        const Gap(4),
                        _RatingLine(listing: listing),
                      ],
                    ),
                  ),
                ],
              ),

              //* dietary tags
              if (listing.dietaryTags.isNotEmpty) ...[
                const Gap(AppSizes.md),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: listing.dietaryTags
                      .map((tag) => _DietaryTagChip(tag: tag))
                      .toList(),
                ),
              ],

              //* portions + expiry
              const Gap(AppSizes.sm + 2),
              Row(
                children: [
                  Text(
                    _portionsLabel(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(AppSizes.sm),
                  Text(
                    '·',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  const Gap(AppSizes.sm),
                  const Icon(Iconsax.clock, size: 14, color: AppColors.grey),
                  const Gap(4),
                  Text(
                    _expiryLabel(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),

              //* price row
              const Gap(AppSizes.md),
              _PriceRow(
                price: listing.price,
                originalPrice: listing.originalPrice,
              ),

              //* CTAs
              const Gap(AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewDetail,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.lightGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: const Text(AppTexts.mapSheetDetailCta),
                    ),
                  ),
                  const Gap(AppSizes.sm + 2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: const Text(AppTexts.mapSheetOrderCta),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerLine extends StatelessWidget {
  const _SellerLine({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    return Row(
      children: [
        Flexible(
          child: Text(
            listing.sellerName,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Gap(6),
        Text('·', style: style),
        const Gap(6),
        Text(
          pinEmojiFor(listing.category),
          style: const TextStyle(fontSize: 12),
        ),
        const Gap(4),
        Text(listing.category.label, style: style),
      ],
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    return Row(
      children: [
        const Text('⭐', style: TextStyle(fontSize: 12)),
        const Gap(4),
        Text(
          listing.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(6),
        Text('·', style: subtle),
        const Gap(6),
        Text('${listing.distanceKm.toStringAsFixed(1)}km', style: subtle),
      ],
    );
  }
}

class _DietaryTagChip extends StatelessWidget {
  const _DietaryTagChip({required this.tag});

  final DietaryTag tag;

  String _emoji() {
    switch (tag) {
      case DietaryTag.halal:
        return '🟣';
      case DietaryTag.vegan:
        return '🌱';
      case DietaryTag.glutenFree:
        return '🔵';
      case DietaryTag.spicy:
        return '🌶️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji(), style: const TextStyle(fontSize: 12)),
          const Gap(4),
          Text(
            tag.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tag.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, this.originalPrice});

  final double price;
  final double? originalPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (originalPrice != null) ...[
          Text(
            '€${originalPrice!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.grey,
            ),
          ),
          const Gap(AppSizes.sm),
          const Icon(Iconsax.arrow_right_3, size: 14, color: AppColors.grey),
          const Gap(AppSizes.sm),
        ],
        Text(
          '€${price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}
