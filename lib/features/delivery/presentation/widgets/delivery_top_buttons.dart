import 'package:flutter/material.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';

class DeliveryTopButtons extends StatelessWidget {
  const DeliveryTopButtons({
    super.key,
    // required this.onMenuTap,
    required this.onGpsTap,
    this.onFitRouteTap,
  });

  // final VoidCallback onMenuTap;

  /// Recenters the camera on the driver's current position.
  final VoidCallback onGpsTap;

  /// Fits the camera to the whole active route (driver + pickup + dropoff +
  /// polyline). Null when there is no active delivery, in which case the
  /// button is hidden.
  final VoidCallback? onFitRouteTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Stack(
          children: [
            //* menu — top-left
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {},
                child: CustomCircularImage(image: AppImages.profilePic),
              ),
            ),

            //* right column, mid-screen: fit-route (when a job is active)
            //* stacked above the driver-recenter GPS button.
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFitRouteTap != null) ...[
                    _CircleButton(
                      icon: Iconsax.routing,
                      onTap: onFitRouteTap!,
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  _CircleButton(icon: Iconsax.gps, onTap: onGpsTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: scheme.onSurface),
      ),
    );
  }
}
