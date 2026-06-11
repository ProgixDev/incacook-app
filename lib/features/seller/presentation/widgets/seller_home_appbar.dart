import 'package:flutter/material.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';

class SellerHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SellerHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.only(
        top: DeviceUtils.getStatusBarHeight(),
        left: AppSizes.md,
        right: AppSizes.md,
      ),
      height: DeviceUtils.getAppBarHeight() + DeviceUtils.getStatusBarHeight(),
      child: Row(
        children: [
          Flexible(
            child: Text(
              "Bonjour Fatima",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    final statusBarHeight = DeviceUtils.getStatusBarHeight();
    return Size.fromHeight(statusBarHeight + AppSizes.appBarHeight);
  }
}
