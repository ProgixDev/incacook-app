import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';

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
    final textTheme = Theme.of(context).textTheme;

    // Reserve the top band (the "Skip" pill) and the bottom band (dot
    // navigation + the round next button) so the content never collides with
    // the overlaid controls. SafeArea keeps it clear of notches / gesture bars.
    final topReserve = DeviceUtils.getAppBarHeight() + AppSizes.lg;
    final bottomReserve =
        DeviceUtils.getBottomNavigationBarHeight() + AppSizes.spaceBtwSections + AppSizes.lg;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.defaultSpace,
          topReserve,
          AppSizes.defaultSpace,
          bottomReserve,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flexible image: keeps its aspect ratio (BoxFit.contain → no
            // distortion) and shrinks to the available height instead of
            // forcing a fixed 50% that overflows on small screens.
            Expanded(
              child: Center(
                child: Image.asset(
                  animation,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
            const Gap(AppSizes.spaceBtwSections),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSizes.spaceBtwItems),
            Text(
              subtitle,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
