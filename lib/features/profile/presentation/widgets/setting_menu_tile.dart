import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/features/profile/domain/Setting_menu_item.dart';

class SettingMenuTile extends StatelessWidget {
  const SettingMenuTile({super.key, required this.item});

  final SettingMenuItem item;

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: AppColors.lightBackground,
              child: Icon(
                item.icon,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.trailingText != null)
              Text(
                item.trailingText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (item.showChevron)
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
