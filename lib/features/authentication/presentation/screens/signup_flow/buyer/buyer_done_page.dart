import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/client/presentation/client_nav_tabs.dart';

class BuyerDonePage extends StatelessWidget {
  const BuyerDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Column(
          children: [
            const Spacer(),
            // Plays once on appearance — gives the same celebratory beat
            // as the previous custom check animation but uses the shared
            // success lottie so the brand language is consistent.
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                AppAnimations.success,
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),
            const Gap(AppSizes.md),
            Text(
              AppTexts.signupBuyerDoneTitle(controller.firstName.value),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSizes.sm + 4),
            Text(
              AppTexts.signupBuyerDoneSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          await controller.submitSignup();
                          Get.offAll<void>(
                            () => const NavigationMenu(tabs: kClientNavTabs),
                          );
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppTexts.signupBuyerDoneCta),
                ),
              ),
            ),
            const Gap(AppSizes.lg),
          ],
        ),
      ),
    );
  }
}
