import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/presentation/widget/category_pill.dart';

enum MapFilter { all, social, traiteur, restaurant, urgent }

class MapFilterBar extends StatelessWidget {
  const MapFilterBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final MapFilter selected;
  final ValueChanged<MapFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        children: [
          CategoryPill(
            label: AppTexts.homeCategoryAll,
            imagePath: AppImages.all,
            selected: selected == MapFilter.all,
            onTap: () => onSelect(MapFilter.all),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategorySocial,
            imagePath: AppImages.individual,
            selected: selected == MapFilter.social,
            onTap: () => onSelect(MapFilter.social),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategoryTraiteur,
            imagePath: AppImages.bulk,
            selected: selected == MapFilter.traiteur,
            onTap: () => onSelect(MapFilter.traiteur),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategoryRestaurant,
            imagePath: AppImages.restaurants,
            selected: selected == MapFilter.restaurant,
            onTap: () => onSelect(MapFilter.restaurant),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.mapCategoryUrgent,
            icon: Iconsax.clock,
            selected: selected == MapFilter.urgent,
            onTap: () => onSelect(MapFilter.urgent),
          ),
        ],
      ),
    );
  }
}
