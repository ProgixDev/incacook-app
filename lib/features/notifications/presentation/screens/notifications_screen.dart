import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/notifications/controllers/notifications_controller.dart';
import 'package:incacook/features/notifications/domain/app_notification.dart';
import 'package:incacook/features/orders/presentation/screens/order_tracking.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';

/// The notification inbox (the bell). Lists persisted notifications newest
/// first, marks them read on tap, and deep-links order/delivery events to the
/// tracking screen — the same routing the push handler uses.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController _controller =
      Get.isRegistered<NotificationsController>()
          ? NotificationsController.instance
          : Get.put(NotificationsController(), permanent: true);
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _controller.refreshInbox();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 240) {
      _controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onTapNotification(AppNotification n) {
    _controller.markRead(n);
    if (n.type == 'wallet_funds_available') {
      Get.to<void>(() => const WalletScreen());
      return;
    }
    final orderId = n.orderId;
    if (orderId != null &&
        orderId.isNotEmpty &&
        (n.type.startsWith('order_') || n.type.startsWith('delivery_'))) {
      Get.to<void>(() => OrderTrackingScreen(orderId: orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Notifications',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            if (_controller.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: _controller.markAllRead,
              child: const Text('Tout lire'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.loading.value && _controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.error.value != null && _controller.items.isEmpty) {
          // Debug builds append the raw error (status code + message) so a
          // failing inbox is self-diagnosing during testing; release builds
          // keep the friendly message only.
          final detail = kDebugMode ? '\n\n${_controller.error.value}' : '';
          return _InboxMessage(
            icon: Iconsax.warning_2,
            text: 'Impossible de charger les notifications.$detail',
            action: TextButton(
              onPressed: _controller.refreshInbox,
              child: const Text('Réessayer'),
            ),
          );
        }
        if (_controller.items.isEmpty) {
          return const _InboxMessage(
            icon: Iconsax.notification,
            text: 'Aucune notification pour le moment.',
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.refreshInbox,
          child: ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            itemCount: _controller.items.length + (_controller.hasMore.value ? 1 : 0),
            separatorBuilder: (_, _) => const Gap(AppSizes.sm),
            itemBuilder: (context, index) {
              if (index >= _controller.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final n = _controller.items[index];
              return _NotificationTile(
                notification: n,
                onTap: () => _onTapNotification(n),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final unread = !notification.read;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (unread ? scheme.primary : scheme.onSurfaceVariant)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(notification.type),
                size: 20,
                color: unread ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    notification.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    _relativeTime(notification.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (unread) ...[
              const Gap(AppSizes.sm),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(String type) {
    if (type.startsWith('delivery_') || type == 'order_picked_up') {
      return Iconsax.truck;
    }
    if (type.startsWith('order_')) return Iconsax.receipt_1;
    if (type == 'wallet_funds_available') return Iconsax.wallet;
    return Iconsax.notification;
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const Gap(AppSizes.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const Gap(AppSizes.sm), action!],
          ],
        ),
      ),
    );
  }
}
