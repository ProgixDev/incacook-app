import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/authentication/controllers/signup_controller.dart';

class TermsAndConditionsCheckBox extends StatelessWidget {
  const TermsAndConditionsCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final scheme = Theme.of(context).colorScheme;
    final linkColor = scheme.primary;
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
                  color: linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
              ),
              TextSpan(
                text: " ${AppTexts.and}  ",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: AppTexts.terms,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
