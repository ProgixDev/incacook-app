import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/config/feature_flags.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/country_code_selector.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class BasicInfoPage extends GetView<SignupFlowController> {
  const BasicInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupStepLayout(
      title: AppTexts.signupBasicInfoTitle,
      description: AppTexts.signupBasicInfoSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SignupTextField(
                  controller: controller.firstNameTextController,
                  label: AppTexts.signupFirstNameLabel,
                  hint: AppTexts.signupFirstNameHint,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const Gap(AppSizes.sm + 4),
              Expanded(
                child: SignupTextField(
                  controller: controller.lastNameTextController,
                  label: AppTexts.signupLastNameLabel,
                  hint: AppTexts.signupLastNameHint,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const Gap(AppSizes.md),
          Obx(() => SignupTextField(
                controller: controller.emailTextController,
                label: AppTexts.signupEmailLabel,
                hint: AppTexts.signupEmailHint,
                leadingIcon: Iconsax.direct_right,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: controller.email.value.isEmpty ||
                        controller.isEmailValid
                    ? null
                    : AppTexts.signupEmailError,
              )),
          const Gap(AppSizes.md),
          Obx(() => SignupTextField(
                controller: controller.phoneTextController,
                label: FeatureFlags.useEmailOtpBypass
                    ? AppTexts.signupPhoneLabelOptional
                    : AppTexts.signupPhoneLabel,
                hint: AppTexts.signupPhoneHint,
                leading: const CountryCodeSelector(),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                helperText: AppTexts.signupPhoneHelper,
                errorText: controller.phone.value.isEmpty ||
                        controller.isPhoneValid
                    ? null
                    : AppTexts.signupPhoneError,
              )),
          const Gap(AppSizes.md),
          Obx(() => SignupTextField(
                controller: controller.passwordTextController,
                label: AppTexts.signupPasswordLabel,
                hint: AppTexts.signupPasswordHint,
                leadingIcon: Iconsax.password_check,
                obscureText: controller.hidePassword.value,
                textInputAction: TextInputAction.next,
                trailing: IconButton(
                  onPressed: () => controller.hidePassword.toggle(),
                  icon: Icon(
                    controller.hidePassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    size: 20,
                  ),
                ),
                errorText: controller.password.value.isEmpty ||
                        controller.isPasswordValid
                    ? null
                    : AppTexts.signupPasswordError,
              )),
          const Gap(AppSizes.sm),
          const _PasswordStrengthMeter(),
          const Gap(AppSizes.md),
          Obx(() => SignupTextField(
                controller: controller.confirmPasswordTextController,
                label: AppTexts.signupConfirmPasswordLabel,
                leadingIcon: Iconsax.password_check,
                obscureText: controller.hideConfirmPassword.value,
                textInputAction: TextInputAction.done,
                trailing: IconButton(
                  onPressed: () => controller.hideConfirmPassword.toggle(),
                  icon: Icon(
                    controller.hideConfirmPassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    size: 20,
                  ),
                ),
                errorText: controller.confirmPassword.value.isEmpty ||
                        controller.isPasswordConfirmed
                    ? null
                    : AppTexts.signupConfirmPasswordError,
              )),
        ],
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter();

  static const _labels = [
    AppTexts.signupPasswordStrengthWeak,
    AppTexts.signupPasswordStrengthWeak,
    AppTexts.signupPasswordStrengthMedium,
    AppTexts.signupPasswordStrengthGood,
    AppTexts.signupPasswordStrengthExcellent,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final score = controller.passwordStrength;
      final empty = controller.password.value.isEmpty;
      final color = score >= 3
          ? scheme.primary
          : score == 2
              ? Colors.orange
              : scheme.error;
      return Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: !empty && i < score
                          ? color
                          : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Gap(AppSizes.sm + 4),
          Text(
            empty ? '' : _labels[score],
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }
}
