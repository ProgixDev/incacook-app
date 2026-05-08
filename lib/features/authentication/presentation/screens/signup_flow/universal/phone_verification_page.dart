import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_otp_field.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<SignupFlowController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.otpResendSecondsLeft.value == 0) {
        controller.requestOtp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SignupStepLayout(
      title: AppTexts.signupOtpTitle,
      description: AppTexts.signupOtpSubtitle(_formatPhone(controller.phone.value)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => SignupOtpField(
                onChanged: (v) => controller.otpCode.value = v,
                onCompleted: controller.verifyOtp,
                errorText: controller.otpError.value.isEmpty
                    ? null
                    : controller.otpError.value,
              )),
          const Gap(AppSizes.md),
          Obx(() {
            if (!controller.otpVerifying.value) {
              return const SizedBox.shrink();
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const Gap(AppSizes.sm),
                    Text(
                      AppTexts.signupOtpVerifying,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Gap(AppSizes.md),
          Obx(() {
            final secs = controller.otpResendSecondsLeft.value;
            final canResend = secs == 0;
            return Column(
              children: [
                TextButton(
                  onPressed: canResend
                      ? () async {
                          await controller.requestOtp();
                          Get.snackbar(
                            AppTexts.signupOtpResentTitle,
                            AppTexts.signupOtpResentBody,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      : null,
                  child: Text(
                    canResend
                        ? AppTexts.signupOtpResendNow
                        : AppTexts.signupOtpResendIn(secs),
                  ),
                ),
                TextButton(
                  onPressed: controller.previousPage,
                  child: const Text(AppTexts.signupOtpEditNumber),
                ),
              ],
            );
          }),
          const Gap(AppSizes.lg),
          Container(
            padding: const EdgeInsets.all(AppSizes.sm + 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: scheme.primary),
                const Gap(AppSizes.sm),
                Expanded(
                  child: Text(
                    AppTexts.signupOtpDemoHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return AppTexts.signupOtpDefaultPhone;
    return '+33 $digits';
  }
}
