import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/cart/controllers/cart_controller.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_seller_card.dart';
import 'package:homemade/features/cart/presentation/widgets/order_summary_block.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({super.key, required this.onContinue, this.enabled = true});

  final VoidCallback onContinue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    //* Frosted footer with a top-only rounded radius so the bottom edges
    //* run flush with the screen edge. Column shrink-wraps so the footer
    //* sizes to its content (no fixed-height overflow).
    return FrostedSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        bottomSafe + AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CartSellerCard(listing: CartController.instance.sellerReference!),
          const Gap(AppSizes.md + 4),
          OrderSummaryBlock(
            subtotal: CartController.instance.subtotal,
            shipping: AppTexts.cartShippingFee,
          ),
          const Gap(AppSizes.md),
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
