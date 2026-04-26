import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

class OrderDelivererPill extends StatelessWidget {
  const OrderDelivererPill({super.key, this.onCallTap, this.onChatTap});

  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          //* avatar
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE8823B),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(AppImages.profilePic, fit: BoxFit.cover),
          ),
          const Gap(AppSizes.sm),

          //* name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTexts.trackingDelivererName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppTexts.trackingDelivererMeta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          //* call button
          GestureDetector(
            onTap: onCallTap,
            child: const CustomCircularContainer(
              size: 44,
              backgroundColor: AppColors.white,
              child: Icon(Iconsax.call, color: AppColors.primary, size: 18),
            ),
          ),
          const Gap(AppSizes.xs + 2),

          //* chat button with unread dot
          GestureDetector(
            onTap: onChatTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const CustomCircularContainer(
                  size: 44,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Iconsax.message,
                    color: AppColors.primary,
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
                      border: Border.all(color: AppColors.white, width: 1.5),
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
