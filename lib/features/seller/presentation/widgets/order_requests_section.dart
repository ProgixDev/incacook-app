import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/seller/data/seller_orders_repository.dart';
import 'package:incacook/features/seller/domain/order_request.dart';
import 'package:incacook/features/seller/presentation/widgets/order_request_card.dart';

/// Home-screen "Demandes de commande" carousel. Lists fresh
/// CONFIRMED orders awaiting the seller's accept/reject decision.
/// Accepting transitions the order to PREPARING (so it disappears
/// from this list and shows up in the "Commandes" tab); rejecting
/// cancels the order on the backend with a default reason.
class OrderRequestsSection extends StatefulWidget {
  const OrderRequestsSection({super.key});

  @override
  State<OrderRequestsSection> createState() => _OrderRequestsSectionState();
}

class _OrderRequestsSectionState extends State<OrderRequestsSection> {
  static const double _cardHeight = 480;
  static const double _viewportFraction = 0.92;

  late Future<List<SellerOrderSummary>> _ordersFuture;
  final Set<String> _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _ordersFuture = _load();
  }

  Future<List<SellerOrderSummary>> _load() {
    return SellerOrdersRepository.instance.listIncoming(status: 'CONFIRMED');
  }

  void _reload() {
    setState(() {
      _ordersFuture = _load();
    });
  }

  Future<void> _accept(String orderId) async {
    if (_busy.contains(orderId)) return;
    setState(() => _busy.add(orderId));
    try {
      await SellerOrdersRepository.instance.startPreparing(orderId);
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'accepter: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(orderId));
    }
  }

  Future<void> _reject(String orderId) async {
    if (_busy.contains(orderId)) return;
    setState(() => _busy.add(orderId));
    try {
      await SellerOrdersRepository.instance.cancel(
        orderId,
        reason: 'Refusé par le vendeur',
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de refuser: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(orderId));
    }
  }

  /// Maps the backend's slim list payload to the existing OrderRequest
  /// card model. The list response already includes per-item rows
  /// (listingName, quantity, unitPriceCents) so the card renders real
  /// product names + prices. Portion isn't a backend field — we leave
  /// it empty and the card just doesn't show it.
  OrderRequest _toCardModel(SellerOrderSummary s) {
    return OrderRequest(
      id: s.orderNumber,
      placedAt: s.placedAt,
      items: s.items
          .map(
            (it) => OrderRequestItem(
              name: it.listingName,
              price: it.unitPriceEuros,
              portion: '',
              quantity: it.quantity,
            ),
          )
          .toList(),
      note: s.note ?? '',
      paymentStatus: 'Payé · ${s.totalEuros.toStringAsFixed(2)} €',
      deliverTo: s.fulfillmentChoice == 'PICKUP'
          ? 'À récupérer sur place'
          : 'Livraison',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SellerOrderSummary>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _sectionFrame(
            count: 0,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.lg,
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return _sectionFrame(
            count: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: _ErrorState(
                error: '${snapshot.error}',
                onRetry: _reload,
              ),
            ),
          );
        }
        final orders = snapshot.data ?? const [];
        return _sectionFrame(
          count: orders.length,
          child: orders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _EmptyState(),
                )
              : SizedBox(
                  height: _cardHeight,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: _viewportFraction),
                    padEnds: false,
                    itemCount: orders.length,
                    itemBuilder: (context, i) {
                      final s = orders[i];
                      final busy = _busy.contains(s.id);
                      return Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? AppSizes.md : AppSizes.sm,
                          right: AppSizes.sm,
                        ),
                        child: Opacity(
                          opacity: busy ? 0.5 : 1.0,
                          child: AbsorbPointer(
                            absorbing: busy,
                            child: OrderRequestCard(
                              order: _toCardModel(s),
                              onAccept: () => _accept(s.id),
                              onReject: () => _reject(s.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _sectionFrame({required int count, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: _SectionHeader(count: count, onRefresh: _reload),
        ),
        const Gap(AppSizes.md),
        child,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count, required this.onRefresh});

  final int count;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (count > 0)
          _CountBadge(count: count)
        else
          //? empty-state header collapses the count badge to a slim accent
          //? bar — keeps the visual rhythm without claiming attention.
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const Gap(AppSizes.md),
        Expanded(
          child: Text(
            AppTexts.sellerOrderRequestsTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: Icon(Iconsax.refresh, color: scheme.onSurface),
          tooltip: 'Actualiser',
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: textTheme.titleMedium?.copyWith(
          color: scheme.onError,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hint = scheme.onSurfaceVariant.withValues(alpha: 0.5);

    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.spaceBtwSections,
      ),
      child: Column(
        children: [
          Icon(Iconsax.emoji_sad, size: 64, color: hint),
          const Gap(AppSizes.lg),
          Text(
            AppTexts.sellerOrderEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: hint),
          ),
        ],
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
    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: scheme.error),
          const Gap(AppSizes.md),
          Text(error, textAlign: TextAlign.center),
          const Gap(AppSizes.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}