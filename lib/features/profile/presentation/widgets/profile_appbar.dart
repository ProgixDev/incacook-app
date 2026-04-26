import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key, this.onNotificationsTap});

  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: DeviceUtils.getStatusBarHeight(),
        left: AppSizes.md,
        right: AppSizes.md,
      ),
      child: SizedBox(
        height: AppSizes.appBarHeight,
        child: Row(
          children: [
            CustomCircularContainer(
              size: 44,
              backgroundColor: scheme.surfaceContainerHigh,
              child: Icon(Iconsax.user, color: scheme.onSurface, size: 20),
            ),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.profileTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onNotificationsTap,
              child: CustomCircularContainer(
                size: 44,
                backgroundColor: scheme.surfaceContainerHigh,
                child: Icon(
                  Iconsax.notification,
                  color: scheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(AppSizes.appBarHeight + DeviceUtils.getStatusBarHeight());
}
