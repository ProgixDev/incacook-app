import 'package:homemade/features/onboarding/controllers/onboarding_controller.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;

    return Positioned(
      bottom: DeviceUtils.getBottomNavigationBarHeight() + 25,
      left: AppSizes.defaultSpace,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 3,
          effect: ExpandingDotsEffect(
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotHeight: 6,
          ),
        ),
      ),
    );
  }
}
