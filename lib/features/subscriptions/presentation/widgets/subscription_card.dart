import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/subscriptions/data/subscription_repository.dart';
import 'package:incacook/features/subscriptions/presentation/subscribe_flow.dart';
import 'package:incacook/features/subscriptions/presentation/widgets/subscription_status_badge.dart';

/// Seller dashboard card: shows the platform subscription status + renewal
/// date and a "Gérer" button that opens the Stripe Billing Portal (update
/// card / cancel / invoices). When inactive it offers a subscribe button.
class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  final SubscriptionRepository _repo = const SubscriptionRepository();
  bool _busy = false;

  Future<void> _open(Future<String> Function() makeUrl, String failMsg) async {
    setState(() => _busy = true);
    try {
      final url = await makeUrl();
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _toast(failMsg);
    } on ApiFailure catch (e) {
      if (mounted) _toast('$failMsg ${e.message}');
    } catch (e) {
      if (mounted) _toast('$failMsg $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// In-app subscribe (card popup → charge), shared with the paywall.
  Future<void> _subscribe() async {
    setState(() => _busy = true);
    await startCardSubscription(context);
    if (mounted) setState(() => _busy = false);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _renewal(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return DateFormat('d MMMM yyyy', 'fr_FR').format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Obx(() {
      final seller = UserController.instance.user.value?.sellerAccount;
      final active = seller?.subscriptionActive ?? false;
      final renewal = _renewal(seller?.subscriptionCurrentPeriodEnd);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.crown, color: scheme.primary, size: 20),
                const Gap(8),
                Text('Mon abonnement',
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                SubscriptionStatusBadge(active: active),
              ],
            ),
            const Gap(10),
            Text(
              active
                  ? (renewal.isNotEmpty
                      ? 'Renouvellement le $renewal'
                      : 'Abonnement actif')
                  : 'Activez votre abonnement pour vendre sur IncaCook.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const Gap(12),
            if (active)
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _open(_repo.createPortalUrl,
                        'Ouverture du portail impossible:'),
                icon: const Icon(Iconsax.setting_2, size: 18),
                label: const Text('Gérer l\'abonnement'),
              )
            else
              FilledButton.icon(
                onPressed: _busy ? null : _subscribe,
                icon: const Icon(Iconsax.card, size: 18),
                label: const Text('S\'abonner — 4 \$ / mois'),
              ),
          ],
        ),
      );
    });
  }
}
