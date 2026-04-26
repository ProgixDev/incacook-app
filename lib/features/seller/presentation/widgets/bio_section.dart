import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/common/styles/shadows_styles.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class BioSection extends StatelessWidget {
  const BioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceUtils.getScreenWidth(context) * 0.9,
      child: DecoratedBox(
        //* shadow lives outside the FrostedSurface clip so it isn't
        //* swallowed by the frame.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [CustomShadowStyle.customCircleShadows()],
        ),
        child: FrostedSurface(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Bio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(AppSizes.sm),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
