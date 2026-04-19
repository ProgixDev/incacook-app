import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.imagePath,
    required this.selected,
    this.onTap,
  });

  final String label;
  final String imagePath;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const double pillHeight = 66;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: selected ? AppColors.accent : AppColors.secondary,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,

        padding: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.accent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: pillHeight,
              width: pillHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                color: AppColors.lightGrey,
                border: BoxBorder.all(
                  color: AppColors.darkGrey.withValues(alpha: 0.4),
                  width: 0.2,
                ),
              ),
              child: CustomCircularImage(image: imagePath, fit: BoxFit.contain),
            ),
            const Gap(AppSizes.sm),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
