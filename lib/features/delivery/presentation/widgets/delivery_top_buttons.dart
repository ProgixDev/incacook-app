import 'package:flutter/material.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';

class DeliveryTopButtons extends StatelessWidget {
  const DeliveryTopButtons({
    super.key,
    // required this.onMenuTap,
    required this.onGpsTap,
  });

  // final VoidCallback onMenuTap;
  final VoidCallback onGpsTap;

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

            //* gps — right column, mid-screen
            Align(
              alignment: Alignment.centerRight,
              child: _CircleButton(icon: Iconsax.gps, onTap: onGpsTap),
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
