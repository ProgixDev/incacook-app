import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_charter_viewer.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_checkbox.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class DriverCharterPage extends StatelessWidget {
  const DriverCharterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    return SignupStepLayout(
      title: AppTexts.signupDriverCharterTitle,
      description: AppTexts.signupDriverCharterSubtitle,
      scrollable: false,
      // Outer scroll wraps the whole page so the charter viewer keeps
      // its taller (0.55 × screenHeight) default and the checkboxes
      // remain reachable below it via page scrolling.
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignupCharterViewer(
              text: AppTexts.signupDriverCharterText,
              onReachedBottom: () =>
                  controller.charterScrolledToBottom.value = true,
            ),
            const Gap(AppSizes.md),
            Obx(() {
              final enabled = controller.charterScrolledToBottom.value;
              return Column(
                children: [
                  SignupCheckbox(
                    enabled: enabled,
                    value: controller.driverPunctualityCommitment.value,
                    onChanged: (v) =>
                        controller.driverPunctualityCommitment.value = v,
                    label: const Text(AppTexts.signupDriverCommitmentPunctuality),
                  ),
                  SignupCheckbox(
                    enabled: enabled,
                    value: controller.driverCareCommitment.value,
                    onChanged: (v) =>
                        controller.driverCareCommitment.value = v,
                    label: const Text(AppTexts.signupDriverCommitmentCare),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
