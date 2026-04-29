import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/features/delivery/controllers/delivery_driver_controller.dart';

class GoOnlineButton extends StatelessWidget {
  const GoOnlineButton({super.key});

  //* Geometry coordinated with [DeliveryNavBar] so the bar's notch fits
  //* the pill's bottom-half silhouette pixel-perfect.
  static const double width = 168;
  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    final controller = DeliveryDriverController.instance;

    return Obx(() {
      final isOnline = controller.isOnline.value;
      final color = isOnline ? BrandColors.error : BrandColors.success;
      final label = isOnline ? 'Go Offline' : 'Go Online';

      return GestureDetector(
        onTap: controller.toggle,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    });
  }
}
