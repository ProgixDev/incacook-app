import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/cart/controllers/cart_controller.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_badge.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_footer.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_item_card_dismissible.dart';
import 'package:homemade/features/cart/presentation/widgets/empty_cart_state.dart';
import 'package:homemade/core/enums/order_enums.dart';
import 'package:homemade/features/home/domain/food_listing.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/features/orders/presentation/screens/delivery_address.dart';
import 'package:homemade/features/orders/presentation/screens/order_summary.dart';
import 'package:homemade/features/orders/presentation/widgets/fulfillment_choice_sheet.dart';

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
        actions: [Obx(() => CartBadge(count: cart.itemCount))],
      ),
      body: Obx(() {
        if (cart.isEmpty) {
          return EmptyCartState(onGoHome: () => Get.back<void>());
        }

        final seller = cart.sellerReference!;
        return Stack(
          children: [
            Positioned.fill(
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
                  itemCount: cart.itemCount,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartFooter(
                enabled: cart.items.every((i) => i.isAvailable),
                onContinue: () => _continueToFulfillment(context, seller),
              ),
            ),
          ],
        );
      }),
    );
  }
}
