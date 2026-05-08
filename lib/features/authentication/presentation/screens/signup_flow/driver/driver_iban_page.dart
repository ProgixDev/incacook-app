import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class DriverIbanPage extends StatelessWidget {
  const DriverIbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SignupStepLayout(
      title: AppTexts.signupDriverIbanTitle,
      description: AppTexts.signupDriverIbanSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => SignupTextField(
                label: AppTexts.signupDriverIbanLabel,
                hint: AppTexts.signupDriverIbanHint,
                leadingIcon: Iconsax.card,
                initialValue: controller.iban.value,
                onChanged: (v) => controller.iban.value = v,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9\s]'),
                  ),
                  _IbanFormatter(),
                  LengthLimitingTextInputFormatter(34),
                ],
                errorText: controller.iban.value.isEmpty ||
                        controller.isIbanValid
                    ? null
                    : AppTexts.signupDriverIbanError,
              )),
          const Gap(AppSizes.md),
          SignupTextField(
            label: AppTexts.signupDriverIbanHolderLabel,
            hint: AppTexts.signupDriverIbanHolderHint,
            leadingIcon: Iconsax.user,
            initialValue: controller.ibanHolderName.value,
            onChanged: (v) => controller.ibanHolderName.value = v,
          ),
          const Gap(AppSizes.sm + 4),
          Text(
            AppTexts.signupDriverIbanFooter,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.sm + 4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 18, color: scheme.primary),
                const Gap(AppSizes.sm),
                Expanded(
                  child: Text(
                    AppTexts.signupDriverIbanSecure,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IbanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(raw[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
