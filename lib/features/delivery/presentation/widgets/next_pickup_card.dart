import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/delivery/data/delivery_driver_mock_data.dart';

/// Hero card at the top of the Drive sheet — promotes the next scheduled
/// pickup with seller, address, ETA + distance chips, and a primary
/// Navigate CTA.
class NextPickupCard extends StatelessWidget {
  const NextPickupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final pickups = DeliveryDriverMockData.upcomingPickups();
    if (pickups.isEmpty) return const SizedBox.shrink();
    final pickup = pickups.first;

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          //* Hero card radius — matches `FoodListingCard`'s soft modern
          //* feel rather than the smaller `cardRadiusLg` used on list cards.
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
                AppTexts.deliveryDashboardNextPickupLabel.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const Gap(AppSizes.sm + 2),
              Text(
                pickup.sellerName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  height: 1.1,
                ),
              ),
              const Gap(AppSizes.xs + 2),
              Text(
                pickup.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSizes.md + 2),
              Row(
                children: [
                  _InfoChip(icon: Iconsax.clock, label: pickup.etaLabel),
                  const Gap(AppSizes.sm),
                  //? Mock distance — `ScheduledPickup` has no distance
                  //? field yet; wire to a routing calc when we have one.
                  const _InfoChip(icon: Iconsax.location5, label: '1,2 km'),
                ],
              ),
              const Gap(AppSizes.md + 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  //* Defaults to `scheme.primary` / `onPrimary` — only the
                  //* shape, padding, and weight need overriding.
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Iconsax.arrow_right_3, size: 18),
                  label: const Text(AppTexts.deliveryDashboardNavigateCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 4,
        vertical: AppSizes.xs + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurface),
          const Gap(6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
