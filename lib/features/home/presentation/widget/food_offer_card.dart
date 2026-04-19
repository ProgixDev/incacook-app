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
  const FoodOfferCard({super.key, required this.offer, this.onAddToCart});

  final FoodOffer offer;
  final VoidCallback? onAddToCart;

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
            _TitleAndImage(offer: offer),
            const Spacer(),
            _PriceRow(price: offer.price),
            const Gap(AppSizes.md),
            _SpecialOffersRow(
              containOffers: offer.containOffers,
              discountLabel: offer.discountLabel,
              onAddToCart: onAddToCart,
            ),
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

class _TitleAndImage extends StatelessWidget {
  const _TitleAndImage({required this.offer});
  final FoodOffer offer;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: AppColors.textPrimary,
    );

    return SizedBox(
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //* title on the left
          Positioned(
            left: 0,
            top: 0,
            right: 110,
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

          //* food image on the right
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
        ],
      ),
    );
  }
}

// class _FloatingChip extends StatelessWidget {
//   const _FloatingChip({required this.icon, required this.label});
//   final IconData icon;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withValues(alpha: 0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: AppColors.textPrimary),
//           const Gap(4),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price});
  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '€',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          price.toStringAsFixed(2),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SpecialOffersRow extends StatelessWidget {
  const _SpecialOffersRow({
    required this.containOffers,
    this.discountLabel,
    required this.onAddToCart,
  });

  final bool containOffers;
  final String? discountLabel;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (containOffers) ...[
          Expanded(
            child: Row(
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                        Text(
                          discountLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Gap(AppSizes.sm),
        ],

        if (containOffers) const SizedBox.shrink() else const Spacer(),

        GestureDetector(
          onTap: onAddToCart,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.shopping_cart,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
