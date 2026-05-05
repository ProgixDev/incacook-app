import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/client/presentation/widget/category_pill.dart';

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
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        children: [
          CategoryPill(
            label: AppTexts.homeCategoryAll,
            iconPath: AppImages.all,
            selected: selected == MapFilter.all,
            onTap: () => onSelect(MapFilter.all),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategorySocialShort,
            iconPath: AppImages.homeMade,
            selected: selected == MapFilter.social,
            onTap: () => onSelect(MapFilter.social),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategoryTraiteurShort,
            iconPath: AppImages.bulk,
            selected: selected == MapFilter.traiteur,
            onTap: () => onSelect(MapFilter.traiteur),
          ),
          const Gap(AppSizes.sm),
          CategoryPill(
            label: AppTexts.homeCategoryRestaurantShort,
            iconPath: AppImages.restaurants,
            selected: selected == MapFilter.restaurant,
            onTap: () => onSelect(MapFilter.restaurant),
          ),
        ],
      ),
    );
  }
}
