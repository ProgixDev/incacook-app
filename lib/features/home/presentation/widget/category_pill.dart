import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.selected,
    this.imagePath,
    this.icon,
    this.emoji,
    this.onTap,
  });

  final String label;
  final String? imagePath;
  final IconData? icon;
  final String? emoji;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = selected ? AppColors.white : AppColors.secondary;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: contentColor,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(imagePath!, fit: BoxFit.contain),
              ),
              const Gap(AppSizes.sm),
            ] else if (icon != null) ...[
              Icon(icon, size: 16, color: contentColor),
              const Gap(AppSizes.sm - 2),
            ] else if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const Gap(AppSizes.sm),
            ],
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
