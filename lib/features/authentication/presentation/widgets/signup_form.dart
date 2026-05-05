import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/features/seller/presentation/seller_nav_tabs.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/validators/validators.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/authentication/controllers/signup_controller.dart';
import 'package:homemade/features/authentication/domain/user_type.dart';
import 'package:homemade/features/client/presentation/client_nav_tabs.dart';
import 'package:homemade/features/delivery/presentation/screens/delivery_home.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key, required this.userType});

  final UserType userType;

  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(48.0)),
    borderSide: BorderSide.none,
  );

  static final _fieldRadius = BorderRadius.circular(48);

  Widget _homeForUserType() {
    return switch (userType) {
      UserType.client => const NavigationMenu(tabs: kClientNavTabs),
      UserType.delivery => const DeliveryHomeScreen(),
      UserType.seller => const NavigationMenu(tabs: kSellerNavTabs),
    };
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: false,
      isDense: true,
      labelText: label,
      prefixIcon: Icon(icon, color: scheme.primary),
      suffixIcon: suffixIcon,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder,
    );
  }

  Widget _frosted(Widget child) =>
      FrostedSurface(borderRadius: _fieldRadius, child: child);

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
                child: _frosted(
                  TextFormField(
                    controller: controller.firstName,
                    validator: (value) => CustomValidator.validateEmptyText(
                      'First name',
                      value,
                    ),
                    decoration: _decoration(
                      context,
                      label: AppTexts.firstName,
                      icon: Iconsax.user,
                    ),
                  ),
                ),
              ),
              const Gap(AppSizes.spaceBtwInputFields),
              Expanded(
                child: _frosted(
                  TextFormField(
                    controller: controller.lastName,
                    validator: (value) => CustomValidator.validateEmptyText(
                      'Last name',
                      value,
                    ),
                    decoration: _decoration(
                      context,
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
          _frosted(
            TextFormField(
              controller: controller.userName,
              validator: (value) =>
                  CustomValidator.validateEmptyText('Username', value),
              decoration: _decoration(
                context,
                label: AppTexts.username,
                icon: Iconsax.user_edit,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* email
          _frosted(
            TextFormField(
              controller: controller.email,
              validator: (value) => CustomValidator.validateEmail(value),
              decoration: _decoration(
                context,
                label: AppTexts.email,
                icon: Iconsax.direct_right,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* phone number
          _frosted(
            TextFormField(
              controller: controller.phoneNumber,
              validator: (value) => CustomValidator.validatePhoneNumber(value),
              decoration: _decoration(
                context,
                label: AppTexts.phoneNumber,
                icon: Iconsax.call,
              ),
            ),
          ),
          const Gap(AppSizes.sm),

          //* seller-specific fields
          if (userType == UserType.seller) ...[
            _frosted(
              TextFormField(
                controller: controller.restaurantName,
                validator: (value) => CustomValidator.validateEmptyText(
                  'Restaurant name',
                  value,
                ),
                decoration: _decoration(
                  context,
                  label: AppTexts.restaurantName,
                  icon: Iconsax.shop,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            _frosted(
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
            ),
            const Gap(AppSizes.sm),
          ],

          //* delivery-specific fields
          if (userType == UserType.delivery) ...[
            _frosted(
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
            ),
            const Gap(AppSizes.sm),
            _frosted(
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
            ),
            const Gap(AppSizes.sm),
          ],

          //* password
          Obx(
            () => _frosted(
              TextFormField(
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
