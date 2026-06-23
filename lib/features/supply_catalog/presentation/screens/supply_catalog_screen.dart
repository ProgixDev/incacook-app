import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/supply_catalog/data/supply_catalog_repository.dart';
import 'package:incacook/features/supply_catalog/presentation/money_format.dart';
import 'package:incacook/features/supply_catalog/presentation/screens/supply_orders_screen.dart';
import 'package:incacook/features/supply_catalog/presentation/screens/supply_product_detail_screen.dart';

/// Seller-facing catalog of admin products. Browse + tap to buy. Reached
/// from the seller dashboard; the backend restricts it to the SELLER role.
class SupplyCatalogScreen extends StatefulWidget {
  const SupplyCatalogScreen({super.key});

  @override
  State<SupplyCatalogScreen> createState() => _SupplyCatalogScreenState();
}

class _SupplyCatalogScreenState extends State<SupplyCatalogScreen> {
  final SupplyCatalogRepository _repo = const SupplyCatalogRepository();
  late Future<List<CatalogItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listProducts();
  }

  Future<void> _refresh() async {
    final next = _repo.listProducts();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue fournisseur'),
        actions: [
          IconButton(
            tooltip: 'Mes commandes',
            icon: const Icon(Iconsax.receipt_item),
            onPressed: () => Get.to<void>(() => const SupplyOrdersScreen()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CatalogItem>>(
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
            final items = snap.data ?? const <CatalogItem>[];
            if (items.isEmpty) {
              return const _Message(
                icon: Iconsax.box,
                text: 'Aucun produit disponible pour le moment.',
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.74,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) =>
                  _ProductCard(item: items[i], onChanged: _refresh),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item, required this.onChanged});
  final CatalogItem item;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Get.to<void>(() => SupplyProductDetailScreen(item: item));
        await onChanged();
      },
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _imgFallback(scheme),
                    )
                  : _imgFallback(scheme),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(item.priceCents, item.currency),
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback(ColorScheme scheme) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Iconsax.box, color: scheme.onSurfaceVariant, size: 40),
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      // ListView so RefreshIndicator works even when empty.
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
