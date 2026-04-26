import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/validators/validators.dart';
import 'package:homemade/features/authentication/controllers/login_controller.dart';
import 'package:homemade/features/authentication/presentation/screens/forget_password.dart';
import 'package:homemade/features/authentication/presentation/screens/user_type_selection.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            //?Email
            TextFormField(
              controller: controller.email,
              validator: (value) => CustomValidator.validateEmail(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                prefixIcon: Icon(
                  Iconsax.direct_right,
                  color: scheme.primary,
                ),
                labelText: AppTexts.email,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),

            //* password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) =>
                    CustomValidator.validateEmptyText('Password', value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.surfaceContainerHigh,
                  labelText: AppTexts.password,
                  prefixIcon: Icon(
                    Iconsax.password_check,
                    color: scheme.primary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields / 2),

            //* remember me and forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //* remember me
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (value) => controller.rememberMe.value =
                            !controller.rememberMe.value,
                        activeColor: scheme.primary,
                        checkColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Text(
                      AppTexts.rememberMe,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),

                //* forget password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                  child: const Text(AppTexts.forgetPassword),
                ),
              ],
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* sign in button
            SizedBox(
              width: double.infinity, //? to make the sized button full width
              child: ElevatedButton(
                onPressed: () => Get.offAll(() => const NavigationMenu()),
                child: const Text(AppTexts.signIn),
              ),
            ),
            const Gap(AppSizes.spaceBtwItems),

            //* create account button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const UserTypeSelectionScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.surfaceContainerHigh,
                  foregroundColor: scheme.onSurfaceVariant,
                  side: BorderSide.none,
                ),
                child: const Text(AppTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
