import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/constants/animations.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/onboarding/controllers/onboarding_controller.dart';
import 'package:vinted_v2/features/onboarding/presentation/widgets/onboarding_dot_navigation.dart';
import 'package:vinted_v2/features/onboarding/presentation/widgets/onboarding_next_button.dart';
import 'package:vinted_v2/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:vinted_v2/features/onboarding/presentation/widgets/onboarding_skip.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          //* horizontal scrollable pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                animation: AppImages.onboarding1,
                title: AppTexts.onBoardingTitle1,
                subtitle: AppTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                animation: AppImages.onboarding2,
                title: AppTexts.onBoardingTitle2,
                subtitle: AppTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                animation: AppImages.onboarding3,
                title: AppTexts.onBoardingTitle3,
                subtitle: AppTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          //? skip button
          const OnBoardingSkip(),

          //? dot naviagator smoothPageIndicator
          const OnBoardingDotNavigation(),

          //? circular button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}
