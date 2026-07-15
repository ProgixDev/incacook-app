import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/features/delivery/controllers/delivery_driver_controller.dart';

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
      final busy = controller.busy.value;
      final disabledReason = controller.onlineDisabledReason;
      final canTap = !busy && controller.canToggleOnline;
      final disabled = !isOnline && !controller.canToggleOnline;
      // Online but holding a delivery: going offline mid-job is refused (here
      // and by the server). Distinct from [disabled], which is the offline-side
      // KYC block — this one keeps the "Go Offline" affordance but dims it.
      final lockedByJob = isOnline && !controller.canToggleOnline;
      final color = isOnline
          ? BrandColors.error.withValues(alpha: lockedByJob ? 0.45 : 1)
          : disabled
          ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
          : BrandColors.success;
      final label = busy
          ? '...'
          : isOnline
          ? 'Go Offline'
          : disabled
          ? 'KYC requis'
          : 'Go Online';

      return GestureDetector(
        onTap: canTap
            ? controller.toggle
            : () {
                if (disabledReason == null) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(disabledReason),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: disabled ? 0.08 : 0.35),
                    blurRadius: disabled ? 8 : 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (disabled) ...[
                    Icon(
                      Iconsax.info_circle,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            // Show KYC status subtitle when disabled
            if (disabled && disabledReason != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getShortKycStatus(disabledReason),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Extract a short KYC status from the full disabled reason message.
  String _getShortKycStatus(String reason) {
    if (reason.contains('attente')) return 'En attente';
    if (reason.contains('refusé')) return 'Refusé';
    if (reason.contains('requis')) return 'Compléter KYC';
    return 'KYC requis';
  }
}
