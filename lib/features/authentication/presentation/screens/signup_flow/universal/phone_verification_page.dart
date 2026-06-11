import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/config/feature_flags.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
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
    final userController = UserController.instance;
    final scheme = Theme.of(context).colorScheme;
    final useEmail = FeatureFlags.useEmailOtpBypass;

    // Auth email comes from the Session captured server-side — same
    // address Supabase will derive the OTP destination from. Fall back
    // to the wizard's typed email if the auth call hasn't landed yet
    // (shouldn't happen in normal flow, but defensive).
    final destinationEmail =
        userController.authEmail.value ?? controller.email.value;

    return SignupStepLayout(
      title: useEmail ? AppTexts.signupOtpEmailTitle : AppTexts.signupOtpTitle,
      description: useEmail
          ? AppTexts.signupOtpEmailSubtitle(_formatEmail(destinationEmail))
          : AppTexts.signupOtpSubtitle(_formatPhone(controller.phone.value)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => SignupOtpField(
              onChanged: (v) => controller.otpCode.value = v,
              onCompleted: controller.verifyOtp,
              errorText: controller.otpError.value.isEmpty
                  ? null
                  : controller.otpError.value,
            ),
          ),
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
                          CustomLoaders.successSnackBar(
                            title: AppTexts.signupOtpResentTitle,
                            message: useEmail
                                ? AppTexts.signupOtpEmailResentBody
                                : AppTexts.signupOtpResentBody,
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
                  child: Text(
                    useEmail
                        ? AppTexts.signupOtpEmailEditAddress
                        : AppTexts.signupOtpEditNumber,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatPhone(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return AppTexts.signupOtpDefaultPhone;
    // Full international number → show as typed; else assume French (+33).
    if (v.startsWith('+')) return v;
    return '+33 ${v.replaceAll(RegExp(r'\D'), '')}';
  }

  String _formatEmail(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return AppTexts.signupOtpEmailDefaultDestination;
    return v;
  }
}
