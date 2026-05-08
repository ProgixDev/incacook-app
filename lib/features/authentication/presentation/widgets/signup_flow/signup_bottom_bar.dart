import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';

/// Sticky bottom bar with the primary "Continuer" button and an optional
/// secondary "Passer" (Skip) button. Frosted to sit over the page content.
///
/// Designed to be rendered inside a [Stack] (not the [Scaffold.bottomNavigationBar]
/// slot), so page content scrolls *behind* it and the frosted blur reads.
/// Pages reserve [reservedHeight] of bottom padding via [SignupStepLayout]
/// so scroll content can clear the floating bar.
class SignupBottomBar extends GetView<SignupFlowController> {
  const SignupBottomBar({super.key});

  /// Approximate visible height: button (52) + vertical inner padding
  /// (12 + 16) + the [_bottomLift] gap below the bar. The system's bottom
  /// safe-area inset is added on top by the SafeArea inside [build], so
  /// callers add only this constant.
  static const double reservedHeight = 92;

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
            child: Row(
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
                    onPressed: (canGoNext && !controller.isLoading.value)
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
          ),
        ),
      );
    });
  }
}
