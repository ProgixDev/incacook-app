import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/cart/presentation/screens/my_cart.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/cart_badge.dart';
import 'package:vinted_v2/features/map/presentation/screens/map.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: DeviceUtils.getStatusBarHeight(),
        left: AppSizes.md,
        right: AppSizes.md,
      ),
      height: DeviceUtils.getAppBarHeight() + DeviceUtils.getStatusBarHeight(),
      child: Row(
        children: [
          const Icon(Iconsax.location, color: AppColors.secondary, size: 20),
          const Gap(AppSizes.xs),
          Flexible(
            child: Text(
              "Lyon, France",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(() => const MapScreen()),
            child: Container(
              width: AppSizes.lg * 1.8,
              height: AppSizes.lg * 1.8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Iconsax.map,
                color: AppColors.secondary,
                size: AppSizes.lg - 2,
              ),
            ),
          ),
          const Gap(AppSizes.sm + 2),
          GestureDetector(
            onTap: () => Get.to(() => const MyCartScreen()),
            child: const CartBadge(count: 4),
          ),
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



