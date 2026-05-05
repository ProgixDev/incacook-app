import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/client/controllers/filter_controller.dart';
import 'package:homemade/features/client/presentation/widget/category_pill.dart';

//* Category browse hub: a horizontal pill strip for the 3 main "kitchen
//* style" categories (+ Tout), and below it a circular-icon strip per
//* subcategory group (cuisines, diets, dishes). Visibility of the dish
//* strip is driven by [DishType.valuesFor], so faitMaison naturally hides
//* it (matches the brief: dish types only apply to traiteur / restaurant).
class CategoryHubSection extends StatelessWidget {
  const CategoryHubSection({super.key});

  //* visual mappings — icon assets live with the UI, not on the enums, so
  //* the domain model stays asset-agnostic.
  static const Map<SellerCategory, String> _categoryIcon = {
    SellerCategory.faitMaison: AppImages.homeMade,
    SellerCategory.traiteur: AppImages.bulk,
    SellerCategory.restaurant: AppImages.restaurants,
  };

  static const Map<CuisineType, String> _cuisineIcon = {
    CuisineType.orientale: AppImages.eastern,
    CuisineType.francaise: AppImages.french,
    CuisineType.africaine: AppImages.african,
    CuisineType.portugaise: AppImages.portuguese,
    CuisineType.italienne: AppImages.italian,
    CuisineType.espagnole: AppImages.spanish,
    CuisineType.latine: AppImages.latin,
  };

  static const Map<DietaryTag, String> _dietIcon = {
    DietaryTag.halal: AppImages.halal,
    DietaryTag.vegan: AppImages.vegan,
    DietaryTag.glutenFree: AppImages.glutenFree,
    DietaryTag.casher: AppImages.casher,
  };

  static const Map<DishType, String> _dishIcon = {
    DishType.entree: AppImages.appetizer,
    DishType.plat: AppImages.dish,
    DishType.dessert: AppImages.dessert,
    DishType.cocktailDinatoire: AppImages.cocktail,
  };

  @override
  Widget build(BuildContext context) {
    final filter = FilterController.instance;

    return Obx(() {
      final f = filter.filter.value;
      final selectedCat = f.category;
      final visibleDishes = selectedCat == null
          ? const <DishType>[]
          : DishType.valuesFor(selectedCat);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* main pills (Tout + 3 categories)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              children: [
                CategoryPill(
                  label: AppTexts.homeCategoryAll,
                  iconPath: AppImages.all,
                  selected: selectedCat == null,
                  onTap: () => filter.setCategory(null),
                ),
                const Gap(AppSizes.sm),
                for (final cat in SellerCategory.values) ...[
                  CategoryPill(
                    label: cat.shortLabel,
                    iconPath: _categoryIcon[cat]!,
                    selected: selectedCat == cat,
                    onTap: () => filter.setCategory(cat),
                  ),
                  const Gap(AppSizes.sm),
                ],
              ],
            ),
          ),
          const Gap(AppSizes.md),

          //* Type de cuisine — same set under every main category
          _SubcategoryStrip(
            title: AppTexts.categoryGroupCuisine,
            children: [
              for (final cuisine in CuisineType.values)
                _SubcategoryCircle(
                  label: cuisine.label,
                  iconPath: _cuisineIcon[cuisine]!,
                  selected: f.cuisines.contains(cuisine),
                  onTap: () => filter.toggleCuisine(cuisine),
                ),
            ],
          ),
          const Gap(AppSizes.md),

          //* Régime alimentaire — same set under every main category
          _SubcategoryStrip(
            title: AppTexts.categoryGroupDiet,
            children: [
              for (final diet in DietaryTag.values)
                _SubcategoryCircle(
                  label: diet.label,
                  iconPath: _dietIcon[diet]!,
                  selected: f.diets.contains(diet),
                  onTap: () => filter.toggleDiet(diet),
                ),
            ],
          ),

          //* Type de plat — only when current main cat exposes any (via
          //* DishType.availableFor). faitMaison hides this; traiteur shows
          //* all four; restaurant shows three (no cocktail).
          if (visibleDishes.isNotEmpty) ...[
            const Gap(AppSizes.md),
            _SubcategoryStrip(
              title: AppTexts.categoryGroupDish,
              children: [
                for (final dish in visibleDishes)
                  _SubcategoryCircle(
                    label: dish.label,
                    iconPath: _dishIcon[dish]!,
                    selected: f.dishTypes.contains(dish),
                    onTap: () => filter.toggleDishType(dish),
                  ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _SubcategoryStrip extends StatelessWidget {
  const _SubcategoryStrip({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Gap(AppSizes.sm),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            itemCount: children.length,
            separatorBuilder: (_, _) => const Gap(AppSizes.sm + 4),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ],
    );
  }
}

class _SubcategoryCircle extends StatelessWidget {
  const _SubcategoryCircle({
    required this.label,
    required this.iconPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 76,
        //* tween 0 → 1 on selection so the circle's fill cross-fades from
        //* frosted glass into the brand pill instead of snapping. Same
        //* curve/duration as _MainPill for a unified feel.
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: selected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            final bgTint = Color.lerp(
              colors.frostedTint,
              colors.selectedSurface,
              t,
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FrostedSurface(
                  shape: BoxShape.circle,
                  tint: bgTint,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.sm + 2),
                      child: Image.asset(iconPath, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const Gap(AppSizes.xs),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
