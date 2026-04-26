import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/constants/colors.dart';
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
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.accent,
                prefixIcon: Icon(
                  Iconsax.direct_right,
                  color: AppColors.primary,
                ),
                labelText: AppTexts.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
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
                  fillColor: AppColors.accent,
                  labelText: AppTexts.password,
                  prefixIcon: const Icon(
                    Iconsax.password_check,
                    color: AppColors.primary,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
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
                        activeColor: AppColors.primary,
                        checkColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const Text(
                      AppTexts.rememberMe,
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),

                //* forget password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                  child: const Text(
                    AppTexts.forgetPassword,
                    style: TextStyle(color: AppColors.secondary),
                  ),
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
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.grey,
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
