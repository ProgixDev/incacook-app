import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/widgets/qr/qr_display_sheet.dart';
import 'package:incacook/features/orders/data/order_summary.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/screens/dispute_screen.dart';
import 'package:incacook/features/reviews/presentation/review_sheet.dart';

/// Profile "Mes commandes" history. Buyer mode lists the user's own orders;
/// seller mode lists the seller's orders and shows a **payée / non payée**
/// badge per order (paid = the Stripe charge succeeded). Both highlight
/// successfully completed orders.
class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key, required this.isSeller});

  /// true → seller view (loads `/sellers/me/orders`, shows paid badge);
  /// false → buyer view (loads `/orders/me`).
  final bool isSeller;

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  late Future<List<OrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderSummary>> _load() => widget.isSeller
      ? OrdersRepository.instance.listSellerOrders()
      : OrdersRepository.instance.listMyOrders();

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  /// Buyer reviews a DELIVERED order. On success, refresh the list (so the
  /// "Noter" button reflects the now-reviewed state) and confirm.
  Future<void> _openReview(OrderSummary order) async {
    final submitted = await ReviewSheet.show(
      context,
      orderId: order.id,
      orderNumber: order.orderNumber,
    );
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Merci pour votre avis !')));
      await _refresh();
    }
  }

  /// Buyer reports a post-delivery problem. Refreshes on success so a resulting
  /// refund/status change is reflected.
  Future<void> _openDispute(OrderSummary order) async {
    final created = await Get.to<bool>(
      () => DisputeScreen(orderId: order.id, orderNumber: order.orderNumber),
    );
    if (created == true && mounted) {
      await _refresh();
    }
  }

  /// Fetches the buyer's reception QR and shows it for the driver to scan —
  /// reachable from history, so leaving the live-tracking screen never strands
  /// the handoff. Surfaces the backend message (e.g. not in delivery yet).
  Future<void> _openReceptionQr(OrderSummary order) async {
    try {
      final qr = await OrdersRepository.instance.fetchDeliveryQr(order.id);
      if (!mounted) return;
      await showQrModal(
        context,
        title: AppTexts.deliveryQrSheetTitle,
        instruction: AppTexts.deliveryQrSheetInstruction,
        qrData: qr.qrData,
        closeLabel: AppTexts.deliveryQrSheetClose,
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.deliveryQrUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Mes commandes',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<OrderSummary>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _MessageList(
                child: _ErrorState(
                  error: '${snapshot.error}',
                  onRetry: _refresh,
                ),
              );
            }
            final orders = snapshot.data ?? const <OrderSummary>[];
            if (orders.isEmpty) {
              return const _MessageList(
                child: Text(
                  'Aucune commande pour l\'instant.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                showPaidBadge: widget.isSeller,
                // Buyers can review a delivered order.
                onReview: widget.isSeller ? null : () => _openReview(orders[i]),
                // Buyers can report a post-delivery problem.
                onDispute: widget.isSeller
                    ? null
                    : () => _openDispute(orders[i]),
                // Buyers can re-open their reception QR straight from history —
                // so a buyer who left the live-tracking screen can still present
                // it to the driver (the card gates it to in-delivery orders).
                onReceptionQr: widget.isSeller
                    ? null
                    : () => _openReceptionQr(orders[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.showPaidBadge,
    this.onReview,
    this.onDispute,
    this.onReceptionQr,
  });

  final OrderSummary order;
  final bool showPaidBadge;

  /// Buyer-side review action; shown only for DELIVERED orders.
  final VoidCallback? onReview;

  /// Buyer-side "report a problem" action; shown for in-delivery/delivered orders.
  final VoidCallback? onDispute;

  /// Buyer-side "show my reception QR"; shown only for an in-delivery order
  /// being delivered (not a pickup) so the buyer can re-present it any time.
  final VoidCallback? onReceptionQr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final date = DateFormat(
      'd MMM yyyy · HH:mm',
      'fr_FR',
    ).format(order.placedAt);
    final itemsLabel = order.itemCount > 1 ? 'articles' : 'article';

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
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                currency.format(order.totalEuros),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Gap(2),
          Text(
            '${order.itemCount} $itemsLabel · '
            '${order.fulfillmentChoice == 'PICKUP' ? 'À emporter' : 'Livraison'} · $date',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(AppSizes.sm),
          Row(
            children: [
              _StatusChip(order: order),
              if (showPaidBadge) ...[
                const Gap(AppSizes.sm),
                _PaidChip(paid: order.isPaid, cancelled: order.isCancelled),
              ],
            ],
          ),
          //* Buyer reception-QR action — the order is out for delivery and the
          //* buyer must present the QR the driver scans. Reachable here so
          //* leaving the tracking screen doesn't dead-end the handoff.
          if (onReceptionQr != null && order.canShowReceptionQr) ...[
            const Gap(AppSizes.sm),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onReceptionQr,
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text(AppTexts.buyerDeliveryQrCta),
              ),
            ),
          ],
          //* Buyer review action — only once the order is DELIVERED. The
          //* backend rejects a second review (one per order); the error is
          //* surfaced in the sheet if the buyer already reviewed.
          if (onReview != null && order.status == 'DELIVERED') ...[
            const Gap(AppSizes.sm),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.star_rate_rounded, size: 18),
                label: const Text('Noter'),
              ),
            ),
          ],
          //* Buyer "report a problem" — available once the order is on its way
          //* or completed (covers never-received + post-delivery quality issues).
          if (onDispute != null &&
              (order.status == 'IN_DELIVERY' ||
                  order.status == 'DELIVERED' ||
                  order.status == 'COMPLETED')) ...[
            const Gap(AppSizes.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDispute,
                icon: const Icon(Icons.report_gmailerrorred_outlined, size: 18),
                label: const Text(AppTexts.disputeCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'En attente';
    case 'CONFIRMED':
      return 'Confirmée';
    case 'PREPARING':
      return 'En préparation';
    case 'READY':
      return 'Prête';
    case 'PICKED_UP':
      return 'Récupérée';
    case 'IN_DELIVERY':
      return 'En livraison';
    case 'NO_DRIVER_AVAILABLE':
      return 'Aucun livreur';
    case 'DELIVERED':
      return 'Livrée';
    case 'COMPLETED':
      return 'Terminée';
    case 'CANCELLED':
      return 'Annulée';
    case 'REFUNDED':
      return 'Remboursée';
    case 'DISPUTED':
      return 'Litige';
    default:
      return status;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Completed = green, cancelled/refunded = error, otherwise neutral.
    final Color bg;
    final Color fg;
    if (order.isCompleted) {
      bg = const Color(0xFF1FA463).withValues(alpha: 0.14);
      fg = const Color(0xFF1FA463);
    } else if (order.isCancelled) {
      bg = scheme.error.withValues(alpha: 0.12);
      fg = scheme.error;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }
    return _Pill(label: _statusLabel(order.status), bg: bg, fg: fg);
  }
}

class _PaidChip extends StatelessWidget {
  const _PaidChip({required this.paid, required this.cancelled});

  final bool paid;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (cancelled) {
      return _Pill(
        label: 'Remboursée',
        bg: scheme.error.withValues(alpha: 0.12),
        fg: scheme.error,
        icon: Icons.undo,
      );
    }
    return paid
        ? _Pill(
            label: 'Payée',
            bg: const Color(0xFF1FA463).withValues(alpha: 0.14),
            fg: const Color(0xFF1FA463),
            icon: Icons.check_circle,
          )
        : _Pill(
            label: 'Non payée',
            bg: const Color(0xFFE8823B).withValues(alpha: 0.16),
            fg: const Color(0xFFC9621F),
            icon: Icons.schedule,
          );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const Gap(4)],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps a centered message so it stays scrollable (for RefreshIndicator).
class _MessageList extends StatelessWidget {
  const _MessageList({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(child: child),
        ),
      ],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: scheme.error, size: 40),
        const Gap(AppSizes.sm),
        Text(error, textAlign: TextAlign.center),
        const Gap(AppSizes.md),
        OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    );
  }
}
