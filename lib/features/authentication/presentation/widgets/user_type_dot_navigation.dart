import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/authentication/controllers/user_type_selection_controller.dart';

class UserTypeDotNavigation extends StatelessWidget {
  const UserTypeDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserTypeSelectionController.instance;
    final dark = DeviceUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwItems),
      child: Center(
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: UserTypeSelectionController.pageOrder.length,
          effect: ExpandingDotsEffect(
            activeDotColor: dark
                ? AppColors.lightBackground
                : AppColors.secondary,
            dotHeight: 6,
          ),
        ),
      ),
    );
  }
}
