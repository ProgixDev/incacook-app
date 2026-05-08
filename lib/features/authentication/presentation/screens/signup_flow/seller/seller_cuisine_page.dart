import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/course_type.dart';
import 'package:incacook/features/authentication/data/models/cuisine_type.dart';
import 'package:incacook/features/authentication/data/models/seller_sub_type.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_chip_group.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class SellerCuisinePage extends GetView<SignupFlowController> {
  const SellerCuisinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isProfessional =
        controller.sellerSubType.value != SellerSubType.faitMaison;

    final courseOptions =
        controller.sellerSubType.value == SellerSubType.traiteur
        ? CourseType.values
        : CourseType.values.where((c) => c != CourseType.cocktail).toList();

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
              () => SignupChipGroup<CourseType>(
                options: courseOptions,
                selected: controller.courseTypes.toList(),
                labelOf: (c) => c.label,
                leadingOf: (c) => Image.asset(c.iconPath),
                onToggle: (c) {
                  if (controller.courseTypes.contains(c)) {
                    controller.courseTypes.remove(c);
                  } else {
                    controller.courseTypes.add(c);
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
