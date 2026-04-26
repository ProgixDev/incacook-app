import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/common/styles/shadows_styles.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/cart/controllers/cart_controller.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_seller_card.dart';
import 'package:homemade/features/cart/presentation/widgets/order_summary_block.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({super.key, required this.onContinue, this.enabled = true});

  final VoidCallback onContinue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DeviceUtils.getScreenHeight(context) * 0.4,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        DeviceUtils.getBottomNavigationBarHeight() / 1.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [CustomShadowStyle.customCircleShadows()],
      ),
      child: Column(
        children: [
          CartSellerCard(listing: CartController.instance.sellerReference!),
          const Gap(AppSizes.md + 4),
          OrderSummaryBlock(
            subtotal: CartController.instance.subtotal,
            shipping: AppTexts.cartShippingFee,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onContinue : null,
              child: const Text(AppTexts.cartContinuePay),
            ),
          ),
        ],
      ),
    );
  }
}
