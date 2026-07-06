import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/seller/data/seller_orders_repository.dart';

class TodaySnapshotCard extends StatefulWidget {
  const TodaySnapshotCard({super.key});

  @override
  State<TodaySnapshotCard> createState() => _TodaySnapshotCardState();
}

class _TodaySnapshotCardState extends State<TodaySnapshotCard> {
  late final Future<_TodaySellerStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.sellerHomeTodayLabel,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(AppSizes.lg),
          FutureBuilder<_TodaySellerStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final loading = snapshot.connectionState != ConnectionState.done;
              final stats = snapshot.data;

              return Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      iconAsset: AppImages.revenue,
                      value: loading
                          ? '...'
                          : stats == null
                          ? '--'
                          : _formatEuros(stats.revenueCents),
                      label: AppTexts.sellerHomeTodayRevenue,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      iconAsset: AppImages.orders,
                      value: loading ? '...' : '${stats?.orderCount ?? 0}',
                      label: AppTexts.sellerHomeTodayOrders,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<_TodaySellerStats> _loadStats() async {
    final orders = await SellerOrdersRepository.instance.listIncoming(
      limit: 100,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    var revenueCents = 0;
    var orderCount = 0;

    for (final order in orders) {
      final placedAt = order.placedAt.toLocal();
      if (placedAt.isBefore(today) || !placedAt.isBefore(tomorrow)) {
        continue;
      }
      if (!_paidSellerStatuses.contains(order.status)) {
        continue;
      }
      orderCount += 1;
      revenueCents += order.sellerEarningsCents;
    }

    return _TodaySellerStats(
      revenueCents: revenueCents,
      orderCount: orderCount,
    );
  }

  String _formatEuros(int cents) => '€${(cents / 100).toStringAsFixed(2)}';
}

const Set<String> _paidSellerStatuses = {
  'CONFIRMED',
  'PREPARING',
  'READY',
  'PICKED_UP',
  'IN_DELIVERY',
  'DELIVERED',
  'COMPLETED',
};

class _TodaySellerStats {
  const _TodaySellerStats({
    required this.revenueCents,
    required this.orderCount,
  });

  final int revenueCents;
  final int orderCount;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(iconAsset, width: 22, height: 22),
            const Gap(AppSizes.sm),
            Flexible(
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Gap(AppSizes.xs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
