import 'package:flutter/material.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    super.key,
    required this.onAddToCart,
    required this.onOrder,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    const double height = 64;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: bottomSafe + AppSizes.md,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _PillButton(
                label: AppTexts.productAddToCart,
                onTap: onAddToCart,
                background: AppColors.accent,
                foreground: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _PillButton(
                label: AppTexts.productOrder,
                onTap: onOrder,
                background: AppColors.secondary,
                foreground: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
