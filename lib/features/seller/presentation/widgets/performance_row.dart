import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/seller/domain/performance_metric.dart';

class PerformanceRow extends StatelessWidget {
  const PerformanceRow({super.key, required this.metric});

  final PerformanceMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(metric.type.icon, size: 16, color: metric.type.color),
            const Gap(AppSizes.sm),
            Text(
              metric.type.label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        const Gap(AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: metric.percent / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.lightGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(metric.type.color),
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            Text(
              '${metric.percent}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: metric.type.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
