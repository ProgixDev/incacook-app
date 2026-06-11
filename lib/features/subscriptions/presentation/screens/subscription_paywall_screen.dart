import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/features/subscriptions/presentation/subscribe_flow.dart';

/// Shown to a seller whose mandatory $4/mo platform subscription is not
/// active. Lets them start Stripe Checkout, then refresh their status.
/// Buyers/drivers never see this — it's only mounted inside the gated
/// seller feature tabs (the Profil tab stays accessible).
class SubscriptionPaywallScreen extends StatefulWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  State<SubscriptionPaywallScreen> createState() =>
      _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState extends State<SubscriptionPaywallScreen> {
  bool _busy = false;

  /// Collects the card in-app and charges the $4/mo subscription. On
  /// success the SubscriptionGate auto-reveals the seller feature behind
  /// this screen (no manual navigation).
  Future<void> _subscribe() async {
    setState(() => _busy = true);
    await startCardSubscription(context);
    if (mounted) setState(() => _busy = false);
  }

  /// Fallback: re-pull `/users/me` in case activation landed via webhook.
  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      final fresh = await UserController.instance.refreshFromServer();
      final active = fresh.sellerAccount?.subscriptionActive ?? false;
      if (!active && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abonnement encore inactif.')),
        );
      }
    } catch (_) {
      // ignore — the button is just a convenience retry
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Abonnement vendeur')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(8),
              Icon(Iconsax.shop, size: 64, color: scheme.primary),
              const Gap(16),
              Text(
                'Abonnement requis',
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              Text(
                'Pour vendre sur IncaCook, un abonnement mensuel est requis.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Gap(24),
              _PriceCard(scheme: scheme, text: text),
              const Gap(24),
              const _Benefit(text: 'Ajouter et publier vos plats'),
              const _Benefit(text: 'Recevoir des commandes'),
              const _Benefit(text: 'Apparaître dans la recherche des clients'),
              const Gap(28),
              FilledButton.icon(
                onPressed: _busy ? null : _subscribe,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.card),
                label: const Text('S\'abonner — 4 \$ / mois'),
              ),
              const Gap(12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _refresh,
                icon: const Icon(Iconsax.refresh),
                label: const Text('J\'ai payé — Actualiser'),
              ),
              const Gap(16),
              Text(
                'Paiement sécurisé via Stripe. Résiliable à tout moment.',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '4 \$',
            style: text.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          Text('par mois', style: text.bodyMedium),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Iconsax.tick_circle, color: BrandColors.success, size: 20),
          const Gap(10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
