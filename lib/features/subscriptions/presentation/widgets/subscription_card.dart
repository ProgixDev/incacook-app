import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/services/revenuecat_service.dart';
import 'package:incacook/features/subscriptions/presentation/screens/subscription_paywall_screen.dart';
import 'package:incacook/features/subscriptions/presentation/widgets/subscription_status_badge.dart';

/// Seller dashboard card: shows the platform subscription status + renewal
/// date and a "Gérer" button that opens the App Store / Play Store subscription
/// management page. When inactive it opens the RevenueCat paywall.
class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  final RevenueCatService _revenueCat = Get.find<RevenueCatService>();
  bool _busy = false;

  Future<void> _manageSubscription() async {
    setState(() => _busy = true);
    try {
      final url =
          await _revenueCat.subscriptionManagementUrl() ??
          _fallbackManagementUrl();
      final uri = Uri.tryParse(url);
      if (uri == null) {
        if (mounted) _toast('Ouverture de la gestion impossible.');
        return;
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _toast('Ouverture de la gestion impossible.');
    } catch (e) {
      if (mounted) _toast('Ouverture de la gestion impossible: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fallbackManagementUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/account/subscriptions'
          '?package=com.incacook.app';
    }
    return 'https://apps.apple.com/account/subscriptions';
  }

  /// Opens the current RevenueCat/App Store subscription flow.
  Future<void> _subscribe() async {
    setState(() => _busy = true);
    try {
      await Get.to<void>(() => const SubscriptionPaywallScreen());
      await UserController.instance.refreshFromServer();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                // Expanded so the title absorbs leftover width and ellipsizes
                // instead of pushing the badge off-screen (was a fixed Text +
                // Spacer → RenderFlex overflow on narrow phones).
                Expanded(
                  child: Text(
                    'Mon abonnement',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(8),
                Flexible(
                  fit: FlexFit.loose,
                  child: SubscriptionStatusBadge(active: active),
                ),
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
                onPressed: _busy ? null : _manageSubscription,
                icon: const Icon(Iconsax.setting_2, size: 18),
                label: const Text('Gérer l\'abonnement'),
              )
            else
              FilledButton.icon(
                onPressed: _busy ? null : _subscribe,
                icon: const Icon(Iconsax.crown, size: 18),
                label: const Text('Choisir un abonnement'),
              ),
          ],
        ),
      );
    });
  }
}
