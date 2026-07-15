import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';

class OrderDelivererPill extends StatelessWidget {
  const OrderDelivererPill({
    super.key,
    required this.name,
    required this.totalDeliveries,
    this.avatarUrl,
    this.onCallTap,
    this.onChatTap,
  });

  /// Real assigned driver's display name. The pill is only shown once a
  /// driver is assigned, so this is never a placeholder.
  final String name;

  /// The driver's real lifetime completed deliveries, from the tracking
  /// snapshot. Rendered via [AppTexts.trackingDelivererMeta].
  final int totalDeliveries;

  /// Resolved avatar URL (from the driver's avatarPath); null falls back to
  /// the default profile asset.
  final String? avatarUrl;

  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          CustomCircularImage(
            image: avatarUrl ?? AppImages.profilePic,
            isNetworkImage: avatarUrl != null,
          ),
          const Gap(AppSizes.sm),

          //* name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppTexts.trackingDelivererMeta(totalDeliveries),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          //* call button
          GestureDetector(
            onTap: onCallTap,
            child: CustomCircularContainer(
              size: 44,
              backgroundColor: Colors.white,
              child: Icon(
                Iconsax.call,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
          ),
          const Gap(AppSizes.xs + 2),

          //* chat button with unread dot
          GestureDetector(
            onTap: onChatTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomCircularContainer(
                  size: 44,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Iconsax.message,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8823B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
