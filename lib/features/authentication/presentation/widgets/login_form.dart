import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/validators/validators.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/authentication/controllers/login_controller.dart';
import 'package:homemade/features/authentication/presentation/screens/forget_password.dart';
import 'package:homemade/features/authentication/presentation/screens/user_type_selection.dart';
import 'package:homemade/features/client/presentation/client_nav_tabs.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final scheme = Theme.of(context).colorScheme;
    final fieldRadius = BorderRadius.circular(48);

    InputDecoration decoration({
      required String label,
      required IconData prefixIcon,
      Widget? suffixIcon,
    }) {
      const border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(48.0)),
        borderSide: BorderSide.none,
      );
      return InputDecoration(
        filled: false,
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: scheme.primary),
        suffixIcon: suffixIcon,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      );
    }

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            //?Email
            FrostedSurface(
              borderRadius: fieldRadius,
              child: TextFormField(
                controller: controller.email,
                validator: (value) => CustomValidator.validateEmail(value),
                decoration: decoration(
                  label: AppTexts.email,
                  prefixIcon: Iconsax.direct_right,
                ),
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),

            //* password
            FrostedSurface(
              borderRadius: fieldRadius,
              child: Obx(
                () => TextFormField(
                  controller: controller.password,
                  validator: (value) =>
                      CustomValidator.validateEmptyText('Password', value),
                  obscureText: controller.hidePassword.value,
                  decoration: decoration(
                    label: AppTexts.password,
                    prefixIcon: Iconsax.password_check,
                    suffixIcon: IconButton(
                      onPressed: () => controller.hidePassword.value =
                          !controller.hidePassword.value,
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
            const Gap(AppSizes.spaceBtwInputFields / 2),

            //* remember me and forgot password — use Flexible + ellipsis so
            //* the long French labels don't overflow on narrow screens.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: (value) => controller.rememberMe.value =
                              !controller.rememberMe.value,
                          activeColor: scheme.primary,
                          checkColor: scheme.onPrimary,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const Gap(AppSizes.xs),
                      Flexible(
                        child: Text(
                          AppTexts.rememberMe,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    AppTexts.forgetPassword,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* sign in button
            SizedBox(
              width: double.infinity, //? to make the sized button full width
              child: ElevatedButton(
                onPressed: () => Get.offAll(
                  () => const NavigationMenu(tabs: kClientNavTabs),
                ),
                child: const Text(AppTexts.signIn),
              ),
            ),
            const Gap(AppSizes.spaceBtwItems),

            //* create account button — frosted to match the form fields.
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () =>
                      Get.to(() => const UserTypeSelectionScreen()),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.buttonRadius,
                      ),
                    ),
                  ),
                  child: const Text(AppTexts.createAccount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
