import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/orders/data/buyer_order_detail.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/screens/order_tracking.dart';

/// Buyer order detail, reached by tapping a row in "Mes commandes".
/// Shows the line items, add-ons, the price breakdown and the delivery
/// address, and — while the order is in flight — a "Suivre ma commande"
/// button into the live-tracking ("suivi") screen.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<BuyerOrderDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<BuyerOrderDetail> _load() =>
      OrdersRepository.instance.getOrderDetail(widget.orderId);

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Détail de la commande',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<BuyerOrderDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              error: 'Impossible de charger la commande.',
              onRetry: _refresh,
            );
          }
          return _Content(order: snapshot.data!);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.order});

  final BuyerOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final date =
        DateFormat('d MMM yyyy · HH:mm', 'fr_FR').format(order.placedAt);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _HeaderCard(order: order, date: date),
        if (order.isTrackable) ...[
          const Gap(AppSizes.md),
          FilledButton.icon(
            onPressed: () =>
                Get.to(() => OrderTrackingScreen(orderId: order.id)),
            icon: const Icon(Icons.local_shipping_outlined, size: 20),
            label: const Text('Suivre ma commande'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
        const Gap(AppSizes.md),
        _ItemsCard(order: order, currency: currency),
        const Gap(AppSizes.md),
        _PriceCard(order: order, currency: currency),
        if (order.isDelivery && order.dropoffLine1 != null) ...[
          const Gap(AppSizes.md),
          _DeliveryCard(order: order),
        ],
        if ((order.note ?? '').isNotEmpty) ...[
          const Gap(AppSizes.md),
          _SectionCard(
            title: 'Note',
            child: Text(order.note!),
          ),
        ],
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order, required this.date});

  final BuyerOrderDetail order;
  final String date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Commande #${order.orderNumber}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(status: order.status),
            ],
          ),
          const Gap(4),
          Text(
            '${order.isDelivery ? 'Livraison' : 'À emporter'} · $date',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order, required this.currency});

  final BuyerOrderDetail order;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Articles',
      child: Column(
        children: [
          for (var i = 0; i < order.items.length; i++) ...[
            if (i > 0) const Divider(height: AppSizes.lg),
            _ItemRow(item: order.items[i], currency: currency),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.currency});

  final BuyerOrderItem item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = ApiConstants.publicImageUrl(item.listingImageUrl);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _ImagePlaceholder(scheme: scheme),
                  )
                : _ImagePlaceholder(scheme: scheme),
          ),
        ),
        const Gap(AppSizes.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.listingName,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(2),
              Text(
                '${item.quantity} × ${currency.format(item.unitPriceCents / 100.0)}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (item.addOns.isNotEmpty) ...[
                const Gap(2),
                Text(
                  item.addOns.map((a) => a.label).join(', '),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if ((item.note ?? '').isNotEmpty) ...[
                const Gap(2),
                Text(
                  '« ${item.note} »',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSizes.sm),
        Text(
          currency.format(item.lineTotalCents / 100.0),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.order, required this.currency});

  final BuyerOrderDetail order;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Paiement',
      child: Column(
        children: [
          _PriceRow(
            label: 'Sous-total',
            value: currency.format(order.subtotalCents / 100.0),
          ),
          if (order.isDelivery) ...[
            const Gap(AppSizes.sm),
            _PriceRow(
              label: 'Frais de livraison',
              value: currency.format(order.deliveryFeeCents / 100.0),
            ),
          ],
          if (order.platformBuyerFeeCents > 0) ...[
            const Gap(AppSizes.sm),
            _PriceRow(
              label: 'Frais de service',
              value: currency.format(order.platformBuyerFeeCents / 100.0),
            ),
          ],
          const Divider(height: AppSizes.lg),
          _PriceRow(
            label: 'Total',
            value: currency.format(order.buyerTotalCents / 100.0),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasize
        ? textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order});

  final BuyerOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _SectionCard(
      title: 'Livraison',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.dropoffLine1!, style: textTheme.bodyMedium),
          if (order.dropoffLine2.isNotEmpty) ...[
            const Gap(2),
            Text(
              order.dropoffLine2,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if ((order.deliveryInstructions ?? '').isNotEmpty) ...[
            const Gap(AppSizes.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    order.deliveryInstructions!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(AppSizes.sm),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg;
    if (status == 'DELIVERED' || status == 'COMPLETED') {
      bg = const Color(0xFF1FA463).withValues(alpha: 0.14);
      fg = const Color(0xFF1FA463);
    } else if (status == 'CANCELLED' || status == 'REFUNDED') {
      bg = scheme.error.withValues(alpha: 0.12);
      fg = scheme.error;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        orderStatusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 40),
            const Gap(AppSizes.sm),
            Text(error, textAlign: TextAlign.center),
            const Gap(AppSizes.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
