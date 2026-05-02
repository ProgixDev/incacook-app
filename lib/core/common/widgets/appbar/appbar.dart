import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.actions,
    this.leadingOnPressed,
    this.leading,
  });

  final Widget? title;
  final bool showBackArrow;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        right: 16.0,
        left: 16,
        top: DeviceUtils.getStatusBarHeight(),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null && showBackArrow == false)
                GestureDetector(onTap: leadingOnPressed, child: leading)
              else if (showBackArrow)
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: FrostedSurface(
                    shape: BoxShape.circle,
                    child: SizedBox(
                      width: AppSizes.lg * 1.8,
                      height: AppSizes.lg * 1.8,
                      child: Center(
                        child: Icon(
                          Iconsax.arrow_left,
                          color: scheme.onSurface,
                          size: AppSizes.lg,
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              ...?actions,
            ],
          ),
          if (title != null)
            Column(
              children: [
                const Gap(AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [title!],
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(DeviceUtils.getAppBarHeight());
}
