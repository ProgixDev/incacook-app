import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';

class FeedFoodCard extends StatelessWidget {
  const FeedFoodCard({
    super.key,
    required this.listing,
    required this.isSaved,
    this.onTap,
    this.onToggleSaved,
  });

  final FoodListing listing;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onToggleSaved;

  String _formatExpiryTime(DateTime when) {
    final hh = when.hour.toString().padLeft(2, '0');
    final mm = when.minute.toString().padLeft(2, '0');
    return '${AppTexts.feedExpireAt} $hh:$mm';
  }

  String _portionsLabel() {
    final word = listing.portionsLeft == 1
        ? AppTexts.feedPortion
        : AppTexts.feedPortions;
    return '${listing.portionsLeft} $word';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(
              listing: listing,
              isSaved: isSaved,
              expiryLabel: _formatExpiryTime(listing.expiresAt),
              onToggleSaved: onToggleSaved,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* dish name
                  Text(
                    listing.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const Gap(6),

                  //* seller · category · distance
                  _SellerLine(listing: listing),
                  const Gap(AppSizes.sm),

                  //* rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        size: 16,
                        color: Color(0xFFFFC107),
                      ),
                      const Gap(4),
                      Text(
                        listing.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '(${listing.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),

                  //* dietary tags
                  if (listing.dietaryTags.isNotEmpty) ...[
                    const Gap(AppSizes.sm + 2),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: listing.dietaryTags
                          .map((tag) => _DietaryTagChip(tag: tag))
                          .toList(),
                    ),
                  ],
                  const Gap(AppSizes.md - 2),

                  //* portions + fulfillment
                  Row(
                    children: [
                      Text(
                        _portionsLabel(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(AppSizes.sm),
                      const Text(
                        '·',
                        style: TextStyle(color: AppColors.grey),
                      ),
                      const Gap(AppSizes.sm),
                      _FulfillmentBadge(fulfillment: listing.fulfillment),
                    ],
                  ),
                  const Gap(AppSizes.md - 2),

                  //* price row
                  _PriceRow(
                    price: listing.price,
                    originalPrice: listing.originalPrice,
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

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.listing,
    required this.isSaved,
    required this.expiryLabel,
    this.onToggleSaved,
  });

  final FoodListing listing;
  final bool isSaved;
  final String expiryLabel;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(listing.imagePath, fit: BoxFit.cover),

          //* save (heart) icon
          Positioned(
            top: AppSizes.sm + 2,
            right: AppSizes.sm + 2,
            child: GestureDetector(
              onTap: onToggleSaved,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isSaved ? Iconsax.heart5 : Iconsax.heart,
                  size: 20,
                  color: isSaved ? const Color(0xFFE53935) : AppColors.secondary,
                ),
              ),
            ),
          ),

          //* expiry badge
          Positioned(
            left: AppSizes.sm + 2,
            bottom: AppSizes.sm + 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm + 2,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.clock,
                    size: 12,
                    color: AppColors.white,
                  ),
                  const Gap(6),
                  Text(
                    expiryLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerLine extends StatelessWidget {
  const _SellerLine({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    return Row(
      children: [
        Flexible(
          child: Text(
            listing.sellerName,
            overflow: TextOverflow.ellipsis,
            style: subtle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Gap(6),
        Text('·', style: subtle),
        const Gap(6),
        SizedBox(
          width: 14,
          height: 14,
          child: Image.asset(listing.category.imagePath, fit: BoxFit.contain),
        ),
        const Gap(4),
        Text(listing.category.label, style: subtle),
        const Gap(6),
        Text('·', style: subtle),
        const Gap(6),
        Text(
          '${listing.distanceKm.toStringAsFixed(1)}km',
          style: subtle,
        ),
      ],
    );
  }
}

class _DietaryTagChip extends StatelessWidget {
  const _DietaryTagChip({required this.tag});

  final DietaryTag tag;

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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle),
          ),
          const Gap(6),
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

class _FulfillmentBadge extends StatelessWidget {
  const _FulfillmentBadge({required this.fulfillment});

  final Fulfillment fulfillment;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    final widgets = <Widget>[];
    if (fulfillment == Fulfillment.delivery || fulfillment == Fulfillment.both) {
      widgets.addAll([
        const Icon(Iconsax.truck_fast, size: 14, color: AppColors.grey),
        const Gap(4),
        Text(AppTexts.feedDelivery, style: style),
      ]);
    }
    if (fulfillment == Fulfillment.both) {
      widgets.add(const Gap(AppSizes.sm));
    }
    if (fulfillment == Fulfillment.pickup || fulfillment == Fulfillment.both) {
      widgets.addAll([
        const Icon(Iconsax.shop, size: 14, color: AppColors.grey),
        const Gap(4),
        Text(AppTexts.feedPickup, style: style),
      ]);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
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
          const Gap(AppSizes.sm + 2),
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
