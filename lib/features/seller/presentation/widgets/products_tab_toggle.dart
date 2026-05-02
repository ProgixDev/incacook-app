import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

enum ProductsTab { available, notAvailable }

class ProductsTabToggle extends StatelessWidget {
  const ProductsTabToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onLayoutToggle,
  });

  final ProductsTab selected;
  final ValueChanged<ProductsTab> onChanged;
  final VoidCallback? onLayoutToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = DeviceUtils.getScreenHeight(context) * 0.05;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: height,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabSegment(
                    label: AppTexts.sellerProductsTabAvailable,
                    selected: selected == ProductsTab.available,
                    onTap: () => onChanged(ProductsTab.available),
                  ),
                ),
                Expanded(
                  child: _TabSegment(
                    label: AppTexts.sellerProductsTabNotAvailable,
                    selected: selected == ProductsTab.notAvailable,
                    onTap: () => onChanged(ProductsTab.notAvailable),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(8),
        GestureDetector(
          onTap: onLayoutToggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Iconsax.element_3, color: scheme.onSurface, size: 20),
          ),
        ),
      ],
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bg = selected ? scheme.primary : Colors.transparent;
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          style: textTheme.bodyMedium!.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
