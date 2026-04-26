import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/cart/presentation/screens/my_cart.dart';
import 'package:homemade/features/cart/presentation/widgets/cart_badge.dart';
import 'package:homemade/features/map/presentation/screens/map.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

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
          Icon(Iconsax.location, color: onSurface, size: 20),
          const Gap(AppSizes.xs),
          Flexible(
            child: Text(
              "Lyon, France",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(() => const MapScreen()),
            child: FrostedSurface(
              shape: BoxShape.circle,
              child: SizedBox(
                width: AppSizes.lg * 1.8,
                height: AppSizes.lg * 1.8,
                child: Center(
                  child: Icon(
                    Iconsax.map,
                    color: onSurface,
                    size: AppSizes.lg - 2,
                  ),
                ),
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
