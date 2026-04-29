import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/delivery/data/delivery_driver_mock_data.dart';
import 'package:homemade/features/delivery/domain/delivery_driver_models.dart';

class ScheduledPickupsSection extends StatelessWidget {
  const ScheduledPickupsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final pickups = DeliveryDriverMockData.upcomingPickups();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'Your Scheduled Pickups',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const Gap(AppSizes.md),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            itemCount: pickups.length,
            separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
            itemBuilder: (_, i) => _PickupCard(pickup: pickups[i]),
          ),
        ),
      ],
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.pickup});

  final ScheduledPickup pickup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //? placeholder for the Mapbox Static Image preview — wire to
          //? https://api.mapbox.com/styles/v1/mapbox/light-v11/static/...
          //? once we want real previews. Cheap to render compared to a live
          //? MapWidget per card.
          Container(
            height: 120,
            color: scheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Iconsax.location5,
              size: 32,
              color: scheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup.sellerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  pickup.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSizes.xs),
                Row(
                  children: [
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const Gap(4),
                    Text(
                      pickup.etaLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
