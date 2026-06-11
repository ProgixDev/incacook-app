import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/utils/validators/validators.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/controllers/reset_password_controller.dart';

/// Code + new-password step of the forgot-password flow. Reached from
/// [ForgetPasswordController.sendPasswordResetEmail] once a 6-digit code has
/// been emailed to [email].
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController(email: email));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.back<void>(),
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Lottie.asset(
                  AppAnimations.forgotPassword,
                  width: DeviceUtils.getScreenWidth(context) * 0.5,
                ),
                const Gap(AppSizes.spaceBtwSections),

                Text(
                  AppTexts.resetPasswordTitle,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSizes.spaceBtwItems),
                Text(
                  '${AppTexts.resetPasswordSubTitle}\n$email',
                  style: textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSizes.spaceBtwSections),

                //* verification code
                FrostedSurface(
                  borderRadius: BorderRadius.circular(999),
                  child: TextFormField(
                    controller: controller.code,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: controller.validateCode,
                    decoration: const InputDecoration(
                      labelText: AppTexts.resetCodeLabel,
                      prefixIcon: Icon(Iconsax.password_check),
                    ),
                  ),
                ),
                const Gap(AppSizes.spaceBtwItems),

                //* new password
                Obx(
                  () => FrostedSurface(
                    borderRadius: BorderRadius.circular(999),
                    child: TextFormField(
                      controller: controller.password,
                      obscureText: controller.hidePassword.value,
                      validator: CustomValidator.validatePassword,
                      decoration: InputDecoration(
                        labelText: AppTexts.newPasswordLabel,
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: controller.hidePassword.toggle,
                          icon: Icon(
                            controller.hidePassword.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSizes.spaceBtwItems),

                //* confirm new password
                Obx(
                  () => FrostedSurface(
                    borderRadius: BorderRadius.circular(999),
                    child: TextFormField(
                      controller: controller.confirmPassword,
                      obscureText: controller.hidePassword.value,
                      validator: controller.validateConfirm,
                      decoration: const InputDecoration(
                        labelText: AppTexts.confirmNewPasswordLabel,
                        prefixIcon: Icon(Iconsax.password_check),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSizes.spaceBtwSections),

                //* submit
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submit,
                      child: const Text(AppTexts.resetPasswordCta),
                    ),
                  ),
                ),
                const Gap(AppSizes.spaceBtwItems),

                //* resend code (with cooldown)
                Obx(() {
                  final left = controller.resendSecondsLeft.value;
                  return TextButton(
                    onPressed: left > 0 ? null : controller.resendCode,
                    child: Text(
                      left > 0
                          ? '${AppTexts.resendCode} ($left s)'
                          : AppTexts.resendCode,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}