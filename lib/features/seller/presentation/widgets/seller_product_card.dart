import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';

import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/food_listing.dart';

class SellerProductCard extends StatelessWidget {
  const SellerProductCard({
    super.key,
    required this.product,
    required this.onAvailabilityChanged,
    this.onTap,
  });

  final FoodListing product;
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
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProductImage(
              imageUrl: product.imageUrl,
              prepMinutes: product.prepMinutes ?? 0,
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
                      // Must be Expanded (not a bare Text + Spacer): a long dish
                      // name would otherwise take its full intrinsic width and
                      // push the availability switch off the right edge, so the
                      // toggle silently disappeared on rows with long names.
                      Expanded(
                        child: Text(
                          product.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(AppSizes.sm),
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
                              product.menuCategory ?? '',
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
  const _ProductImage({required this.imageUrl, required this.prepMinutes});

  final String imageUrl;
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
            // Real listing images come through as HTTP(S) URLs (resolved
            // from Supabase storage paths upstream); legacy mock entries
            // still pass an asset key. On a network failure or while
            // loading we fall through to the placeholder asset so the
            // card slot never reads as empty.
            imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      AppImages.foodTest,
                      fit: BoxFit.cover,
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                : Image.asset(imageUrl, fit: BoxFit.cover),
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
