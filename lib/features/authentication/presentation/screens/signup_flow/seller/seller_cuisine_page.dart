import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_chip_group.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class SellerCuisinePage extends GetView<SignupFlowController> {
  const SellerCuisinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isProfessional =
        controller.sellerCategory.value != SellerCategory.faitMaison;

    // DishType.valuesFor already gates by SellerCategory: traiteur sees
    // cocktailDinatoire, restaurant doesn't.
    final dishOptions =
        controller.sellerCategory.value == SellerCategory.traiteur
        ? DishType.valuesFor(SellerCategory.traiteur)
        : DishType.valuesFor(SellerCategory.restaurant);

    return SignupStepLayout(
      title: AppTexts.signupSellerCuisineTitle,
      description: AppTexts.signupSellerCuisineSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.signupSellerCuisineSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(AppSizes.sm + 4),
          Obx(
            () => SignupChipGroup<CuisineType>(
              options: CuisineType.values,
              selected: controller.cuisineTypes.toList(),
              labelOf: (c) => c.label,
              leadingOf: (c) => Image.asset(c.iconPath),
              onToggle: (c) {
                if (controller.cuisineTypes.contains(c)) {
                  controller.cuisineTypes.remove(c);
                } else {
                  controller.cuisineTypes.add(c);
                }
              },
            ),
          ),
          if (isProfessional) ...[
            const Gap(AppSizes.lg),
            Text(
              AppTexts.signupSellerCourseSection,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(AppSizes.sm + 4),
            Obx(
              () => SignupChipGroup<DishType>(
                options: dishOptions,
                selected: controller.dishTypes.toList(),
                labelOf: (d) => d.label,
                leadingOf: (d) => Image.asset(d.iconPath),
                onToggle: (d) {
                  if (controller.dishTypes.contains(d)) {
                    controller.dishTypes.remove(d);
                  } else {
                    controller.dishTypes.add(d);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
