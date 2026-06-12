import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';

/// Inline dial-code selector used as a phone field's prefix
/// ([SignupTextField.leading]). Tapping opens a searchable country picker and
/// updates the controller's [SignupFlowController.dialCode], so the composed
/// E.164 uses the chosen country (no more hardcoded +33).
class CountryCodeSelector extends StatelessWidget {
  const CountryCodeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCountryPicker(
        context: context,
        showPhoneCode: true,
        favorite: const ['FR', 'DZ'],
        onSelect: (country) => controller.setCountry(
          dialCode: '+${country.phoneCode}',
          flagEmoji: country.flagEmoji,
          isoCode: country.countryCode,
        ),
        countryListTheme: CountryListThemeData(
          backgroundColor: scheme.surface,
          textStyle: TextStyle(color: scheme.onSurface),
          searchTextStyle: TextStyle(color: scheme.onSurface),
          inputDecoration: InputDecoration(
            hintText: 'Rechercher un pays',
            prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: AppSizes.md, right: AppSizes.sm),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.countryFlag.value,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Text(
                controller.dialCode.value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
