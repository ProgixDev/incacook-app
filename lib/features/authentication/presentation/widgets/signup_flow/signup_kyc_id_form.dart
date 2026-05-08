import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/id_document_type.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_chip_group.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';

/// Shared KYC ID-document form. Used identically by seller and driver
/// flows so all the upload-state plumbing lives in one place.
class SignupKycIdForm extends GetView<SignupFlowController> {
  const SignupKycIdForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.signupKycIdDocTypeLabel,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(AppSizes.sm + 4),
        Obx(
          () => SignupChipGroup<IdDocumentType>(
            options: IdDocumentType.values,
            selected: controller.idDocumentType.value == null
                ? const []
                : [controller.idDocumentType.value!],
            labelOf: (t) => t.label,
            singleSelect: true,
            onToggle: (t) {
              controller.idDocumentType.value = t;
              if (!t.requiresVerso) controller.idBackPath.value = '';
            },
          ),
        ),
        const Gap(AppSizes.lg),
        Obx(() {
          final docType = controller.idDocumentType.value;
          final showVerso = docType?.requiresVerso ?? true;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SignupImagePicker(
                  path: controller.idFrontPath.value,
                  onChanged: (p) => controller.idFrontPath.value = p,
                  variant: SignupImagePickerVariant.rectangular,
                  size: 120,
                  label: AppTexts.signupKycIdRecto,
                ),
              ),
              if (showVerso) ...[
                const Gap(AppSizes.sm + 4),
                Expanded(
                  child: SignupImagePicker(
                    path: controller.idBackPath.value,
                    onChanged: (p) => controller.idBackPath.value = p,
                    variant: SignupImagePickerVariant.rectangular,
                    size: 120,
                    label: AppTexts.signupKycIdVerso,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
