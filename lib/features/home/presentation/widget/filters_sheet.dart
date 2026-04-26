import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/core/utils/popups/blurred_modal_sheet.dart';
import 'package:homemade/core/widgets/misc/drag_handle.dart';
import 'package:homemade/features/home/controllers/filter_controller.dart';

class FiltersSheet extends StatelessWidget {
  const FiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showBlurredModalBottomSheet<void>(
      context: context,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = FilterController.instance;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const DragHandle(color: AppColors.secondary),
            const _Header(),
            Divider(
              height: 1,
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
            Expanded(
              child: Obx(() {
                final f = controller.filter.value;
                final dishes = f.applicableDishTypes;
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.md,
                  ),
                  children: [
                    _Section(
                      title: AppTexts.filterCategoryLabel,
                      child: _CategoryGroup(
                        selected: f.category,
                        onSelect: controller.setCategory,
                      ),
                    ),
                    _Section(
                      title: AppTexts.filterCuisineLabel,
                      child: _CuisineGroup(
                        selected: f.cuisines,
                        onToggle: controller.toggleCuisine,
                      ),
                    ),
                    _Section(
                      title: AppTexts.filterDietLabel,
                      child: _DietGroup(
                        selected: f.diets,
                        onToggle: controller.toggleDiet,
                      ),
                    ),
                    if (dishes.isNotEmpty)
                      _Section(
                        title: AppTexts.filterDishLabel,
                        child: _DishGroup(
                          available: dishes,
                          selected: f.dishTypes,
                          onToggle: controller.toggleDishType,
                        ),
                      ),
                    // _Section(
                    //   title: AppTexts.filterDistanceLabel,
                    //   child: _DistanceSlider(
                    //     maxKm:
                    //         f.category?.maxRadiusKm ??
                    //         ListingFilter.standardRadiusKm,
                    //     valueKm: f.maxDistanceKm,
                    //     onChanged: controller.setMaxDistance,
                    //   ),
                    // ),
                    // _Section(
                    //   title: AppTexts.filterAvailabilityLabel,
                    //   child: _StockToggle(
                    //     value: f.inStockOnly,
                    //     onChanged: controller.setInStockOnly,
                    //   ),
                    // ),
                    const Gap(AppSizes.md),
                  ],
                );
              }),
            ),
            _ApplyBar(
              onApply: () => Navigator.of(context).pop(),
              onReset: controller.reset,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppTexts.filterSheetTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(AppSizes.sm + 2),
          child,
        ],
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.selected, required this.onSelect});

  final SellerCategory? selected;
  final ValueChanged<SellerCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        _Chip(
          label: AppTexts.homeCategoryAll,
          selected: selected == null,
          onTap: () => onSelect(null),
        ),
        for (final cat in SellerCategory.values)
          _Chip(
            label: cat.label,
            selected: selected == cat,
            onTap: () => onSelect(cat),
          ),
      ],
    );
  }
}

class _CuisineGroup extends StatelessWidget {
  const _CuisineGroup({required this.selected, required this.onToggle});

  final Set<CuisineType> selected;
  final ValueChanged<CuisineType> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final c in CuisineType.values)
          _Chip(
            label: c.label,
            selected: selected.contains(c),
            onTap: () => onToggle(c),
          ),
      ],
    );
  }
}

class _DietGroup extends StatelessWidget {
  const _DietGroup({required this.selected, required this.onToggle});

  final Set<DietaryTag> selected;
  final ValueChanged<DietaryTag> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final d in DietaryTag.values)
          _Chip(
            label: d.label,
            selected: selected.contains(d),
            tint: d.color,
            onTap: () => onToggle(d),
          ),
      ],
    );
  }
}

class _DishGroup extends StatelessWidget {
  const _DishGroup({
    required this.available,
    required this.selected,
    required this.onToggle,
  });

  final List<DishType> available;
  final Set<DishType> selected;
  final ValueChanged<DishType> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final d in available)
          _Chip(
            label: d.label,
            selected: selected.contains(d),
            onTap: () => onToggle(d),
          ),
      ],
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.onApply, required this.onReset});

  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.sm,
        ),
        child: Obx(() {
          final count = FilterController.instance.activeCount;
          final hasActive = count > 0;
          return Row(
            children: [
              _ResetCircleButton(enabled: hasActive, onTap: onReset),
              const Gap(AppSizes.sm + 2),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApply,
                  child: Text(
                    count == 0
                        ? AppTexts.filterSeeResults
                        : '${AppTexts.filterApply} ($count)',
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ResetCircleButton extends StatelessWidget {
  const _ResetCircleButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? AppColors.secondary : AppColors.grey;
    final bg = enabled ? AppColors.white : AppColors.lightGrey;
    return Tooltip(
      message: AppTexts.filterReset,
      child: Material(
        color: bg,
        shape: CircleBorder(
          side: BorderSide(
            color: accent.withValues(alpha: enabled ? 0.6 : 0.25),
            width: 1,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              Icons.refresh_rounded,
              size: 22,
              color: accent.withValues(alpha: enabled ? 1.0 : 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? AppColors.secondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.accent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : AppColors.grey.withValues(alpha: 0.25),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.white : accent,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
