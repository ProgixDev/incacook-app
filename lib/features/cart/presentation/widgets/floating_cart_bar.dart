import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/cart/controllers/cart_controller.dart';
import 'package:vinted_v2/features/cart/presentation/screens/my_cart.dart';

/// Compact pill that floats at the bottom of seller-browsing screens while
/// the cart has items. Tap to open [MyCartScreen].
class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

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
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.shopping_bag,
                  color: AppColors.white,
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
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                      ),
                      Text(
                        '${AppTexts.cartFloatingTotalPrefix} €${cart.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
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
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.white,
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
