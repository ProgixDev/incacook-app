import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart' show Iconsax;
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/cart/presentation/screens/my_cart.dart';
import 'package:vinted_v2/features/catalog/presentation/screens/product_detail.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: DeviceUtils.getStatusBarHeight(),
        bottom: 0,
        left: AppSizes.md,
        right: AppSizes.md,
      ),
      height: DeviceUtils.getAppBarHeight() + DeviceUtils.getStatusBarHeight(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Iconsax.location, color: AppColors.secondary),
          const Gap(AppSizes.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Location", style: Theme.of(context).textTheme.bodyMedium),
              Text(
                "Paris, France",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(() => const MyCartScreen()),
            child: CustomCircularContainer(
              size: AppSizes.lg * 1.8,
              backgroundColor: AppColors.accent,
              child: Icon(Iconsax.shopping_bag, color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    final statusBarHeight = DeviceUtils.getStatusBarHeight();
    final appBarContentHeight = AppSizes.appBarHeight;
    return Size.fromHeight(statusBarHeight + appBarContentHeight);
  }
}
