import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/loaders/animation_loader.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class CustomFullscreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: DeviceUtils.isDarkMode(Get.context!)
              ? AppColors.darkBackground
              : AppColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const Gap(250), //? adjust as needed
              CustomAnimationLoader(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );
  }

  static void stopLoading() {
    Navigator.of(
      Get.overlayContext!,
    ).pop(); //? close the dialog using the navigator
  }
}
