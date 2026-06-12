import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/config/feature_flags.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/country_code_selector.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_otp_field.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

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
    // When we already have a destination — the email bypass, or a number
    // captured on basic info — skip the inline number-entry phase and send the
    // code straight away (the page's historical behaviour). The Google /
    // NoProfile path arrives with no number, so [canRequestOtp] is false and we
    // fall through to the inline phone field instead of firing `{phone: +33}`.
    if (controller.canRequestOtp && !controller.otpRequested.value) {
      controller.otpRequested.value = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.canRequestOtp &&
          controller.otpResendSecondsLeft.value == 0) {
        controller.requestOtp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final useEmail = FeatureFlags.useEmailOtpBypass;
    return Obx(() {
      final inCodeEntry = useEmail || controller.otpRequested.value;
      return inCodeEntry
          ? _buildCodeEntry(context, controller, useEmail)
          : _buildPhoneEntry(context, controller);
    });
  }

  // --- Phase 1: collect the phone number inline (Google / NoProfile path). ---
  Widget _buildPhoneEntry(
    BuildContext context,
    SignupFlowController controller,
  ) {
    return SignupStepLayout(
      title: AppTexts.signupOtpEnterPhoneTitle,
      description: AppTexts.signupOtpEnterPhoneSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => SignupTextField(
                controller: controller.phoneTextController,
                label: AppTexts.signupPhoneLabel,
                hint: AppTexts.signupPhoneHint,
                leading: const CountryCodeSelector(),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                helperText: AppTexts.signupPhoneHelper,
                errorText: controller.otpError.value.isNotEmpty
                    ? controller.otpError.value
                    : (controller.phone.value.isEmpty ||
                            controller.isPhoneValid
                        ? null
                        : AppTexts.signupPhoneError),
              )),
          const Gap(AppSizes.lg),
          Obx(() => SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isPhoneValid
                      ? () => controller.requestOtp()
                      : null,
                  child: const Text(AppTexts.signupOtpSendCode),
                ),
              )),
        ],
      ),
    );
  }

  // --- Phase 2: enter the 6-digit code (unchanged behaviour). ---
  Widget _buildCodeEntry(
    BuildContext context,
    SignupFlowController controller,
    bool useEmail,
  ) {
    final userController = UserController.instance;
    final scheme = Theme.of(context).colorScheme;

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
          : AppTexts.signupOtpSubtitle(_formatPhone(controller)),
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
                  onPressed: () {
                    // Inline-entry path (basic info was skipped): return to the
                    // number field instead of a no-op previousPage at index 0.
                    if (!useEmail && controller.startedSignedUp.value) {
                      controller.editPhoneNumber();
                    } else {
                      controller.previousPage();
                    }
                  },
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

  String _formatPhone(SignupFlowController controller) {
    final v = controller.phone.value.trim();
    if (v.isEmpty) return AppTexts.signupOtpDefaultPhone;
    // Full international number → show as typed; else prefix the selected
    // country's dial code (dropping a single national trunk '0' to match the
    // E.164 actually sent).
    if (v.startsWith('+')) return v;
    var national = v.replaceAll(RegExp(r'\D'), '');
    if (national.startsWith('0')) national = national.substring(1);
    return '${controller.dialCode.value} $national';
  }

  String _formatEmail(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return AppTexts.signupOtpEmailDefaultDestination;
    return v;
  }
}
