import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/cart/presentation/screens/my_cart.dart';
import 'package:incacook/features/cart/presentation/widgets/cart_badge.dart';
import 'package:incacook/features/map/presentation/screens/map.dart';

class ClientHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClientHomeAppBar({super.key});

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
            child: Obx(
              () => Text(
                // Real reverse-geocoded "City, Country"; falls back while the
                // location resolves or when it's unavailable/denied.
                LocationService.instance.placeLabel.value ?? 'Localisation…',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
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
            child: Obx(
              () => CartBadge(count: CartController.instance.itemCount),
            ),
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
