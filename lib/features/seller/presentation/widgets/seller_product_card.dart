import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/common/widgets/misc/price_display.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/features/seller/domain/seller_product.dart';

class SellerProductCard extends StatelessWidget {
  const SellerProductCard({
    super.key,
    required this.product,
    required this.onAvailabilityChanged,
    this.onTap,
  });

  final SellerProduct product;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback? onTap;

  static const double _imageWidth = 110;
  static const double _imageHeight = 110;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProductImage(
              imagePath: product.imagePath,
              prepMinutes: product.prepMinutes,
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      _AvailabilitySwitch(
                        value: product.isAvailable,
                        onChanged: onAvailabilityChanged,
                      ),
                    ],
                  ),
                  const Gap(AppSizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Gap(AppSizes.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.category,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(AppSizes.sm),
                          Text(
                            '|',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(AppSizes.sm),
                          Text(
                            product.isAvailable
                                ? AppTexts.sellerProductsAvailableLabel
                                : AppTexts.sellerProductsNotAvailableLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: product.isAvailable
                                  ? BrandColors.success
                                  : BrandColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(AppSizes.sm),
                  PriceDisplay(price: product.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imagePath, required this.prepMinutes});

  final String imagePath;
  final int prepMinutes;

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: SellerProductCard._imageWidth,
        height: SellerProductCard._imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: AppSizes.sm,
            //       vertical: 6,
            //     ),
            //     color: Colors.black.withValues(alpha: 0.45),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         const Icon(Iconsax.clock, color: Colors.white, size: 12),
            //         const Gap(4),
            //         Text(
            //           '$prepMinutes ${AppTexts.sellerProductsPrepSuffix}',
            //           style: textTheme.labelSmall?.copyWith(
            //             color: Colors.white,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(2),
          //? rating star is a regulatory-style accent — brand-stable amber.
          const Icon(Icons.star_rounded, color: BrandColors.warning, size: 14),
        ],
      ),
    );
  }
}

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    //? veg / non-veg dot is a regulatory indicator — brand-stable across
    //? modes, same convention as the order request quantity pill.
    final color = isVeg ? BrandColors.success : BrandColors.error;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 24,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: BrandColors.success,
          inactiveTrackColor: BrandColors.error.withValues(alpha: 0.55),
          activeThumbColor: Colors.white,
          inactiveThumbColor: Colors.white,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    //? disabled treatment when there's no discount keeps the row's vertical
    //? rhythm without misleading users into thinking 0% is an offer.
    final hasDiscount = percent > 0;
    final bg = hasDiscount
        ? scheme.primary
        : scheme.primary.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.discount_shape, color: scheme.onPrimary, size: 12),
          const Gap(4),
          Text(
            '$percent% OFF',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
