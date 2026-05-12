import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class DriverDocumentsPage extends StatelessWidget {
  const DriverDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;
    return SignupStepLayout(
      title: AppTexts.signupDriverDocsTitle,
      description: AppTexts.signupDriverDocsSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => SignupImagePicker(
              path: controller.drivingLicenseUrl.value,
              onChanged: (p) => controller.drivingLicenseUrl.value = p,
              purpose: UploadPurpose.kycDocument,
              variant: SignupImagePickerVariant.rectangular,
              size: 140,
              label: AppTexts.signupDriverLicenseLabel,
              helper: AppTexts.signupDriverLicenseHelper,
            ),
          ),
          const Gap(AppSizes.md),
          Obx(
            () => SignupImagePicker(
              path: controller.carteGriseUrl.value,
              onChanged: (p) => controller.carteGriseUrl.value = p,
              purpose: UploadPurpose.kycDocument,
              variant: SignupImagePickerVariant.rectangular,
              size: 140,
              label: AppTexts.signupDriverCarteGriseLabel,
              helper: AppTexts.signupDriverCarteGriseHelper,
            ),
          ),
          const Gap(AppSizes.md),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: scheme.primary),
              const Gap(AppSizes.sm),
              Expanded(
                child: Text(
                  AppTexts.signupDriverDocsSecurityNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
