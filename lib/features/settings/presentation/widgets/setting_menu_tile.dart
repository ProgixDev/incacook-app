import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/constants/sizes.dart';

class SettingMenuTile extends StatelessWidget {
  const SettingMenuTile({super.key, required this.item});

  final SettingMenuItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            CustomCircularContainer(
              size: 44,
              backgroundColor: scheme.surfaceContainerHigh,
              child: Icon(item.icon, size: 20, color: scheme.onSurface),
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (item.trailingText != null)
              Text(
                item.trailingText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (item.showChevron)
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
