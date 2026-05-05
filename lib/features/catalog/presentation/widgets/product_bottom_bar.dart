import 'package:flutter/material.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: bottomSafe + AppSizes.md,
      ),
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(height / 2),
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: height - 12,
          child: Row(
            children: [
              //* "Add to cart" reads as a secondary action — transparent so
              //* the frosted bar shows through, foreground stays onSurface.
              Expanded(
                child: _PillButton(
                  label: AppTexts.productAddToCart,
                  onTap: onAddToCart,
                  background: Colors.transparent,
                  foreground: scheme.onSurface,
                ),
              ),
              //* "Order" is the primary CTA — solid selectedSurface fill
              //* so it pops against the frosted bar.
              Expanded(
                child: _PillButton(
                  label: AppTexts.productOrder,
                  onTap: onOrder,
                  background: colors.selectedSurface,
                  foreground: colors.selectedOnSurface,
                ),
              ),
            ],
          ),
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
      behavior: HitTestBehavior.opaque,
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
