import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/authentication/controllers/user_type_selection_controller.dart';
import 'package:homemade/features/authentication/presentation/widgets/user_type_dot_navigation.dart';
import 'package:homemade/features/authentication/presentation/widgets/user_type_page.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserTypeSelectionController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CustomAppBar(showBackArrow: true),
      body: SafeArea(
        child: Column(
          children: [
            //* heading
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  Text(
                    AppTexts.userTypeHeading,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppSizes.sm),
                  Text(
                    AppTexts.userTypeSubHeading,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            //* horizontal pages
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
                  UserTypePage(
                    animation: AppAnimations.userTypeClient,
                    title: AppTexts.userTypeClientTitle,
                    subtitle: AppTexts.userTypeClientSubtitle,
                  ),
                  UserTypePage(
                    animation: AppAnimations.userTypeSeller,
                    title: AppTexts.userTypeSellerTitle,
                    subtitle: AppTexts.userTypeSellerSubtitle,
                  ),
                  UserTypePage(
                    animation: AppAnimations.userTypeDelivery,
                    title: AppTexts.userTypeDeliveryTitle,
                    subtitle: AppTexts.userTypeDeliverySubtitle,
                  ),
                ],
              ),
            ),

            //* dot indicator
            const UserTypeDotNavigation(),

            //* continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.defaultSpace,
                AppSizes.sm,
                AppSizes.defaultSpace,
                AppSizes.defaultSpace,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.continueToSignup,
                  child: const Text(AppTexts.sayContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
