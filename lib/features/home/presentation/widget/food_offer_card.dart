import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/catalog/presentation/screens/product_detail.dart';
import 'package:vinted_v2/features/home/domain/food_offer.dart';

class FoodOfferCard extends StatelessWidget {
  const FoodOfferCard({super.key, required this.offer});

  final FoodOffer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.4),
        ),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              minutes: offer.deliveryMinutes,
              freeDelivery: offer.freeDelivery,
            ),
            const Gap(AppSizes.md),
            _TitleImageAndPrice(offer: offer),
            if (offer.containOffers) ...[
              const Gap(AppSizes.md),
              _SpecialOffersRow(discountLabel: offer.discountLabel),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.minutes, required this.freeDelivery});
  final int minutes;
  final bool freeDelivery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.clock, size: 14, color: AppColors.white),
              const Gap(6),
              Text(
                '$minutes mins',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSizes.sm),
        if (freeDelivery) ...[
          const Icon(Iconsax.truck_fast, size: 16, color: AppColors.grey),
          const Gap(4),
          Text(
            AppTexts.homeFreeDelivery,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
        ],
      ],
    );
  }
}

class _TitleImageAndPrice extends StatelessWidget {
  const _TitleImageAndPrice({required this.offer});
  final FoodOffer offer;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: AppColors.textPrimary,
    );

    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //* title spans the upper-left, reserving space for the round image
          Positioned(
            left: 0,
            top: 0,
            right: 120,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${offer.titleLeading} ', style: titleStyle),
                  TextSpan(
                    text: offer.titleTrailing,
                    style: titleStyle?.copyWith(
                      color: AppColors.grey.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
            ),
          ),

          //* food image floats bottom-right
          Positioned(
            right: -AppSizes.md,
            bottom: -AppSizes.sm,
            child: SizedBox(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset(offer.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),

          //* large price sits at the bottom-left, next to the image
          Positioned(
            left: 0,
            bottom: 0,
            child: _LargePrice(price: offer.price),
          ),
        ],
      ),
    );
  }
}

class _LargePrice extends StatelessWidget {
  const _LargePrice({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '€',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          price.toStringAsFixed(2),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _SpecialOffersRow extends StatelessWidget {
  const _SpecialOffersRow({this.discountLabel});

  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: const Icon(
            Iconsax.discount_shape,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(AppSizes.sm),
        if (discountLabel != null && discountLabel!.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTexts.homeSpecialOffers,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                ),
                Text(
                  discountLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
