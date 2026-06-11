import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/constants/sizes.dart';

/// Bottom-sheet popup that collects card details with Stripe's native
/// `CardField` and tokenizes them into a PaymentMethod. Returns the
/// PaymentMethod **id** (safe to hold and confirm the order with later),
/// or `null` if the user cancels.
///
/// The raw PAN/CVC never touch Dart — the SDK keeps them native and hands
/// back only the tokenized id.
Future<String?> showCardEntrySheet(
  BuildContext context, {
  required String brandLabel,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _CardEntrySheet(brandLabel: brandLabel),
  );
}

class _CardEntrySheet extends StatefulWidget {
  const _CardEntrySheet({required this.brandLabel});

  final String brandLabel;

  @override
  State<_CardEntrySheet> createState() => _CardEntrySheetState();
}

class _CardEntrySheetState extends State<_CardEntrySheet> {
  bool _complete = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (!_complete) {
      setState(() => _error = 'Renseigne tous les champs de la carte.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Tokenize the card entered in the mounted CardField into a reusable
      // PaymentMethod id.
      final method = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(method.id);
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.error.localizedMessage ?? 'Carte invalide.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Impossible de valider la carte: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);

    return Padding(
      // Lift the sheet above the keyboard so the input + button stay visible.
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.sm,
        bottom: media.viewInsets.bottom + AppSizes.lg,
      ),
      child: ConstrainedBox(
        // Never taller than the visible area — scroll instead of overflow.
        constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carte ${widget.brandLabel}',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Gap(AppSizes.xs),
              Text(
                'Saisis les informations de ta carte. '
                'Paiement sécurisé par Stripe.',
                style: textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Gap(AppSizes.md),
              // Compact single-line card input (number · MM/YY · CVC · code
              // postal). Sizes itself like a text field, so the sheet stays
              // short and responsive on every screen.
              CardField(
                onCardChanged: (card) {
                  final complete = card?.complete ?? false;
                  if (complete != _complete) {
                    setState(() => _complete = complete);
                  }
                },
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
              ),
              if (_error != null) ...[
                const Gap(AppSizes.sm),
                Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ],
              const Gap(AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmer la carte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
