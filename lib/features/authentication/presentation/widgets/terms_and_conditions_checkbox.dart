import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/authentication/controllers/signup_controller.dart';

class TermsAndConditionsCheckBox extends StatelessWidget {
  const TermsAndConditionsCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = DeviceUtils.isDarkMode(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) => controller.privacyPolicy.value =
                  !controller.privacyPolicy.value,
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "${AppTexts.iAgreeTo} ",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: AppTexts.privacy,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? Colors.white : AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? Colors.white : AppColors.primary,
                ),
              ),
              TextSpan(
                text: " ${AppTexts.and}  ",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: AppTexts.terms,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? Colors.white : AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
