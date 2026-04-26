import 'package:flutter/material.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/onboarding/controllers/onboarding_controller.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: DeviceUtils.getAppBarHeight(),
      right: AppSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(),
        child: const Text("Skip", style: TextStyle(color: AppColors.primary)),
      ),
    );
  }
}
