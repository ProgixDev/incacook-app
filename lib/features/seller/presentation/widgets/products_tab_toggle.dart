import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

enum ProductsTab { available, notAvailable }

class ProductsTabToggle extends StatefulWidget {
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
  State<ProductsTabToggle> createState() => _ProductsTabToggleState();
}

class _ProductsTabToggleState extends State<ProductsTabToggle> {
  //? tabs are hidden until the layout button is tapped — reveals them
  //? sliding in from the right of the row.
  bool _expanded = false;

  static const _animDuration = Duration(milliseconds: 320);
  static const _animCurve = Curves.easeOutCubic;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    widget.onLayoutToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = DeviceUtils.getScreenHeight(context) * 0.05;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            //? ClipRect keeps the off-screen tabs from leaking past the
            //? Expanded slot during the slide.
            child: ClipRect(
              child: AnimatedSlide(
                duration: _animDuration,
                curve: _animCurve,
                //? Offset.dx == 1 → translated right by full child width
                //? (parked just off the right edge of the Expanded slot).
                offset: _expanded ? Offset.zero : const Offset(1.0, 0),
                child: AnimatedOpacity(
                  duration: _animDuration,
                  curve: _animCurve,
                  opacity: _expanded ? 1.0 : 0.0,
                  child: FrostedSurface(
                    borderRadius: BorderRadius.circular(40),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabSegment(
                            label: AppTexts.sellerProductsTabAvailable,
                            selected: widget.selected == ProductsTab.available,
                            onTap: () =>
                                widget.onChanged(ProductsTab.available),
                          ),
                        ),
                        Expanded(
                          child: _TabSegment(
                            label: AppTexts.sellerProductsTabNotAvailable,
                            selected:
                                widget.selected == ProductsTab.notAvailable,
                            onTap: () =>
                                widget.onChanged(ProductsTab.notAvailable),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: _toggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: height,
              child: FrostedSurface(
                borderRadius: BorderRadius.circular(40),
                child: Center(
                  child: AnimatedRotation(
                    duration: _animDuration,
                    curve: _animCurve,
                    //? quarter-turn cue so the user has feedback that the
                    //? button is "open" while the tabs are showing.
                    turns: _expanded ? 0.125 : 0,
                    child: Icon(
                      Iconsax.element_3,
                      color: scheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
