import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/delivery/data/delivery_driver_mock_data.dart';
import 'package:homemade/features/delivery/presentation/widgets/delivery_nav_bar.dart';
import 'package:homemade/features/delivery/presentation/widgets/scheduled_pickups_section.dart';
import 'package:homemade/features/delivery/presentation/widgets/weekly_challenges_section.dart';

class DeliveryBottomSheet extends StatefulWidget {
  const DeliveryBottomSheet({super.key});

  @override
  State<DeliveryBottomSheet> createState() => _DeliveryBottomSheetState();
}

class _DeliveryBottomSheetState extends State<DeliveryBottomSheet> {
  static const double _expandedFraction = 0.9;
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(double collapsedFraction) {
    final size = _controller.size;
    final midpoint = (collapsedFraction + _expandedFraction) / 2;
    final target = size < midpoint ? _expandedFraction : collapsedFraction;
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    //* The collapsed sheet is just tall enough to show the full nav bar
    //* (including its overhang) plus the bottom safe area.
    final collapsedFraction =
        (DeliveryNavBar.totalHeight + MediaQuery.of(context).padding.bottom) / MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: collapsedFraction,
      minChildSize: collapsedFraction,
      maxChildSize: _expandedFraction,
      snap: true,
      snapSizes: [collapsedFraction, _expandedFraction],
      builder: (context, scrollController) {
        final scheme = Theme.of(context).colorScheme;
        return Column(
          children: [
            GestureDetector(
              onTap: () => _toggle(collapsedFraction),
              behavior: HitTestBehavior.opaque,
              child: const DeliveryNavBar(),
            ),
            Expanded(
              child: Container(
                color: scheme.surface,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  children: const [
                    Gap(AppSizes.lg),
                    WeeklyChallengesSection(),
                    Gap(AppSizes.lg),
                    _DailyStatsSection(),
                    Gap(AppSizes.md),
                    _DrivingPreferencesRow(),
                    Gap(AppSizes.lg),
                    ScheduledPickupsSection(),
                    Gap(AppSizes.lg),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DailyStatsSection extends StatelessWidget {
  const _DailyStatsSection();

  @override
  Widget build(BuildContext context) {
    final stats = DeliveryDriverMockData.todayStats();
    final scheme = Theme.of(context).colorScheme;
    final hours = stats.onlineTime.inHours;
    final minutes = stats.onlineTime.inMinutes.remainder(60);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.lg,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'Earnings',
                value: '\$${stats.earnings.toStringAsFixed(1)}',
              ),
            ),
            Expanded(
              child: _StatCell(
                label: 'Online',
                value: '${hours}hr ${minutes}min',
              ),
            ),
            Expanded(
              child: _StatCell(
                label: 'Rides',
                value: stats.rides.toString().padLeft(2, '0'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Gap(AppSizes.xs + 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _DrivingPreferencesRow extends StatelessWidget {
  const _DrivingPreferencesRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md + 2,
            ),
            child: Row(
              children: [
                Icon(Iconsax.setting_4, size: 22, color: scheme.onSurface),
                const Gap(AppSizes.md),
                Expanded(
                  child: Text(
                    'Driving Preferences',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
