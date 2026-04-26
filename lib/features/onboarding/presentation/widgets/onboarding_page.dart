import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.animation,
    required this.title,
    required this.subtitle,
  });

  final String animation, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Lottie.asset(
          //   animation,
          //   width: DeviceUtils.getScreenWidth(context) * 0.8,
          //   height: DeviceUtils.getScreenHeight(context) * 0.6,
          // ),
          Image.asset(
            animation,
            width: DeviceUtils.getScreenWidth(context) * 0.8,
            height: DeviceUtils.getScreenHeight(context) * 0.6,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(20),
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
