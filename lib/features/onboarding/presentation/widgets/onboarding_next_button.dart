import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/onboarding/controllers/onboarding_controller.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSizes.defaultSpace,
      bottom: DeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
