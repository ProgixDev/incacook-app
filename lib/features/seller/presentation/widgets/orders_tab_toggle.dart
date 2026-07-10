import 'package:flutter/material.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

enum OrdersTab { toAccept, accepted, history }

class OrdersTabToggle extends StatelessWidget {
  const OrdersTabToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final OrdersTab selected;
  final ValueChanged<OrdersTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DeviceUtils.getScreenHeight(context) * 0.05,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(40),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _TabSegment(
                label: AppTexts.sellerOrdersTabToAccept,
                selected: selected == OrdersTab.toAccept,
                onTap: () => onChanged(OrdersTab.toAccept),
              ),
            ),
            Expanded(
              child: _TabSegment(
                label: AppTexts.sellerOrdersTabAccepted,
                selected: selected == OrdersTab.accepted,
                onTap: () => onChanged(OrdersTab.accepted),
              ),
            ),
            Expanded(
              child: _TabSegment(
                label: AppTexts.sellerOrdersTabHistory,
                selected: selected == OrdersTab.history,
                onTap: () => onChanged(OrdersTab.history),
              ),
            ),
          ],
        ),
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
