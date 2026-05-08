import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_address_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class BuyerAddressPage extends StatefulWidget {
  const BuyerAddressPage({super.key});

  @override
  State<BuyerAddressPage> createState() => _BuyerAddressPageState();
}

class _BuyerAddressPageState extends State<BuyerAddressPage> {
  bool _detailsOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;

    return SignupStepLayout(
      title: AppTexts.signupBuyerAddressTitle,
      description: AppTexts.signupBuyerAddressSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => SignupAddressPicker(
                value: controller.deliveryAddress.value,
                onChanged: (a) => controller.deliveryAddress.value = a,
              )),
          const Gap(AppSizes.md),
          InkWell(
            onTap: () => setState(() => _detailsOpen = !_detailsOpen),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Row(
                children: [
                  Icon(
                    _detailsOpen
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: scheme.primary,
                  ),
                  const Gap(AppSizes.sm),
                  Text(
                    AppTexts.signupBuyerAddressDetailsToggle,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: !_detailsOpen
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(AppSizes.sm),
                      Row(
                        children: [
                          Expanded(
                            child: SignupTextField(
                              label: AppTexts.signupBuyerApartmentLabel,
                              hint: AppTexts.signupBuyerApartmentHint,
                              onChanged: (v) =>
                                  _patch(controller, apartment: v),
                            ),
                          ),
                          const Gap(AppSizes.sm + 4),
                          Expanded(
                            child: SignupTextField(
                              label: AppTexts.signupBuyerFloorLabel,
                              hint: AppTexts.signupBuyerFloorHint,
                              onChanged: (v) => _patch(controller, floor: v),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSizes.md),
                      SignupTextField(
                        label: AppTexts.signupBuyerDigicodeLabel,
                        hint: AppTexts.signupBuyerDigicodeHint,
                        onChanged: (v) => _patch(controller, digicode: v),
                      ),
                      const Gap(AppSizes.md),
                      SignupTextField(
                        label: AppTexts.signupBuyerInstructionsLabel,
                        hint: AppTexts.signupBuyerInstructionsHint,
                        maxLines: 3,
                        onChanged: (v) =>
                            _patch(controller, deliveryNotes: v),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _patch(
    SignupFlowController controller, {
    String? apartment,
    String? floor,
    String? digicode,
    String? deliveryNotes,
  }) {
    final base = controller.deliveryAddress.value;
    if (base == null) return;
    controller.deliveryAddress.value = base.copyWith(
      apartment: apartment ?? base.apartment,
      floor: floor ?? base.floor,
      digicode: digicode ?? base.digicode,
      deliveryNotes: deliveryNotes ?? base.deliveryNotes,
    );
  }
}
