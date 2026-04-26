import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/loaders/animation_loader.dart';

class CustomFullscreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Container(
          color: Theme.of(ctx).colorScheme.surface,
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
