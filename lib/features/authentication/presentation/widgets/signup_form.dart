import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/validators/validators.dart';
import 'package:homemade/features/authentication/controllers/signup_controller.dart';
import 'package:homemade/features/authentication/domain/user_type.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key, required this.userType});

  final UserType userType;

  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(48.0)),
    borderSide: BorderSide.none,
  );

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      labelText: label,
      prefixIcon: Icon(icon, color: scheme.primary),
      suffixIcon: suffixIcon,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) =>
                      CustomValidator.validateEmptyText('First name', value),
                  expands: false,
                  decoration: _decoration(
                    context,
                    label: AppTexts.firstName,
                    icon: Iconsax.user,
                  ),
                ),
              ),
              const Gap(AppSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) =>
                      CustomValidator.validateEmptyText('Last name', value),
                  expands: false,
                  decoration: _decoration(
                    context,
                    label: AppTexts.lastName,
                    icon: Iconsax.user,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSizes.spaceBtwInputFields),

          //* username
          TextFormField(
            controller: controller.userName,
            validator: (value) =>
                CustomValidator.validateEmptyText('Username', value),
            expands: false,
            decoration: _decoration(
              context,
              label: AppTexts.username,
              icon: Iconsax.user_edit,
            ),
          ),
          const Gap(AppSizes.spaceBtwInputFields),

          //* email
          TextFormField(
            controller: controller.email,
            validator: (value) => CustomValidator.validateEmail(value),
            decoration: _decoration(
              context,
              label: AppTexts.email,
              icon: Iconsax.direct_right,
            ),
          ),
          const Gap(AppSizes.spaceBtwInputFields),

          //* phone number
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) => CustomValidator.validatePhoneNumber(value),
            decoration: _decoration(
              context,
              label: AppTexts.phoneNumber,
              icon: Iconsax.call,
            ),
          ),
          const Gap(AppSizes.spaceBtwInputFields),

          //* seller-specific fields
          if (userType == UserType.seller) ...[
            TextFormField(
              controller: controller.restaurantName,
              validator: (value) =>
                  CustomValidator.validateEmptyText('Restaurant name', value),
              decoration: _decoration(
                context,
                label: AppTexts.restaurantName,
                icon: Iconsax.shop,
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),
            TextFormField(
              controller: controller.restaurantAddress,
              validator: (value) => CustomValidator.validateEmptyText(
                'Restaurant address',
                value,
              ),
              decoration: _decoration(
                context,
                label: AppTexts.restaurantAddress,
                icon: Iconsax.location,
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),
          ],

          //* delivery-specific fields
          if (userType == UserType.delivery) ...[
            TextFormField(
              controller: controller.vehicleType,
              validator: (value) =>
                  CustomValidator.validateEmptyText('Vehicle type', value),
              decoration: _decoration(
                context,
                label: AppTexts.vehicleType,
                icon: Iconsax.car,
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),
            TextFormField(
              controller: controller.licenseNumber,
              validator: (value) =>
                  CustomValidator.validateEmptyText('License number', value),
              decoration: _decoration(
                context,
                label: AppTexts.licenseNumber,
                icon: Iconsax.card,
              ),
            ),
            const Gap(AppSizes.spaceBtwInputFields),
          ],

          //* password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => CustomValidator.validatePassword(value),
              obscureText: controller.hidePassword.value,
              decoration: _decoration(
                context,
                label: AppTexts.password,
                icon: Iconsax.password_check,
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
          const Gap(AppSizes.spaceBtwInputFields),

          //* terms&conditions checkbox
          // const TermsAndConditionsCheckBox(),
          // const Gap(AppSizes.spaceBtwItems),

          //* sign up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const NavigationMenu()),
              child: const Text(AppTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
