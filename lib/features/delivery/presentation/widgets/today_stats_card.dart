import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/delivery/data/delivery_driver_mock_data.dart';

/// Today summary card — earnings as the hero number, with online time
/// and completed deliveries as secondary stat tiles below.
class TodayStatsCard extends StatelessWidget {
  const TodayStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = DeliveryDriverMockData.todayStats();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hours = stats.onlineTime.inHours;
    final minutes = stats.onlineTime.inMinutes.remainder(60);
    final onlineLabel = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    final earnings = '€${stats.earnings.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.deliveryDashboardTodayLabel.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const Gap(AppSizes.sm + 2),
              Text(
                earnings,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  height: 1.0,
                ),
              ),
              const Gap(AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Iconsax.clock,
                      value: onlineLabel,
                      label: AppTexts.deliveryDashboardOnlineLabel
                          .toUpperCase(),
                    ),
                  ),
                  const Gap(AppSizes.sm + 2),
                  Expanded(
                    child: _StatTile(
                      icon: Iconsax.driver_2,
                      value: stats.rides.toString().padLeft(2, '0'),
                      label: AppTexts.deliveryDashboardDeliveriesLabel
                          .toUpperCase(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: scheme.onSurfaceVariant),
              const Gap(6),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Gap(AppSizes.sm),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
