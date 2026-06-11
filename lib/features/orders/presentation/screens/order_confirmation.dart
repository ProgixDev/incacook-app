import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/delivery_details.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/features/orders/presentation/screens/order_tracking.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.selection,
    required this.options,
    this.deliveryDetails,
  });

  /// Server-issued order id (ULID) from `POST /v1/orders`. Threaded
  /// through to the tracking screen so it can subscribe to the live
  /// driver-position socket for this delivery.
  final String orderId;
  final double totalAmount;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  static const double _serviceFee = 0.50;

  late final String _orderNumber;
  late final List<CartItem> _items;
  late final FoodListing _seller;
  late final double _subtotal;

  @override
  void initState() {
    super.initState();
    final cart = CartController.instance;
    _items = List.unmodifiable(cart.items);
    _seller = cart.sellerReference!;
    _subtotal = cart.subtotal;
    _orderNumber = _generateOrderNumber();

    HapticFeedback.heavyImpact();

    //? clear the cart after first frame so the snapshot above stays intact
    WidgetsBinding.instance.addPostFrameCallback((_) => cart.clear());
  }

  static String _generateOrderNumber() {
    final random = Random();
    return 'A${1000 + random.nextInt(9000)}';
  }

  DateTime get _expectedArrival =>
      DateTime.now().add(Duration(minutes: widget.options.deliveryMaxMinutes));

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _itemsSummary() {
    if (_items.isEmpty) return '';
    return _items
        .map((i) => i.listing.name.split(' ').first)
        .toSet()
        .join(' + ');
  }

  void _goToTracking() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Get.to<void>(() => OrderTrackingScreen(orderId: widget.orderId));
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SuccessHeader(orderNumber: _orderNumber),
              const _Divider(),
              _StatusBlock(
                sellerName: _seller.sellerName,
                selection: widget.selection,
                options: widget.options,
                deliveryDetails: widget.deliveryDetails,
                expectedArrivalLabel: _formatTime(_expectedArrival),
              ),
              const _Divider(),
              _RecapBlock(
                itemsSummary: _itemsSummary(),
                subtotal: _subtotal,
                deliveryFee: widget.selection.fee,
                serviceFee: _serviceFee,
                total: widget.totalAmount,
                isDelivery:
                    widget.selection.choice == FulfillmentChoice.delivery,
              ),
              const Gap(AppSizes.lg),
              _CtaStack(onTrack: _goToTracking, onGoHome: _goHome),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Lottie.asset(
            AppAnimations.success,
            fit: BoxFit.contain,
            repeat: false,
          ),
        ),
        const Gap(AppSizes.sm),
        Text(
          AppTexts.successTitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Gap(AppSizes.sm - 2),
        Text(
          '${AppTexts.successOrderNumberPrefix} #$orderNumber',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(height: 1, color: scheme.outline),
    );
  }
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({
    required this.sellerName,
    required this.selection,
    required this.options,
    required this.deliveryDetails,
    required this.expectedArrivalLabel,
  });

  final String sellerName;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;
  final String expectedArrivalLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDelivery = selection.choice == FulfillmentChoice.delivery;
    final titleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);
    final subStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Iconsax.shop, size: 20, color: scheme.onSurface),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: Text(
                AppTexts.successStatusPreparing(sellerName),
                style: titleStyle,
              ),
            ),
          ],
        ),
        const Gap(AppSizes.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDelivery ? Iconsax.truck_fast : Iconsax.location,
              size: 20,
              color: scheme.onSurface,
            ),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDelivery
                        ? AppTexts.successDeliveryEstimateLabel
                        : AppTexts.successPickupEstimateLabel,
                    style: titleStyle,
                  ),
                  const Gap(2),
                  Text(
                    isDelivery
                        ? AppTexts.successDeliveryWindow(
                            options.deliveryMinMinutes,
                            options.deliveryMaxMinutes,
                          )
                        : options.pickupNeighborhood,
                    style: subStyle,
                  ),
                  const Gap(AppSizes.sm),
                  Text(
                    '${isDelivery ? AppTexts.successExpectedArrivalPrefix : AppTexts.successExpectedPickupPrefix} $expectedArrivalLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecapBlock extends StatelessWidget {
  const _RecapBlock({
    required this.itemsSummary,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.isDelivery,
  });

  final String itemsSummary;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final bool isDelivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.successRecapTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(AppSizes.sm + 2),
        _Row(label: itemsSummary, amount: subtotal),
        if (isDelivery) ...[
          const Gap(AppSizes.xs + 2),
          _Row(label: AppTexts.checkoutPriceDelivery, amount: deliveryFee),
        ],
        const Gap(AppSizes.xs + 2),
        _Row(label: AppTexts.successRecapServiceLabel, amount: serviceFee),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
          child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        _Row(
          label: AppTexts.successTotalPaidLabel,
          amount: total,
          emphasized: true,
        ),
      ],
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
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        const Gap(AppSizes.md),
        PriceDisplay(price: amount, currencySize: 14, priceSize: 14),
      ],
    );
  }
}

class _CtaStack extends StatelessWidget {
  const _CtaStack({required this.onTrack, required this.onGoHome});

  final VoidCallback onTrack;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTrack,
            child: const Text(AppTexts.successTrackOrderCta),
          ),
        ),
        const Gap(AppSizes.sm + 2),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: scheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text(AppTexts.successBackHomeCta),
          ),
        ),
      ],
    );
  }
}
