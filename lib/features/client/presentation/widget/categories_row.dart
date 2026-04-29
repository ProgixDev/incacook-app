import 'package:flutter/material.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/features/client/presentation/widget/category_pill.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final SellerCategory? selected;
  final ValueChanged<SellerCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget pillFor(SellerCategory cat) => CategoryPill(
      label: cat.shortLabel,
      imagePath: cat.imagePath,
      selected: selected == cat,
      onTap: () => onSelect(cat),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        //* GridView auto-consumes MediaQuery main-axis padding when null —
        //* explicit zero stops it from inheriting the screen's safe-area
        //* insets and adding phantom top/bottom space.
        padding: EdgeInsets.zero,
        crossAxisCount: 3,
        mainAxisSpacing: AppSizes.sm + 2,
        crossAxisSpacing: AppSizes.sm + 2,
        childAspectRatio: 1, //* square tiles
        children: [
          //* Row 1 — three "active" categories.
          pillFor(SellerCategory.faitMaison),
          pillFor(SellerCategory.traiteur),
          pillFor(SellerCategory.restaurant),
          //* Row 2 — empty | "all" centered | empty.
          const SizedBox.shrink(),
          CategoryPill(
            label: AppTexts.homeCategoryAll,
            imagePath: AppImages.all,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
