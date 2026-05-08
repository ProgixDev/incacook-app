import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(logo: AppImages.googleLogo, onTap: () {}),
        const Gap(AppSizes.spaceBtwItems),
        _SocialButton(logo: AppImages.facebookLogo, onTap: () {}),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.logo, required this.onTap});

  final String logo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedSurface(
      shape: BoxShape.circle,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sm + 4),
            child: Image(
              image: AssetImage(logo),
              height: AppSizes.iconMd,
              width: AppSizes.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
