import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class TodaySnapshotCard extends StatelessWidget {
  const TodaySnapshotCard({super.key});

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
          Row(
            children: const [
              Expanded(
                child: _StatTile(
                  iconAsset: AppImages.revenue,
                  value: '€34.50',
                  label: AppTexts.sellerHomeTodayRevenue,
                ),
              ),
              Expanded(
                child: _StatTile(
                  iconAsset: AppImages.orders,
                  value: '12',
                  label: AppTexts.sellerHomeTodayOrders,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
