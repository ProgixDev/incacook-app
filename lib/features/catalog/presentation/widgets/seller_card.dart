import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/chat/presentation/screens/chat.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    this.name = AppTexts.productSampleSellerName,
    this.imagePath = AppImages.profilePic,
    this.rating = AppTexts.productSampleSellerRating,
    this.ordersCompleted = AppTexts.productSampleSellerOrdersCompleted,
    this.onCallTap,
  });

  final String name;
  final String imagePath;
  final double rating;
  final int ordersCompleted;
  final VoidCallback? onCallTap;

  String get _formattedOrders {
    //? 1284 -> "1,284"
    final s = ordersCompleted.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.5),
      ),
      child: Row(
        children: [
          CustomCircularImage(image: imagePath, width: 48, height: 48),
          const Gap(AppSizes.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Iconsax.star1,
                      size: 14,
                      color: Color(0xFFFFC107),
                    ),
                    const Gap(4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(6),
                    //? separator dot
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Flexible(
                      child: Text(
                        '$_formattedOrders ${AppTexts.productSellerOrdersSuffix}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const ChatScreen()),
            child: const CustomCircularContainer(
              size: 40,
              backgroundColor: AppColors.secondary,
              child: Icon(Iconsax.message, color: AppColors.white, size: 18),
            ),
          ),
          const Gap(AppSizes.sm),
          GestureDetector(
            onTap: onCallTap,
            child: const CustomCircularContainer(
              size: 40,
              backgroundColor: AppColors.white,
              child: Icon(Iconsax.call, color: AppColors.secondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
