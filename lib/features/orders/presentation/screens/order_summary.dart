import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/cart/domain/cart_item.dart';
import 'package:incacook/features/client/domain/food_listing.dart';
import 'package:incacook/features/orders/domain/delivery_details.dart';
import 'package:incacook/features/orders/domain/fulfillment_options.dart';
import 'package:incacook/features/orders/presentation/screens/payment.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({
    super.key,
    required this.selection,
    required this.options,
    this.deliveryDetails,
  });

  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

  static const double _serviceFee = 0.50;

  double _computeTotal(double subtotal) =>
      subtotal + selection.fee + _serviceFee;

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final seller = cart.sellerReference!;
    final subtotal = cart.subtotal;
    final total = _computeTotal(subtotal);

    final firstNote = cart.items
        .map((i) => i.note)
        .firstWhere((n) => n.trim().isNotEmpty, orElse: () => '');

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.checkoutTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(
                    title: AppTexts.checkoutOrderSection,
                    onEdit: () => Get.back<void>(),
                  ),
                  const Gap(AppSizes.md),
                  for (final item in cart.items) ...[
                    _SummaryItemCard(item: item),
                    const Gap(AppSizes.sm),
                  ],
                  const Gap(AppSizes.lg),

                  _SectionHeader(
                    title: selection.choice == FulfillmentChoice.delivery
                        ? AppTexts.checkoutDeliverySection
                        : AppTexts.checkoutPickupSection,
                    onEdit: () => Get.back<void>(),
                  ),
                  const Gap(AppSizes.md),
                  _FulfillmentSummary(
                    selection: selection,
                    options: options,
                    deliveryDetails: deliveryDetails,
                    onEdit: () => Get.back<void>(),
                  ),
                  const Gap(AppSizes.lg),

                  const _SectionHeader(title: AppTexts.checkoutSellerSection),
                  const Gap(AppSizes.md),
                  _SellerSummary(seller: seller, note: firstNote),
                  const Gap(AppSizes.lg),

                  const _SectionHeader(title: AppTexts.checkoutPriceSection),
                  const Gap(AppSizes.md),
                  _PriceBreakdown(
                    subtotal: subtotal,
                    deliveryFee: selection.fee,
                    serviceFee: _serviceFee,
                    total: total,
                    isDelivery: selection.choice == FulfillmentChoice.delivery,
                  ),
                  const Gap(AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.to<void>(
                        () => PaymentScreen(
                          totalAmount: total,
                          selection: selection,
                          options: options,
                          deliveryDetails: deliveryDetails,
                        ),
                      ),
                      child: Text(AppTexts.checkoutContinuePayment),
                    ),
                  ),
                  const Gap(AppSizes.spaceBtwSections),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onEdit});

  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lineColor = scheme.onSurface.withValues(alpha: 0.18);
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const Gap(AppSizes.md - 2),
        Expanded(child: Container(height: 2, color: lineColor)),
        if (onEdit != null) ...[
          const Gap(AppSizes.sm),
          GestureDetector(
            onTap: onEdit,
            child: FrostedSurface(
              shape: BoxShape.circle,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(Icons.edit, size: 16, color: scheme.onSurface),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryItemCard extends StatelessWidget {
  const _SummaryItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            child: Image.asset(
              item.listing.imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(AppSizes.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (item.selectedAddOns.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    item.selectedAddOns.map((a) => a.label).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Gap(AppSizes.sm - 2),
                Row(
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    PriceDisplay(
                      price: item.lineTotal,
                      currencySize: 13,
                      priceSize: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentSummary extends StatelessWidget {
  const _FulfillmentSummary({
    required this.selection,
    required this.options,
    required this.deliveryDetails,
    required this.onEdit,
  });

  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;
  final VoidCallback onEdit;

  String _formatScheduledLabel(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(when.year, when.month, when.day);
    final diff = target.difference(today).inDays;
    final time =
        '${when.hour.toString().padLeft(2, '0')}:'
        '${when.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return '${AppTexts.addressToday}, $time';
    if (diff == 1) return '${AppTexts.addressTomorrow}, $time';
    final date =
        '${when.day.toString().padLeft(2, '0')}/'
        '${when.month.toString().padLeft(2, '0')}';
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDelivery = selection.choice == FulfillmentChoice.delivery;
    final icon = isDelivery ? Iconsax.truck_fast : Iconsax.shop;
    final mode = isDelivery
        ? AppTexts.checkoutDeliveryHomeMode
        : AppTexts.checkoutPickupMode;

    final lines = <String>[];
    if (isDelivery && deliveryDetails != null) {
      lines.add(deliveryDetails!.address.line1);
      final timing = deliveryDetails!.timing;
      if (timing == DeliveryTiming.asap) {
        lines.add(AppTexts.checkoutDeliveryAsapEta(options.deliveryMaxMinutes));
      } else if (deliveryDetails!.scheduledAt != null) {
        lines.add(_formatScheduledLabel(deliveryDetails!.scheduledAt!));
      }
    } else {
      lines.add(options.pickupNeighborhood);
    }

    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FrostedSurface(
                shape: BoxShape.circle,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(icon, size: 20, color: scheme.onSurface),
                  ),
                ),
              ),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final line in lines) ...[
                      const Gap(2),
                      Text(
                        line,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // const Gap(AppSizes.sm),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: _EditPillLink(label: AppTexts.checkoutEdit, onTap: onEdit),
          // ),
        ],
      ),
    );
  }
}

class _SellerSummary extends StatelessWidget {
  const _SellerSummary({required this.seller, required this.note});

  final FoodListing seller;
  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomCircularImage(image: seller.imagePath, size: 44),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.sellerName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: Image.asset(
                            seller.category.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          seller.category.label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const Gap(6),
                        Text(
                          '·',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const Gap(6),
                        const Icon(
                          Iconsax.star1,
                          size: 12,
                          color: Color(0xFFFFC107),
                        ),
                        const Gap(3),
                        Text(
                          seller.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.isDelivery,
  });

  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final bool isDelivery;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      child: Column(
        children: [
          _Row(label: AppTexts.checkoutPriceArticles, amount: subtotal),
          if (isDelivery) ...[
            const Gap(AppSizes.sm),
            _Row(label: AppTexts.checkoutPriceDelivery, amount: deliveryFee),
          ],
          const Gap(AppSizes.sm),
          _Row(label: AppTexts.checkoutPriceService, amount: serviceFee),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md - 4),
            child: Divider(height: 1, color: scheme.outline),
          ),
          _Row(
            label: AppTexts.checkoutPriceTotal,
            amount: total,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  final String label;
  final double amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = emphasized
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        PriceDisplay(price: amount, currencySize: 15, priceSize: 15),
      ],
    );
  }
}