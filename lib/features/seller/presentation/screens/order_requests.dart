import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/seller/data/seller_orders_repository.dart';
import 'package:incacook/features/seller/domain/accepted_order.dart';
import 'package:incacook/features/seller/presentation/widgets/accepted_order_card.dart';
import 'package:incacook/features/seller/presentation/widgets/orders_filter_panel.dart';
import 'package:incacook/features/seller/presentation/widgets/orders_tab_toggle.dart';

/// Backend `OrderStatus` strings — the source of truth for what the
/// seller can do next.
const _kPending = 'PENDING';
const _kConfirmed = 'CONFIRMED';
const _kPreparing = 'PREPARING';
const _kReady = 'READY';
const _kInDelivery = 'IN_DELIVERY';
const _kDelivered = 'DELIVERED';
const _kCompleted = 'COMPLETED';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  OrdersTab _tab = OrdersTab.accepted;
  OrdersStatusFilter _statusFilter;
  OrdersSortBy _sortBy = OrdersSortBy.acceptedTime;

  late Future<List<SellerOrderSummary>> _ordersFuture;
  final Set<String> _busy = <String>{};

  _OrderRequestsScreenState() : _statusFilter = null;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _load();
  }

  Future<List<SellerOrderSummary>> _load() {
    return SellerOrdersRepository.instance.listIncoming();
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _ordersFuture = next;
    });
    await next;
  }

  /// Splits the raw backend list into the "active" pane (the seller can
  /// still act on these) vs the "history" pane (cancelled or fully done).
  /// `CONFIRMED` (awaiting accept) intentionally lives on the home
  /// screen's "Demandes de commande" carousel — once the seller
  /// accepts it transitions to PREPARING and shows up here.
  bool _isActive(SellerOrderSummary o) {
    switch (o.status) {
      case _kPending:
      case _kPreparing:
      case _kReady:
      case _kInDelivery:
        return true;
      default:
        return false;
    }
  }

  /// Backend status → display badge. Active orders fall into either
  /// `preparing` (PENDING/PREPARING) or `readyToPickup` (READY /
  /// IN_DELIVERY — food is out of the kitchen, awaiting handoff).
  /// Historic orders (DELIVERED / COMPLETED / CANCELLED / REFUNDED)
  /// collapse to `completed` so the Historique tab shows a neutral
  /// "Terminé" badge instead of an actionable one.
  /// Minutes elapsed since [placedAt] (≥ 0). Used as the "X min"
  /// label on the card's clock — replaces the previously hardcoded
  /// 0 that showed up on every row.
  int _minutesAgo(DateTime placedAt) {
    final diff = DateTime.now().difference(placedAt).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  AcceptedOrderStatus _displayStatus(String backend) {
    switch (backend) {
      case _kReady:
      case _kInDelivery:
        return AcceptedOrderStatus.readyToPickup;
      case _kDelivered:
      case _kCompleted:
        return AcceptedOrderStatus.completed;
      default:
        return AcceptedOrderStatus.preparing;
    }
  }

  List<SellerOrderSummary> _applyFilterAndSort(List<SellerOrderSummary> source) {
    final scoped = _tab == OrdersTab.accepted
        ? source.where(_isActive).toList()
        : source.where((o) => !_isActive(o)).toList();
    final filtered = _statusFilter == null
        ? scoped
        : scoped.where((o) => _displayStatus(o.status) == _statusFilter).toList();
    return [...filtered]
      ..sort((a, b) {
        return switch (_sortBy) {
          OrdersSortBy.acceptedTime => b.placedAt.compareTo(a.placedAt),
          OrdersSortBy.totalPrice => b.totalEuros.compareTo(a.totalEuros),
        };
      });
  }

  Future<void> _advance(SellerOrderSummary o) async {
    if (_busy.contains(o.id)) return;
    setState(() => _busy.add(o.id));
    try {
      final repo = SellerOrdersRepository.instance;
      switch (o.status) {
        case _kPending:
        case _kConfirmed:
          await repo.startPreparing(o.id);
        case _kPreparing:
          await repo.markReady(o.id);
        default:
          return;
      }
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(o.id));
    }
  }

  String? _ctaLabel(String status) {
    switch (status) {
      case _kPending:
      case _kConfirmed:
        return 'Démarrer la préparation';
      case _kPreparing:
        return 'Marquer prêt';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: [
                  const Gap(AppSizes.md),
                  OrdersTabToggle(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                  const Gap(AppSizes.md),
                  OrdersFilterPanel(
                    statusFilter: _statusFilter,
                    sortBy: _sortBy,
                    onStatusChanged: (s) => setState(() => _statusFilter = s),
                    onSortChanged: (s) => setState(() => _sortBy = s),
                  ),
                  const Gap(AppSizes.spaceBtwSections),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: FutureBuilder<List<SellerOrderSummary>>(
                        future: _ordersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return _ErrorState(
                              error: '${snapshot.error}',
                              onRetry: _refresh,
                            );
                          }
                          final orders = _applyFilterAndSort(snapshot.data ?? const []);
                          if (orders.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                _EmptyOrders(),
                              ],
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.spaceBtwSections,
                            ),
                            itemCount: orders.length,
                            separatorBuilder: (_, _) => const Gap(AppSizes.md),
                            itemBuilder: (context, i) {
                              final o = orders[i];
                              final adapter = AcceptedOrder(
                                id: o.orderNumber,
                                acceptedAt: o.placedAt,
                                status: _displayStatus(o.status),
                                // Real "minutes since the order was placed"
                                // — replaces the hardcoded 0. Caps the
                                // negative case (clock skew on the device)
                                // at 0 so the badge never shows "-1 min".
                                minutesRemaining: _minutesAgo(o.placedAt),
                                totalPrice: o.totalEuros,
                              );
                              final cta = _ctaLabel(o.status);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AcceptedOrderCard(order: adapter),
                                  if (cta != null) ...[
                                    const Gap(AppSizes.sm),
                                    FilledButton(
                                      onPressed: _busy.contains(o.id)
                                          ? null
                                          : () => _advance(o),
                                      child: _busy.contains(o.id)
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(cta),
                                    ),
                                  ],
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            AppAnimations.noResults,
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.contain,
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.sellerOrdersEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 48, color: scheme.error),
        const Gap(AppSizes.md),
        Center(
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        const Gap(AppSizes.md),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}
