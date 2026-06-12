import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/navigation/nav_tab.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_controller.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, required this.tabs});

  final List<NavTab> tabs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(tabs: tabs));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Obx(() => controller.tabs[controller.selectedIndex.value].screen),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.md,
          0,
          AppSizes.md,
          DeviceUtils.getBottomNavigationBarHeight() / 1.5,
        ),
        child: Obx(
          () => DecoratedBox(
            //* shadow lives on an outer DecoratedBox so the FrostedSurface's
            //* clip doesn't swallow it.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FrostedSurface(
              borderRadius: BorderRadius.circular(48),
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(controller.tabs.length, (index) {
                  final tab = controller.tabs[index];
                  final selected = controller.selectedIndex.value == index;
                  final item = _NavItem(
                    icon: tab.icon,
                    label: tab.label,
                    selected: selected,
                    onTap: () => controller.selectedIndex.value = index,
                  );
                  // Only the selected item carries a label and can get long
                  // ("Commandes"). Make it flexible so it shrinks/ellipsises
                  // instead of overflowing on narrow screens; the icon-only
                  // unselected items keep their natural size, and spaceBetween
                  // still distributes the gaps when there's room.
                  return selected ? Flexible(child: item) : item;
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final selectedFg = colors.selectedOnSurface;
    final unselectedFg = scheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.selectedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        //? Only the selected item shows its label. No AnimatedSize here: it
        //? hands its subtree an unbounded width, which stops the label's
        //? Flexible from ellipsising → overflow on narrow bars. A plain Row
        //? keeps the bounded constraint flowing so the label shrinks to fit.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? selectedFg : unselectedFg,
            ),
            if (selected) ...[
              const Gap(AppSizes.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selectedFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
