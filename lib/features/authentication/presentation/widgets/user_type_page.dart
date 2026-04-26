import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class UserTypePage extends StatelessWidget {
  const UserTypePage({
    super.key,
    required this.animation,
    required this.title,
    required this.subtitle,
  });

  final String animation, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animation,
            width: DeviceUtils.getScreenWidth(context) * 0.8,
            height: DeviceUtils.getScreenHeight(context) * 0.35,
          ),
          const Gap(AppSizes.spaceBtwItems),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(AppSizes.spaceBtwItems),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
