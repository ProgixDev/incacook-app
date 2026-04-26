import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/home/controllers/filter_controller.dart';

class ActiveFiltersStrip extends StatelessWidget {
  const ActiveFiltersStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FilterController.instance;
    return Obx(() {
      final f = controller.filter.value;
      if (f.isEmpty) return const SizedBox.shrink();

      final chips = <Widget>[];

      if (f.category != null) {
        chips.add(
          _RemovableChip(
            label: f.category!.label,
            onRemove: () => controller.setCategory(null),
          ),
        );
      }
      for (final c in f.cuisines) {
        chips.add(
          _RemovableChip(
            label: c.label,
            onRemove: () => controller.toggleCuisine(c),
          ),
        );
      }
      for (final d in f.diets) {
        chips.add(
          _RemovableChip(
            label: d.label,
            tint: d.color,
            onRemove: () => controller.toggleDiet(d),
          ),
        );
      }
      for (final d in f.dishTypes) {
        chips.add(
          _RemovableChip(
            label: d.label,
            onRemove: () => controller.toggleDishType(d),
          ),
        );
      }
      if (f.maxDistanceKm != null) {
        chips.add(
          _RemovableChip(
            label:
                '${AppTexts.filterDistanceUpTo} ${f.maxDistanceKm!.toStringAsFixed(0)} ${AppTexts.filterDistanceKmSuffix}',
            onRemove: () => controller.setMaxDistance(null),
          ),
        );
      }
      if (f.inStockOnly) {
        chips.add(
          _RemovableChip(
            label: AppTexts.filterInStockOnly,
            onRemove: () => controller.setInStockOnly(false),
          ),
        );
      }

      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const Gap(AppSizes.sm),
          itemBuilder: (_, i) => chips[i],
        ),
      );
    });
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({
    required this.label,
    required this.onRemove,
    this.tint,
  });

  final String label;
  final VoidCallback onRemove;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? AppColors.primary;
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md - 4,
          vertical: AppSizes.xs + 2,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(AppSizes.xs),
            Icon(Icons.close, size: 14, color: accent),
          ],
        ),
      ),
    );
  }
}
