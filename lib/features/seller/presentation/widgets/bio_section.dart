import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/common/styles/shadows_styles.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';

class BioSection extends StatelessWidget {
  const BioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DeviceUtils.getScreenWidth(context) * 0.9,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [CustomShadowStyle.customCircleShadows()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bio',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(),
          ),
          const Gap(AppSizes.sm),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
