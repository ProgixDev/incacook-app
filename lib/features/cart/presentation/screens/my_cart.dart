import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/cart/controllers/cart_controller.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/add_more_items_button.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/cart_footer.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/empty_cart_state.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/seller_header_block.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/orders/domain/delivery_details.dart';
import 'package:vinted_v2/features/orders/domain/fulfillment_options.dart';
import 'package:vinted_v2/features/orders/presentation/screens/delivery_address.dart';
import 'package:vinted_v2/features/orders/presentation/screens/order_summary.dart';
import 'package:vinted_v2/features/orders/presentation/widgets/fulfillment_choice_sheet.dart';

class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  Future<void> _continueToFulfillment(
    BuildContext context,
    FoodListing seller,
  ) async {
    final options = FulfillmentOptions(
      deliveryAvailable:
          seller.fulfillment == Fulfillment.delivery ||
          seller.fulfillment == Fulfillment.both,
      deliveryMinMinutes: 25,
      deliveryMaxMinutes: 40,
      deliveryFee: 2.50,
      pickupAvailable:
          seller.fulfillment == Fulfillment.pickup ||
          seller.fulfillment == Fulfillment.both,
      pickupNeighborhood: 'Bastille, Paris 11ème',
    );

    final selection = await FulfillmentChoiceSheet.resolve(
      context,
      options: options,
    );
    if (selection == null || !context.mounted) return;

    DeliveryDetails? deliveryDetails;
    if (selection.choice == FulfillmentChoice.delivery) {
      deliveryDetails = await Get.to<DeliveryDetails>(
        () => const DeliveryAddressScreen(),
      );
      if (deliveryDetails == null || !context.mounted) return;
    }

    await Get.to<void>(
      () => OrderSummaryScreen(
        selection: selection,
        options: options,
        deliveryDetails: deliveryDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.cartTitleFr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(() {
        if (cart.isEmpty) {
          return EmptyCartState(onGoHome: () => Get.back<void>());
        }

        final seller = cart.sellerReference!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SellerHeaderBlock(listing: seller),
                    const _Divider(),
                    for (final item in cart.items) ...[
                      CartItemCard(
                        item: item,
                        onIncrement: () => cart.incrementQuantity(item.id),
                        onDecrement: () => cart.decrementQuantity(item.id),
                        onRemove: () => cart.removeItem(item.id),
                      ),
                      const Gap(AppSizes.sm + 2),
                    ],
                    const Gap(AppSizes.sm),
                    AddMoreItemsButton(onTap: () => Get.back<void>()),
                    const _Divider(),
                    CartSubtotalRow(subtotal: cart.subtotal),
                    const Gap(AppSizes.md),
                  ],
                ),
              ),
            ),
            CartFooter(
              total: cart.subtotal,
              enabled: cart.items.every((i) => i.isAvailable),
              onContinue: () => _continueToFulfillment(context, seller),
            ),
          ],
        );
      }),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(height: 1, color: AppColors.lightGrey),
    );
  }
}
