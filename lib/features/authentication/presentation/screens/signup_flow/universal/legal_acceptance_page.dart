import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_charter_viewer.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_checkbox.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class LegalAcceptancePage extends GetView<SignupFlowController> {
  const LegalAcceptancePage({super.key});

  String get _combinedText =>
      '${AppTexts.signupCguText}\n\n────────\n\n${AppTexts.signupCgvText}';

  @override
  Widget build(BuildContext context) {
    return SignupStepLayout(
      title: AppTexts.signupLegalTitle,
      description: AppTexts.signupLegalSubtitle,
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flex into whatever vertical space remains after the title/
          // description above and the fixed-height checkboxes/footer
          // below. SignupCharterViewer detects the bounded parent via
          // LayoutBuilder, so its own maxHeightFraction is ignored here.
          Expanded(
            child: SignupCharterViewer(
              text: _combinedText,
              onReachedBottom: () =>
                  controller.charterScrolledToBottom.value = true,
            ),
          ),
          const Gap(AppSizes.md),
          Obx(() {
            final enabled = controller.charterScrolledToBottom.value;
            return Column(
              children: [
                SignupCheckbox(
                  value: controller.acceptedCgu.value,
                  enabled: enabled,
                  onChanged: (v) => controller.acceptedCgu.value = v,
                  label: const Text(AppTexts.signupLegalAcceptCgu),
                ),
                SignupCheckbox(
                  value: controller.acceptedCgv.value,
                  enabled: enabled,
                  onChanged: (v) => controller.acceptedCgv.value = v,
                  label: const Text(AppTexts.signupLegalAcceptCgv),
                ),
              ],
            );
          }),
          // const Gap(AppSizes.sm + 4),
          // Text(
          //   AppTexts.signupLegalFooter,
          //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //     color: Theme.of(context).colorScheme.onSurfaceVariant,
          //   ),
          // ),
        ],
      ),
    );
  }
}
