import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
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
          //* Seller category — picking it drives the rest of the wizard
          //* (business info + KYC for TRAITEUR / RESTAURANT) and the price
          //* rules. Defaults to fait-maison when untouched.
          _SubtypePicker(controller: controller),
          const Gap(AppSizes.lg),
          Center(
            child: Obx(
              () => SignupImagePicker(
                path: controller.profilePhotoUrl.value,
                onChanged: (p) => controller.profilePhotoUrl.value = p,
                purpose: UploadPurpose.avatar,
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

/// The 3-way seller category picker. A null selection is treated as
/// fait-maison (the default the rest of the wizard + backend assume), so
/// fait-maison stays pre-selected and TRAITEUR / RESTAURANT are now
/// selectable — which activates their business-info + KYC steps.
class _SubtypePicker extends StatelessWidget {
  const _SubtypePicker({required this.controller});

  final SignupFlowController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final selected =
          controller.sellerCategory.value ?? SellerCategory.faitMaison;
      void pick(SellerCategory c) => controller.sellerCategory.value = c;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.signupSubtypeTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(2),
          Text(
            AppTexts.signupSubtypeSubtitle,
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Gap(AppSizes.md),
          _SubtypeCard(
            title: AppTexts.signupSubtypeFaitMaisonTitle,
            subtitle: AppTexts.signupSubtypeFaitMaisonSubtitle,
            note: AppTexts.signupSubtypeFaitMaisonNote,
            selected: selected == SellerCategory.faitMaison,
            onTap: () => pick(SellerCategory.faitMaison),
          ),
          const Gap(AppSizes.sm),
          _SubtypeCard(
            title: AppTexts.signupSubtypeTraiteurTitle,
            subtitle: AppTexts.signupSubtypeTraiteurSubtitle,
            selected: selected == SellerCategory.traiteur,
            onTap: () => pick(SellerCategory.traiteur),
          ),
          const Gap(AppSizes.sm),
          _SubtypeCard(
            title: AppTexts.signupSubtypeRestaurantTitle,
            subtitle: AppTexts.signupSubtypeRestaurantSubtitle,
            selected: selected == SellerCategory.restaurant,
            onTap: () => pick(SellerCategory.restaurant),
          ),
        ],
      );
    });
  }
}

class _SubtypeCard extends StatelessWidget {
  const _SubtypeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.note,
  });

  final String title;
  final String subtitle;
  final String? note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fg = selected ? colors.selectedOnSurface : scheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: selected ? colors.selectedSurface : scheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(
            color: selected
                ? colors.selectedOnSurface
                : scheme.outline.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700, color: fg),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: selected
                          ? colors.selectedOnSurface.withValues(alpha: 0.8)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  if (note != null) ...[
                    const Gap(4),
                    Text(
                      note!,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? colors.selectedOnSurface : scheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? colors.selectedOnSurface : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
