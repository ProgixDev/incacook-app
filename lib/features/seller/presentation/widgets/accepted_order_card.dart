import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/seller/domain/accepted_order.dart';

class AcceptedOrderCard extends StatelessWidget {
  const AcceptedOrderCard({super.key, required this.order, this.onTap});

  final AcceptedOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = DateFormat('d MMM y', 'fr_FR').format(order.acceptedAt);
    final timeLabel = DateFormat.jm('fr_FR').format(order.acceptedAt);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(40),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Iconsax.box, color: scheme.onSurface, size: 26),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(AppSizes.xs),
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(AppSizes.sm),
                      Text(
                        '|',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(AppSizes.sm),
                      Text(
                        timeLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(AppSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: order.status),
                const Gap(AppSizes.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const Gap(AppSizes.xs),
                    Text(
                      '${order.minutesRemaining} ${AppTexts.sellerOrdersMinutesSuffix}',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AcceptedOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (bg, fg, label) = switch (status) {
      AcceptedOrderStatus.readyToPickup => (
        scheme.primary,
        scheme.onPrimary,
        AppTexts.sellerOrdersFilterReadyToPickup,
      ),
      AcceptedOrderStatus.preparing => (
        //? high-contrast dark badge — inverseSurface flips correctly across
        //? modes (dark pill in light, light pill in dark) for the same
        //? "stand-out neutral" semantic.
        scheme.inverseSurface,
        scheme.onInverseSurface,
        AppTexts.sellerOrdersFilterPreparing,
      ),
      AcceptedOrderStatus.completed => (
        //? muted surface for historic orders — signals "finished, no
        //? further action" without competing visually with active badges.
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        AppTexts.sellerOrdersFilterCompleted,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
