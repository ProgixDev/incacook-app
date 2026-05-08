import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/cart/presentation/screens/my_cart.dart';

/// Compact pill that floats at the bottom of seller-browsing screens while
/// the cart has items. Tap to open [MyCartScreen].
class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final colors = context.appColors;
    final fg = colors.selectedOnSurface;

    return Obx(() {
      if (cart.isEmpty) return const SizedBox.shrink();

      final count = cart.itemCount;
      final articleWord = count == 1
          ? AppTexts.cartFloatingArticleSingular
          : AppTexts.cartFloatingArticlesPlural;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: GestureDetector(
          onTap: () => Get.to(() => const MyCartScreen()),
          //* frosted bar tinted with the brand's "selected" surface — keeps
          //* the strong brown/cream cart pill identity while adopting the
          //* glass aesthetic of the rest of the app.
          child: FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            tint: colors.selectedSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 2,
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.shopping_bag,
                  color: fg,
                  size: 18,
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count $articleWord',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        '${AppTexts.cartFloatingTotalPrefix} €${cart.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: fg.withValues(alpha: 0.85),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSizes.sm),
                Text(
                  AppTexts.cartFloatingSeeCart,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Icon(
                  Iconsax.arrow_right_3,
                  color: fg,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
