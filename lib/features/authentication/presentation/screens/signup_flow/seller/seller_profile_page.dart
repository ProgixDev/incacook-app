import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final isProfessional =
        controller.sellerCategory.value != SellerCategory.faitMaison;

    return SignupStepLayout(
      title: AppTexts.signupSellerProfileTitle,
      description: AppTexts.signupSellerProfileSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Obx(
              () => SignupImagePicker(
                path: controller.profilePhotoUrl.value,
                onChanged: (p) => controller.profilePhotoUrl.value = p,
                size: 112,
              ),
            ),
          ),
          const Gap(AppSizes.lg),
          SignupTextField(
            label: isProfessional
                ? AppTexts.signupSellerDisplayNameLabelPro
                : AppTexts.signupSellerDisplayNameLabel,
            hint: isProfessional
                ? AppTexts.signupSellerDisplayNameHintPro
                : AppTexts.signupSellerDisplayNameHint,
            initialValue: controller.displayName.value,
            onChanged: (v) => controller.displayName.value = v,
          ),
          const Gap(AppSizes.md),
          Obx(() {
            return SignupTextField(
              label: AppTexts.signupSellerBioLabel,
              hint: AppTexts.signupSellerBioHint,
              maxLines: 4,
              minLines: 3,
              maxLength: 200,
              initialValue: controller.bio.value,
              onChanged: (v) => controller.bio.value = v,
              helperText: AppTexts.signupSellerBioCounter(
                controller.bio.value.length,
              ),
            );
          }),
        ],
      ),
    );
  }
}
