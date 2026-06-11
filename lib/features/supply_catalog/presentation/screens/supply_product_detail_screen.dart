import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/config/stripe_config.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/orders/presentation/widgets/card_entry_sheet.dart';
import 'package:incacook/features/supply_catalog/data/supply_catalog_repository.dart';
import 'package:incacook/features/supply_catalog/presentation/money_format.dart';

/// Catalog product detail + in-app purchase. The buy flow mirrors buyer
/// checkout: card popup → create order (PaymentIntent) → confirm card →
/// server-verified confirm.
class SupplyProductDetailScreen extends StatefulWidget {
  const SupplyProductDetailScreen({required this.item, super.key});

  final CatalogItem item;

  @override
  State<SupplyProductDetailScreen> createState() =>
      _SupplyProductDetailScreenState();
}

class _SupplyProductDetailScreenState extends State<SupplyProductDetailScreen> {
  final SupplyCatalogRepository _repo = const SupplyCatalogRepository();
  int _qty = 1;
  bool _busy = false;

  int get _totalCents => widget.item.priceCents * _qty;

  Future<void> _buy() async {
    if (!StripeConfig.isConfigured) {
      _toast('Paiement non configuré.');
      return;
    }
    // 1. Collect the card → PaymentMethod id.
    final pmId = await showCardEntrySheet(context, brandLabel: 'fournisseur');
    if (pmId == null) return;

    setState(() => _busy = true);
    try {
      // 2. Create order + PaymentIntent.
      final checkout = await _repo.createOrder(
        productId: widget.item.id,
        quantity: _qty,
      );
      // 3. Confirm the card against the PaymentIntent.
      final secret = checkout.clientSecret;
      if (secret != null && secret.isNotEmpty) {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: secret,
          data: PaymentMethodParams.cardFromMethodId(
            paymentMethodData: PaymentMethodDataCardFromMethod(
              paymentMethodId: pmId,
            ),
          ),
        );
      }
      // 4. Server-verified confirm → marks the order PAID.
      await _repo.confirmPayment(checkout.orderId);
      if (mounted) {
        _toast('Achat confirmé !');
        Navigator.of(context).pop();
      }
    } on StripeException catch (e) {
      if (mounted) _toast(e.error.localizedMessage ?? 'Paiement refusé.');
    } on ApiFailure catch (e) {
      if (mounted) _toast('Achat impossible: ${e.message}');
    } catch (e) {
      if (mounted) _toast('Achat impossible: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 220,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Iconsax.box, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          const Gap(16),
          Text(item.name, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(6),
          Text(
            formatMoney(item.priceCents, item.currency),
            style: text.titleMedium?.copyWith(color: scheme.primary),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const Gap(16),
            Text(item.description!, style: text.bodyMedium),
          ],
          const Gap(24),
          Row(
            children: [
              Text('Quantité', style: text.titleSmall),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                icon: const Icon(Iconsax.minus),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_qty', style: text.titleMedium),
              ),
              IconButton.filledTonal(
                onPressed: _qty < 999 ? () => setState(() => _qty++) : null,
                icon: const Icon(Iconsax.add),
              ),
            ],
          ),
          const Gap(24),
          FilledButton.icon(
            onPressed: _busy ? null : _buy,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.card),
            label: Text('Acheter — ${formatMoney(_totalCents, item.currency)}'),
          ),
        ],
      ),
    );
  }
}
