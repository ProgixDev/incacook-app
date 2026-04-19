import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/orders/presentation/screens/order_tracking.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            cursorColor: AppColors.secondary,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: AppTexts.homeSearchHint,
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
              prefixIcon: const Icon(
                Iconsax.search_normal_1,
                color: AppColors.secondary,
                size: 22,
              ),
              filled: true,
              fillColor: AppColors.accent,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Gap(AppSizes.md),
        GestureDetector(
          onTap: () => Get.to(() => const OrderTrackingScreen()),
          child: CustomCircularContainer(
            size: 56,
            backgroundColor: AppColors.secondary,
            child: const Icon(Iconsax.map, color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }
}
