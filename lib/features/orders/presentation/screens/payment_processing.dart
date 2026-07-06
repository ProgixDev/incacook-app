import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/config/stripe_config.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/delivery_details.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/screens/order_confirmation.dart';

enum _PaymentPhase { processing, failed }

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.totalAmount,
    required this.selection,
    required this.options,
    this.deliveryDetails,
    this.cardPaymentMethodId,
    this.simulateFailure = false,
    this.termsAccepted = false,
  });

  final double totalAmount;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

  /// Buyer's CGU/CGV consent, captured on the payment screen (the "Payer"
  /// button is disabled until checked). Forwarded to the create-order call.
  final bool termsAccepted;

  /// Stripe PaymentMethod id captured from the card-entry popup. When set,
  /// the order's PaymentIntent is confirmed with this card directly;
  /// otherwise the native Payment Sheet is shown as a fallback.
  final String? cardPaymentMethodId;

  /// Flip to `true` in demo data to exercise the error UI without a real
  /// backend wired up.
  final bool simulateFailure;

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  static const Duration _processingDuration = Duration(seconds: 2);

  _PaymentPhase _phase = _PaymentPhase.processing;

  //? Created order is remembered so a retry (e.g. after the user dismisses
  //? the Stripe sheet) re-presents payment instead of creating a duplicate
  //? order + PaymentIntent.
  String? _orderId;
  String? _orderNumber;
  String? _clientSecret;

  @override
  void initState() {
    super.initState();
    _runPayment();
  }

  Future<void> _runPayment() async {
    if (widget.simulateFailure) {
      await Future.delayed(_processingDuration);
      if (!mounted) return;
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    final cart = CartController.instance;
    if (cart.items.isEmpty && _orderId == null) {
      if (!mounted) return;
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    try {
      // 1. Create the order once. The backend returns the Stripe
      //    PaymentIntent client secret to settle below.
      if (_orderId == null) {
        final result = await OrdersRepository.instance.createOrder(
          items: List.unmodifiable(cart.items),
          fulfillmentChoice: widget.selection.choice,
          dropoffAddress: widget.deliveryDetails?.address,
          deliveryInstructions: widget.deliveryDetails?.instructions,
          scheduledAt:
              widget.deliveryDetails?.timing == DeliveryTiming.scheduled
              ? widget.deliveryDetails?.scheduledAt
              : null,
          termsAccepted: widget.termsAccepted,
        );
        _orderId = result.id;
        _orderNumber = result.orderNumber;
        _clientSecret = result.paymentIntentClientSecret;
      }

      // 2. Collect the card with the Stripe Payment Sheet — but only when
      //    a publishable key is set AND we have a real PaymentIntent.
      //    Without keys the backend returns a dev-bypass secret and we
      //    skip straight to confirmation (no real charge).
      final secret = _clientSecret;
      final needsCardPayment =
          StripeConfig.isConfigured &&
          secret != null &&
          !secret.contains('_secret_devbypass');
      if (needsCardPayment) {
        final cardMethodId = widget.cardPaymentMethodId;
        if (cardMethodId != null) {
          // Settle directly with the card entered in the popup.
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: secret,
            data: PaymentMethodParams.cardFromMethodId(
              paymentMethodData: PaymentMethodDataCardFromMethod(
                paymentMethodId: cardMethodId,
              ),
            ),
          );
        } else {
          // No pre-entered card (PayPal / Apple Pay / wallet) → let Stripe's
          // native sheet collect a method.
          await _presentPaymentSheet(secret);
        }
      }

      // Payment step done — ask the backend to verify the charge with
      // Stripe and confirm the order so it reaches the seller. Best-effort:
      // if it fails (e.g. the charge is still settling), the Stripe webhook
      // confirms it asynchronously, so we don't block the buyer here.
      if (_orderId != null) {
        try {
          await OrdersRepository.instance.confirmPayment(_orderId!);
        } catch (_) {
          // Non-fatal — webhook backstop will confirm.
        }
      }

      if (!mounted) return;

      //? clear the whole checkout flow — confirmation lives on top of home.
      //? OrderConfirmationScreen owns the cart.clear() (after it has
      //? snapshotted items + sellerReference in its initState).
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => OrderConfirmationScreen(
            orderId: _orderId!,
            orderNumber: _orderNumber!,
            totalAmount: widget.totalAmount,
            selection: widget.selection,
            options: widget.options,
            deliveryDetails: widget.deliveryDetails,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (_) {
      // Includes StripeException (card declined / sheet cancelled). The
      // order stays unpaid; retry re-presents the sheet for the same order.
      if (!mounted) return;
      setState(() => _phase = _PaymentPhase.failed);
    }
  }

  /// Opens Stripe's native Payment Sheet for [clientSecret]. Throws on
  /// decline or user cancellation, which `_runPayment` turns into the
  /// failed state.
  Future<void> _presentPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  void _retry() {
    setState(() => _phase = _PaymentPhase.processing);
    _runPayment();
  }

  void _chooseAnotherMethod() {
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _phase == _PaymentPhase.processing;
    return PopScope(
      canPop: !isProcessing,
      child: Scaffold(
        body: SafeArea(
          child: switch (_phase) {
            _PaymentPhase.processing => const _ProcessingView(),
            _PaymentPhase.failed => _FailedView(
              onRetry: _retry,
              onChooseAnotherMethod: _chooseAnotherMethod,
            ),
          },
        ),
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Lottie.asset(
            AppAnimations.loading,
            width: MediaQuery.of(context).size.width * 0.45,
            fit: BoxFit.contain,
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.paymentProcessingTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(flex: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.lock_1, size: 14, color: scheme.onSurfaceVariant),
              const Gap(6),
              Text(
                AppTexts.paymentProcessingSecurity,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(AppSizes.md),
        ],
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.onRetry,
    required this.onChooseAnotherMethod,
  });

  final VoidCallback onRetry;
  final VoidCallback onChooseAnotherMethod;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Lottie.asset(
            AppAnimations.error,
            width: MediaQuery.of(context).size.width * 0.45,
            fit: BoxFit.contain,
            repeat: false,
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.paymentErrorTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(AppSizes.sm + 2),
          Text(
            AppTexts.paymentErrorBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppTexts.paymentErrorRetry),
            ),
          ),
          const Gap(AppSizes.sm + 2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onChooseAnotherMethod,
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
              child: const Text(AppTexts.paymentErrorChooseMethod),
            ),
          ),
          const Gap(AppSizes.md),
        ],
      ),
    );
  }
}
