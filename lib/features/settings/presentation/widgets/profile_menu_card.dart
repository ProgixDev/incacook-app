import 'package:flutter/material.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:incacook/features/settings/presentation/widgets/setting_menu_tile.dart';

class SettingMenuSection extends StatelessWidget {
  const SettingMenuSection({super.key, this.title, required this.items});

  final String? title;
  final List<SettingMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.xs,
              ),
              child: Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          for (var i = 0; i < items.length; i++) ...[
            SettingMenuTile(item: items[i]),
            if (i != items.length - 1) const _Separator(),
          ],
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: AppSizes.sm),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.7),
      ),
    );
  }
}
