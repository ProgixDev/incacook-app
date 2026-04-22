import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/navigation/navigation_controller.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';

class NavigationMenu extends GetView<NavigationController> {
  const NavigationMenu({super.key});

  static const List<_NavItemSpec> _items = [
    _NavItemSpec(icon: Iconsax.home, label: 'Accueil'),
    // _NavItemSpec(icon: Iconsax.add, label: 'Publier'),
    _NavItemSpec(icon: Iconsax.message, label: 'Messages'),
    _NavItemSpec(icon: Iconsax.user, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.md,
          0,
          AppSizes.md,
          DeviceUtils.getBottomNavigationBarHeight() / 1.5,
        ),
        child: Obx(
          () => Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_items.length, (index) {
                final spec = _items[index];
                return _NavItem(
                  icon: spec.icon,
                  label: spec.label,
                  selected: controller.selectedIndex.value == index,
                  onTap: () => controller.selectedIndex.value = index,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemSpec {
  const _NavItemSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.secondary : AppColors.white,
            ),
            //? only the selected item shows its label, like the reference
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(AppSizes.sm),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
