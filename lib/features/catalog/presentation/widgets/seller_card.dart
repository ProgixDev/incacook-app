import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/chat/presentation/screens/chat.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    this.name = AppTexts.productSampleSellerName,
    this.imageUrl = AppImages.profilePic,
    this.rating = AppTexts.productSampleSellerRating,
    this.ordersCompleted = AppTexts.productSampleSellerOrdersCompleted,
    this.onCallTap,
    this.onCardTap,
  });

  final String name;
  final String imageUrl;
  final double rating;
  final int ordersCompleted;
  final VoidCallback? onCallTap;
  final VoidCallback? onCardTap;

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
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.5),
        ),
        child: Row(
          children: [
            CustomCircularImage(image: imageUrl, size: 48),
            const Gap(AppSizes.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(6),
                      //? separator dot
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(6),
                      Flexible(
                        child: Text(
                          '$_formattedOrders ${AppTexts.productSellerOrdersSuffix}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const ChatScreen()),
              child: CustomCircularContainer(
                size: 40,
                backgroundColor: colors.selectedSurface,
                child: Icon(Iconsax.message, color: colors.selectedOnSurface, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
