import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';

/// Sticky bottom bar with the primary "Continuer" button and an optional
/// secondary "Passer" (Skip) button. Frosted for a branded look.
///
/// Rendered as a real layout footer (last child of the shell's column), so
/// page content is constrained above it and never hides behind it. When the
/// keyboard opens the shell resizes above it and the bar docks just above the
/// keyboard, keeping "Continuer" reachable while typing.
class SignupBottomBar extends GetView<SignupFlowController> {
  const SignupBottomBar({super.key});

  /// Extra space below the frosted card so it doesn't sit flush against
  /// the home-indicator / screen edge.
  static const double _bottomLift = AppSizes.sm + 4;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hideBottomBar) return const SizedBox.shrink();
      final canGoNext = controller.canGoNext();
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            0,
            AppSizes.md,
            _bottomLift,
          ),
          child: FrostedSurface(
            // Borderless: the frosted blur alone separates the bar from
            // the page content, no outline needed.
            border: const Border(),
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              12,
              AppSizes.md,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.submitError.value.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Text(
                      controller.submitError.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Row(
                  children: [
                    if (controller.canSkipCurrent) ...[
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.nextPage,
                            child: const Text(AppTexts.signupSkipCta),
                          ),
                        ),
                      ),
                      const Gap(AppSizes.sm),
                    ],
                    Expanded(
                      flex: controller.canSkipCurrent ? 1 : 2,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: canGoNext ? 1.0 : 0.45,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                (canGoNext && !controller.isLoading.value)
                                    ? controller.nextPage
                                    : null,
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    controller.isLastPage
                                        ? AppTexts.signupFinishCta
                                        : AppTexts.signupContinueCta,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
