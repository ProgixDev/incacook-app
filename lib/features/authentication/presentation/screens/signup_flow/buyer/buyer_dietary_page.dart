import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_chip_group.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class BuyerDietaryPage extends GetView<SignupFlowController> {
  const BuyerDietaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupStepLayout(
      title: AppTexts.signupBuyerDietaryTitle,
      description: AppTexts.signupBuyerDietarySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.signupBuyerDietaryDietSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(AppSizes.sm + 4),
          Obx(
            () => SignupChipGroup<DietaryTag>(
              options: DietaryTag.values,
              selected: controller.dietaryPreferences.toList(),
              labelOf: (d) => d.label,
              leadingOf: (d) => Image.asset(d.iconPath),
              onToggle: (d) {
                if (controller.dietaryPreferences.contains(d)) {
                  controller.dietaryPreferences.remove(d);
                } else {
                  controller.dietaryPreferences.add(d);
                }
              },
            ),
          ),
          const Gap(AppSizes.lg),
          Text(
            AppTexts.signupBuyerDietaryAllergiesSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(AppSizes.xs),
          Text(
            AppTexts.signupBuyerDietaryAllergiesHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(AppSizes.sm + 4),
          Obx(
            () => SignupChipGroup<Allergen>(
              options: Allergen.values,
              selected: controller.allergies.toList(),
              labelOf: (a) => a.label,
              onToggle: (a) {
                if (controller.allergies.contains(a)) {
                  controller.allergies.remove(a);
                } else {
                  controller.allergies.add(a);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
