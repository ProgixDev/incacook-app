import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/features/orders/presentation/screens/order_confirmation.dart';

enum _PaymentPhase { processing, failed }

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.totalAmount,
    required this.selection,
    required this.options,
    this.deliveryDetails,
    this.simulateFailure = false,
  });

  final double totalAmount;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

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

  @override
  void initState() {
    super.initState();
    _runPayment();
  }

  Future<void> _runPayment() async {
    await Future.delayed(_processingDuration);
    if (!mounted) return;

    if (widget.simulateFailure) {
      setState(() => _phase = _PaymentPhase.failed);
      return;
    }

    //? clear the whole checkout flow — confirmation lives on top of home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => OrderConfirmationScreen(
          totalAmount: widget.totalAmount,
          selection: widget.selection,
          options: widget.options,
          deliveryDetails: widget.deliveryDetails,
        ),
      ),
      (route) => route.isFirst,
    );
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
    final colors = context.appColors;
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
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
