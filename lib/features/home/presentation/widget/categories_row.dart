import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/enums/food_enums.dart';
import 'package:vinted_v2/features/home/presentation/widget/category_pill.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key, required this.selected, required this.onSelect});

  final SellerCategory? selected;
  final ValueChanged<SellerCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(SellerCategory?, String, String?)>[
      (null, AppTexts.homeCategoryAll, AppImages.all),
      (
        SellerCategory.faitMaison,
        SellerCategory.faitMaison.label,
        SellerCategory.faitMaison.imagePath,
      ),
      (
        SellerCategory.traiteur,
        SellerCategory.traiteur.label,
        SellerCategory.traiteur.imagePath,
      ),
      (
        SellerCategory.restaurant,
        SellerCategory.restaurant.label,
        SellerCategory.restaurant.imagePath,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
        itemBuilder: (context, index) {
          final (cat, label, imagePath) = items[index];
          return CategoryPill(
            label: label,
            imagePath: imagePath,
            selected: selected == cat,
            onTap: () => onSelect(cat),
          );
        },
      ),
    );
  }
}