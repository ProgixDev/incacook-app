import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/cart/presentation/widgets/cart_footer.dart';
import 'package:incacook/features/cart/presentation/widgets/cart_item_card_dismissible.dart';
import 'package:incacook/features/cart/presentation/widgets/empty_cart_state.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/features/client/domain/food_listing.dart';
import 'package:incacook/features/orders/domain/delivery_details.dart';
import 'package:incacook/features/orders/domain/fulfillment_options.dart';
import 'package:incacook/features/orders/presentation/screens/delivery_address.dart';
import 'package:incacook/features/orders/presentation/screens/order_summary.dart';
import 'package:incacook/features/orders/presentation/widgets/fulfillment_choice_sheet.dart';

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
      deliveryFee: AppTexts.cartShippingFee,
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

    await Get.to(
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
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.cartTitleFr,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (cart.isEmpty) {
          return EmptyCartState(onGoHome: () => Get.back<void>());
        }

        final seller = cart.sellerReference!;
        //* Column instead of Stack-overlay: the list scrolls in the
        //* remaining space and the footer naturally docks at the bottom
        //* with no fixed height — fixes the overflow on shorter devices.
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.md,
                  left: AppSizes.md,
                  right: AppSizes.md,
                ),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCardDismissible(
                      item: item,
                      onDismissed: () => cart.removeItem(item.id),
                      onIncrement: () => cart.incrementQuantity(item.id),
                      onDecrement: () => cart.decrementQuantity(item.id),
                      onRemove: () => cart.removeItem(item.id),
                    );
                  },
                  separatorBuilder: (_, _) => const Gap(AppSizes.sm + 4),
                  itemCount: cart.items.length,
                ),
              ),
            ),
            CartFooter(
              enabled: cart.items.every((i) => i.isAvailable),
              onContinue: () => _continueToFulfillment(context, seller),
            ),
          ],
        );
      }),
    );
  }
}
