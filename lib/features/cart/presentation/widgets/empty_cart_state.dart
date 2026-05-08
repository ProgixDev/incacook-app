import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:lottie/lottie.dart';

class EmptyCartState extends StatelessWidget {
  const EmptyCartState({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Lottie.asset(
              AppAnimations.shoppingCart,
              width: DeviceUtils.getScreenWidth(context),
              height: DeviceUtils.getScreenWidth(context),
              fit: BoxFit.contain,
            ),
            const Gap(AppSizes.md),
            Text(
              AppTexts.cartEmptyTitleFr,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
