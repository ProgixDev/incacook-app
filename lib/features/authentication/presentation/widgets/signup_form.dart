import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/features/seller/presentation/seller_nav_tabs.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/validators/validators.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/controllers/signup_controller.dart';
import 'package:incacook/features/authentication/domain/user_type.dart';
import 'package:incacook/features/client/presentation/client_nav_tabs.dart';
import 'package:incacook/features/delivery/presentation/screens/delivery_home.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key, required this.userType});

  final UserType userType;

  Widget _homeForUserType() {
    return switch (userType) {
      UserType.client => const NavigationMenu(tabs: kClientNavTabs),
      UserType.delivery => const DeliveryHomeScreen(),
      UserType.seller => const NavigationMenu(tabs: kSellerNavTabs),
    };
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
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
                child: FrostedSurface(
                  borderRadius: BorderRadius.circular(999),
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) =>
                        CustomValidator.validateEmptyText('First name', value),
                    decoration: _decoration(
                      label: AppTexts.firstName,
                      icon: Iconsax.user,
                    ),
                  ),
                ),
              ),
              const Gap(AppSizes.spaceBtwInputFields),
              Expanded(
                child: FrostedSurface(
                  borderRadius: BorderRadius.circular(999),
                  child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) =>
                        CustomValidator.validateEmptyText('Last name', value),
                    decoration: _decoration(
                      label: AppTexts.lastName,
                      icon: Iconsax.user,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSizes.sm),

          //* username
          FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            child: TextFormField(
              controller: controller.userName,
              validator: (value) =>
                  CustomValidator.validateEmptyText('Username', value),
              decoration: _decoration(
                label: AppTexts.username,
                icon: Iconsax.user_edit,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* email
          FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            child: TextFormField(
              controller: controller.email,
              validator: (value) => CustomValidator.validateEmail(value),
              decoration: _decoration(
                label: AppTexts.email,
                icon: Iconsax.direct_right,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* phone number
          FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            child: TextFormField(
              controller: controller.phoneNumber,
              validator: (value) => CustomValidator.validatePhoneNumber(value),
              decoration: _decoration(
                label: AppTexts.phoneNumber,
                icon: Iconsax.call,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* seller-specific fields
          if (userType == UserType.seller) ...[
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: TextFormField(
                controller: controller.restaurantName,
                validator: (value) =>
                    CustomValidator.validateEmptyText('Restaurant name', value),
                decoration: _decoration(
                  label: AppTexts.restaurantName,
                  icon: Iconsax.shop,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: TextFormField(
                controller: controller.restaurantAddress,
                validator: (value) => CustomValidator.validateEmptyText(
                  'Restaurant address',
                  value,
                ),
                decoration: _decoration(
                  label: AppTexts.restaurantAddress,
                  icon: Iconsax.location,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
          ],

          //* delivery-specific fields
          if (userType == UserType.delivery) ...[
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: TextFormField(
                controller: controller.vehicleType,
                validator: (value) =>
                    CustomValidator.validateEmptyText('Vehicle type', value),
                decoration: _decoration(
                  label: AppTexts.vehicleType,
                  icon: Iconsax.car,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: TextFormField(
                controller: controller.licenseNumber,
                validator: (value) =>
                    CustomValidator.validateEmptyText('License number', value),
                decoration: _decoration(
                  label: AppTexts.licenseNumber,
                  icon: Iconsax.card,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
          ],

          //* password
          Obx(
            () => FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              child: TextFormField(
                controller: controller.password,
                validator: (value) => CustomValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: _decoration(
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
          ),
          const Gap(AppSizes.md),

          //* sign up button — routes to the home screen matching the
          //* selected user type.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(_homeForUserType),
              child: const Text(AppTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
