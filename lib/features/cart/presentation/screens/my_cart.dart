import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/cart/domain/cart_item.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/order_summary_section.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  static const double _shippingFee = 10.00;

  //? in-memory cart until the cart feature is wired to a real source
  final List<CartItem> _items = [
    CartItem(
      id: 'grilled-chicken',
      name: AppTexts.cartItem1Name,
      description: AppTexts.cartItem1Desc,
      imagePath: AppImages.foodTest,
      price: 3.97,
    ),
    CartItem(
      id: 'crunchy-taco',
      name: AppTexts.cartItem2Name,
      description: AppTexts.cartItem2Desc,
      imagePath: AppImages.foodTest,
      price: 4.00,
    ),
    CartItem(
      id: 'el-combo',
      name: AppTexts.cartItem3Name,
      description: AppTexts.cartItem3Desc,
      imagePath: AppImages.foodTest,
      price: 6.50,
    ),
    CartItem(
      id: 'gusco-griller',
      name: AppTexts.cartItem4Name,
      description: AppTexts.cartItem4Desc,
      imagePath: AppImages.foodTest,
      price: 3.50,
    ),
  ];

  double get _subTotal =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void _updateQuantity(String id, int delta) {
    setState(() {
      final item = _items.firstWhere((i) => i.id == id);
      final next = item.quantity + delta;
      if (next < 1) return;
      item.quantity = next;
    });
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((i) => i.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.cartTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: _items.isEmpty
          ? const _EmptyCart()
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final item in _items) ...[
                            CartItemCard(
                              item: item,
                              onIncrement: () => _updateQuantity(item.id, 1),
                              onDecrement: () => _updateQuantity(item.id, -1),
                              onRemove: () => _removeItem(item.id),
                            ),
                            const Gap(AppSizes.md),
                          ],
                          const Gap(AppSizes.spaceBtwSections),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: OrderSummarySection(
                      subTotal: _subTotal,
                      shipping: _shippingFee,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.shopping_cart,
              size: 56,
              color: AppColors.secondary,
            ),
            const Gap(AppSizes.md),
            Text(
              AppTexts.cartEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSizes.xs),
            Text(
              AppTexts.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
