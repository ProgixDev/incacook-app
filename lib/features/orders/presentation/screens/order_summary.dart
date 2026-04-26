import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/features/cart/controllers/cart_controller.dart';
import 'package:homemade/features/cart/domain/cart_item.dart';
import 'package:homemade/features/home/domain/food_listing.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/features/orders/presentation/screens/payment.dart';

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
                  const _SectionHeader(title: AppTexts.checkoutOrderSection),
                  const Gap(AppSizes.md),
                  for (final item in cart.items) ...[
                    _SummaryItemCard(item: item),
                    const Gap(AppSizes.sm),
                  ],
                  const Gap(AppSizes.xs),
                  _EditLinkInline(
                    label: AppTexts.checkoutEditCart,
                    onTap: () => Get.back<void>(),
                  ),
                  const Gap(AppSizes.lg),

                  _SectionHeader(
                    title: selection.choice == FulfillmentChoice.delivery
                        ? AppTexts.checkoutDeliverySection
                        : AppTexts.checkoutPickupSection,
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
                ],
              ),
            ),
          ),
          _ContinueFooter(
            onContinue: () => Get.to<void>(
              () => PaymentScreen(
                totalAmount: total,
                selection: selection,
                options: options,
                deliveryDetails: deliveryDetails,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.18);
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md - 2),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(child: Container(height: 2, color: lineColor)),
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                const Gap(AppSizes.sm - 2),
                Row(
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text(
                      '€${item.lineTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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

class _EditLinkInline extends StatelessWidget {
  const _EditLinkInline({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              decoration: TextDecoration.underline,
              decorationColor: scheme.onSurface,
            ),
          ),
        ),
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

    return Container(
      padding: const EdgeInsets.all(AppSizes.md - 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: scheme.onSurface),
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSizes.sm),
          Align(
            alignment: Alignment.centerRight,
            child: _EditPillLink(label: AppTexts.checkoutEdit, onTap: onEdit),
          ),
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.md - 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  seller.imagePath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.sellerName,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const Gap(6),
                        Text(
                          '·',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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

class _EditPillLink extends StatelessWidget {
  const _EditPillLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md - 2,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outline),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.md - 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
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
    final amountStyle = emphasized
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text('€${amount.toStringAsFixed(2)}', style: amountStyle),
      ],
    );
  }
}

class _ContinueFooter extends StatelessWidget {
  const _ContinueFooter({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.selectedSurface,
              foregroundColor: colors.selectedOnSurface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text(AppTexts.checkoutContinuePayment),
          ),
        ),
      ),
    );
  }
}
