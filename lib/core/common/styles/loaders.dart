import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';

class CustomLoaders {
  static void hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentMaterialBanner();

  static void customToast({required String message}) {
    final ctx = Get.context!;
    final scheme = Theme.of(ctx).colorScheme;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: ctx.isDark
                ? scheme.surfaceContainerHigh.withValues(alpha: 0.9)
                : scheme.onSurfaceVariant.withValues(alpha: 0.9),
          ),
          child: Center(
            child: Text(message, style: Theme.of(ctx).textTheme.labelLarge),
          ),
        ),
      ),
    );
  }

  static void successSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: BrandColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Iconsax.check, color: Colors.white),
    );
  }

  static void warningSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: BrandColors.warning,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Iconsax.warning_2, color: Colors.white),
    );
  }

  static void errorSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: BrandColors.error,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Iconsax.warning_2, color: Colors.white),
    );
  }
}
