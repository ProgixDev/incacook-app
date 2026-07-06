import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/delivery_details.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/legal/presentation/legal_terms_screen.dart';
import 'package:incacook/features/orders/presentation/screens/payment_processing.dart';
import 'package:incacook/features/orders/presentation/widgets/card_entry_sheet.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selection,
    required this.options,
    this.deliveryDetails,
  });

  final double totalAmount;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;

  /// Required CGU/CGV consent — "Payer" stays disabled until checked.
  bool _termsAccepted = false;

  Future<void> _pay() async {
    if (_processing) return;

    HapticFeedback.mediumImpact();
    setState(() => _processing = true);

    try {
      // 1. Collect card details first
      final cardPaymentMethodId = await showCardEntrySheet(
        context,
        brandLabel: 'bancaire',
      );

      // 2. If user cancelled card entry, stop here
      if (cardPaymentMethodId == null) {
        if (mounted) setState(() => _processing = false);
        return;
      }

      // 3. Proceed to payment processing with the collected card method
      if (mounted) {
        await Get.to<void>(
          () => PaymentProcessingScreen(
            totalAmount: widget.totalAmount,
            selection: widget.selection,
            options: widget.options,
            deliveryDetails: widget.deliveryDetails,
            termsAccepted: _termsAccepted,
            cardPaymentMethodId: cardPaymentMethodId,
          ),
        );
      }
    } catch (e) {
      // Card entry sheet failed - show error and reset
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la saisie de la carte: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.paymentTitle,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalHeader(amount: widget.totalAmount),
                  const Gap(AppSizes.spaceBtwSections),
                  const _StripeDirectCard(),
                  const _Divider(),
                  const _SecureNote(),
                  const Gap(AppSizes.sm + 2),
                  // Required CGU/CGV consent + "Lire les CGU/CGV" link.
                  TermsConsentTile(
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v),
                  ),
                ],
              ),
            ),
          ),
          _PayFooter(
            total: widget.totalAmount,
            enabled: _termsAccepted && !_processing,
            processing: _processing,
            onPay: _pay,
          ),
        ],
      ),
    );
  }
}

class _TotalHeader extends StatelessWidget {
  const _TotalHeader({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.paymentTotalLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSizes.xs),
        PriceDisplay(price: amount, currencySize: 33, priceSize: 33),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(height: 1, color: Theme.of(context).colorScheme.outline),
    );
  }
}

class _StripeDirectCard extends StatelessWidget {
  const _StripeDirectCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      tint: colors.selectedSurface.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(Iconsax.card, color: scheme.primary, size: 22),
          ),
          const Gap(AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carte bancaire',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const Gap(4),
                Text(
                  'Paiement sécurisé par Stripe',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.tick_circle, color: scheme.primary, size: 20),
        ],
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Iconsax.lock_1, size: 14, color: scheme.onSurfaceVariant),
        const Gap(6),
        Flexible(
          child: Text(
            AppTexts.paymentSecureNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PayFooter extends StatelessWidget {
  const _PayFooter({
    required this.total,
    required this.enabled,
    required this.processing,
    required this.onPay,
  });

  final double total;
  final bool enabled;
  final bool processing;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.transparent)),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onPay : null,
            child: processing
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      context.appColors.selectedSurface,
                    ),
                  )
                : Text(
                    '${AppTexts.paymentPayCtaPrefix} €${total.toStringAsFixed(2)}',
                  ),
          ),
        ),
      ),
    );
  }
}
