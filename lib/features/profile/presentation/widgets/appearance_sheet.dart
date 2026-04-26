import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/controllers/theme_controller.dart';
import 'package:homemade/core/utils/popups/blurred_modal_sheet.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/core/widgets/misc/drag_handle.dart';

/// Bottom sheet letting the user pick their theme mode (System / Light /
/// Dark). Persists via [ThemeController].
class AppearanceSheet extends StatelessWidget {
  const AppearanceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showBlurredModalBottomSheet<void>(
      context: context,
      builder: (_) => const AppearanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const DragHandle(),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppTexts.appearanceSheetTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(AppSizes.md),
                  children: [
                    _ModeTile(
                      mode: ThemeMode.system,
                      label: AppTexts.appearanceSystem,
                      icon: Iconsax.mobile,
                      selected: controller.mode.value == ThemeMode.system,
                      onTap: () => controller.setMode(ThemeMode.system),
                    ),
                    const Gap(AppSizes.sm + 2),
                    _ModeTile(
                      mode: ThemeMode.light,
                      label: AppTexts.appearanceLight,
                      icon: Iconsax.sun_1,
                      selected: controller.mode.value == ThemeMode.light,
                      onTap: () => controller.setMode(ThemeMode.light),
                    ),
                    const Gap(AppSizes.sm + 2),
                    _ModeTile(
                      mode: ThemeMode.dark,
                      label: AppTexts.appearanceDark,
                      icon: Iconsax.moon,
                      selected: controller.mode.value == ThemeMode.dark,
                      onTap: () => controller.setMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        tint: selected ? colors.selectedSurface : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md - 2,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? colors.selectedOnSurface : scheme.onSurface,
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? colors.selectedOnSurface
                      : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: colors.selectedOnSurface),
          ],
        ),
      ),
    );
  }
}
