import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/core/widgets/qr/qr_display_sheet.dart';
import 'package:incacook/features/chat/presentation/chat_navigator.dart';
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
const _kNoDriver = 'NO_DRIVER_AVAILABLE';
const _kCancelled = 'CANCELLED';

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

  /// Seller proactively cancels an order they can't fulfil ("Je ne peux pas
  /// fournir"). Confirms (with an optional note), refunds the buyer + adds a
  /// light strike server-side, then refreshes the list.
  Future<void> _cannotProvide(SellerOrderSummary o) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppTexts.sellerCannotProvideTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppTexts.sellerCannotProvideConfirm),
            const Gap(AppSizes.sm),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: AppTexts.sellerCannotProvideNoteHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppTexts.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppTexts.sellerCannotProvideConfirmCta),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy.add(o.id));
    try {
      final note = noteCtrl.text.trim();
      await SellerOrdersRepository.instance
          .cannotProvide(o.id, note: note.isEmpty ? null : note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.sellerCannotProvideSuccess)),
      );
      await _refresh();
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy.remove(o.id));
    }
  }

  /// Fetches the pickup-proof QR for [orderId] and shows it for the driver to
  /// scan. Surfaces the backend message (e.g. order not ready) on failure.
  Future<void> _showPickupQr(String orderId) async {
    try {
      final qr = await SellerOrdersRepository.instance.fetchPickupQr(orderId);
      if (!mounted) return;
      await showQrModal(
        context,
        title: AppTexts.pickupQrSheetTitle,
        instruction: AppTexts.pickupQrSheetInstruction,
        qrData: qr.qrData,
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppTexts.pickupQrUnavailable)));
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
                              // Seller ↔ driver chat for delivery orders once a
                              // driver is in the picture (READY → a driver is
                              // claiming; IN_DELIVERY → assigned). The backend
                              // derives the driver from the order and rejects
                              // with a SnackBar if none is assigned yet.
                              final showContactDriver =
                                  o.fulfillmentChoice == 'DELIVERY' &&
                                  (o.status == _kReady || o.status == _kInDelivery);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AcceptedOrderCard(order: adapter),
                                  // No driver accepted — awaiting the client's
                                  // decision (switch to pickup / cancel). The
                                  // seller is not penalised.
                                  if (o.status == _kNoDriver) ...[
                                    const Gap(AppSizes.sm),
                                    const _NoDriverBanner(),
                                  ],
                                  // Cancelled with a delivery-incident reason:
                                  // seller couldn't provide (no fault beyond the
                                  // cancel) or driver disappeared (seller still
                                  // paid).
                                  if (o.status == _kCancelled &&
                                      (o.cancellationReason == 'seller_unavailable' ||
                                          o.cancellationReason == 'driver_disappeared' ||
                                          o.cancellationReason == 'seller_cannot_provide')) ...[
                                    const Gap(AppSizes.sm),
                                    _OrderCancelledBanner(reason: o.cancellationReason!),
                                  ],
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
                                  if (showContactDriver) ...[
                                    const Gap(AppSizes.sm),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          ChatNavigator.openSellerDriver(
                                            context: context,
                                            peerName: 'Livreur',
                                            orderId: o.id,
                                            myRole: ParticipantRole.seller,
                                          ),
                                      icon: const Icon(Icons.message_outlined, size: 18),
                                      label: const Text(AppTexts.chatContactDriverCta),
                                    ),
                                    const Gap(AppSizes.sm),
                                    OutlinedButton.icon(
                                      onPressed: () => _showPickupQr(o.id),
                                      icon: const Icon(Icons.qr_code_2, size: 18),
                                      label: const Text(AppTexts.sellerPickupQrCta),
                                    ),
                                  ],
                                  // Seller proactive cancellation — only before
                                  // pickup is confirmed (pre-pickup states).
                                  if (o.status == _kConfirmed ||
                                      o.status == _kPreparing ||
                                      o.status == _kReady) ...[
                                    const Gap(AppSizes.sm),
                                    OutlinedButton.icon(
                                      onPressed: _busy.contains(o.id)
                                          ? null
                                          : () => _cannotProvide(o),
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: const Text(AppTexts.sellerCannotProvideCta),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
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

/// Banner shown on a seller order whose delivery found no driver — the client
/// is deciding whether to switch to pickup or cancel. No seller penalty.
class _NoDriverBanner extends StatelessWidget {
  const _NoDriverBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.no_transfer_outlined, size: 18, color: scheme.onErrorContainer),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              AppTexts.sellerNoDriverWaiting,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner on a seller order cancelled by a delivery incident: seller couldn't
/// provide the order at pickup, or the driver disappeared after pickup (seller
/// is still paid in that case).
class _OrderCancelledBanner extends StatelessWidget {
  const _OrderCancelledBanner({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final message = switch (reason) {
      'driver_disappeared' => AppTexts.sellerDriverIncidentMaintained,
      'seller_cannot_provide' => AppTexts.sellerCannotProvideBanner,
      _ => AppTexts.sellerOrderCancelledNoFood,
    };
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, size: 18, color: scheme.onErrorContainer),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
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
