import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/theme/brand_colors.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/authentication/presentation/screens/login.dart';
import 'package:homemade/features/authentication/presentation/screens/user_type_selection.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          //* 1) full-bleed background image
          Image.asset(AppImages.welcome, fit: BoxFit.cover),

          //* 2) frosted layer over the image (tint adapts to mode)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: FrostedSurface.blurSigma,
              sigmaY: FrostedSurface.blurSigma,
            ),
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.55),
            ),
          ),

          //* 3) foreground UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
              child: Column(
                children: [
                  const Gap(AppSizes.spaceBtwSections * 2),

                  //* logo + brand
                  Image.asset(AppImages.appLogo, height: 72),
                  const Gap(AppSizes.sm),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'In',
                          style: TextStyle(color: BrandColors.primary),
                        ),
                        TextSpan(
                          text: 'ca',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const TextSpan(
                          text: 'Cook',
                          style: TextStyle(color: BrandColors.primary),
                        ),
                      ],
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  //* tagline
                  Text(
                    AppTexts.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(AppSizes.md),

                  //* social row
                  Row(
                    children: [
                      Expanded(
                        child: _SocialPill(
                          logo: AppImages.facebookLogo,
                          label: AppTexts.welcomeContinueWith,
                          onTap: () {},
                        ),
                      ),
                      const Gap(AppSizes.sm),
                      Expanded(
                        child: _SocialPill(
                          logo: AppImages.googleLogo,
                          label: AppTexts.welcomeContinueWith,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSizes.sm + 2),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.to(() => const UserTypeSelectionScreen()),
                      child: Text(
                        AppTexts.welcomeSignUpEmail,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSizes.md),

                  //* footer — already have an account? Log in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTexts.welcomeAlreadyAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const LoginScreen()),
                        child: Text(
                          AppTexts.signIn,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.logo,
    required this.label,
    required this.onTap,
  });

  final String logo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: FrostedSurface(
          borderRadius: BorderRadius.circular(999),
          border: const Border.fromBorderSide(BorderSide.none),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(logo, height: 22, width: 22),
                const Gap(AppSizes.sm),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
