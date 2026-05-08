import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/client/controllers/filter_controller.dart';
import 'package:incacook/features/client/presentation/widget/filters_sheet.dart';

class FiltersButton extends StatelessWidget {
  const FiltersButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FilterController.instance;
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final count = controller.activeCount;
      final hasActive = count > 0;
      return FrostedSurface(
        shape: BoxShape.circle,
        //* solid selected fill takes over when filters are active
        tint: hasActive ? colors.selectedSurface : null,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => FiltersSheet.show(context),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Iconsax.filter,
                    size: 22,
                    color: hasActive
                        ? colors.selectedOnSurface
                        : scheme.onSurface,
                  ),
                  if (hasActive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colors.selectedOnSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: colors.selectedSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
