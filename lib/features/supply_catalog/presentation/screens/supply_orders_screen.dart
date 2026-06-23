import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/supply_catalog/data/supply_catalog_repository.dart';
import 'package:incacook/features/supply_catalog/presentation/money_format.dart';
import 'package:incacook/features/supply_catalog/presentation/screens/supply_claim_screen.dart';

/// French label for a claim status.
String _claimStatusLabel(String status) {
  switch (status) {
    case 'OPEN':
    case 'ADMIN_REVIEW':
      return "En cours d'examen";
    case 'REFUNDED':
      return 'Remboursé';
    case 'REPLACEMENT_REQUESTED':
      return 'Remplacement demandé';
    case 'REJECTED':
      return 'Rejeté';
    case 'RESOLVED':
      return 'Résolu';
    default:
      return status;
  }
}

/// Seller's catalog purchase history. Each order shows its status and — when a
/// paid order is within the 14-day window — a "Signaler un problème" button.
/// Existing claims show their current status.
class SupplyOrdersScreen extends StatefulWidget {
  const SupplyOrdersScreen({super.key});

  @override
  State<SupplyOrdersScreen> createState() => _SupplyOrdersScreenState();
}

class _SupplyOrdersScreenState extends State<SupplyOrdersScreen> {
  final SupplyCatalogRepository _repo = const SupplyCatalogRepository();
  late Future<(List<CatalogOrder>, List<CatalogClaim>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<CatalogOrder>, List<CatalogClaim>)> _load() async {
    final orders = await _repo.listMyOrders();
    final claims = await _repo.listMyClaims();
    return (orders, claims);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _openClaim(CatalogOrder order) async {
    final created = await Get.to<bool>(() => SupplyClaimScreen(order: order));
    if (created == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes catalogue')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<(List<CatalogOrder>, List<CatalogClaim>)>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              final msg = snap.error is ApiFailure
                  ? (snap.error as ApiFailure).message
                  : 'Chargement impossible.';
              return _Message(icon: Iconsax.warning_2, text: msg);
            }
            final (orders, claims) = snap.data ?? (const <CatalogOrder>[], const <CatalogClaim>[]);
            if (orders.isEmpty) {
              return const _Message(icon: Iconsax.box, text: 'Aucune commande catalogue.');
            }
            // Latest claim per order (claims are returned newest-first).
            final byOrder = <String, CatalogClaim>{};
            for (final c in claims) {
              byOrder.putIfAbsent(c.catalogOrderId, () => c);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _OrderCard(
                order: orders[i],
                claim: byOrder[orders[i].id],
                onReport: () => _openClaim(orders[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.claim, required this.onReport});

  final CatalogOrder order;
  final CatalogClaim? claim;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('d MMM yyyy', 'fr_FR').format(order.paidAt ?? order.createdAt);
    final itemSummary = order.items.map((it) => '${it.quantity}× ${it.name}').join(', ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(color: scheme.onSurfaceVariant)),
              Text(
                formatMoney(order.totalCents, order.currency),
                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (itemSummary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(itemSummary, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Text('Statut : ${order.status}', style: TextStyle(color: scheme.onSurfaceVariant)),

          if (claim != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.message_question, size: 16, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'Réclamation : ${_claimStatusLabel(claim!.status)}',
                    style: TextStyle(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ] else if (order.isClaimEligible) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReport,
                icon: const Icon(Iconsax.warning_2, size: 18),
                label: const Text('Signaler un problème'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        Icon(icon, size: 48, color: scheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(text, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
