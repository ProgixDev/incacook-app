import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/onboarding/controllers/onboarding_controller.dart';
import 'package:incacook/features/onboarding/presentation/widgets/onboarding_dot_navigation.dart';
import 'package:incacook/features/onboarding/presentation/widgets/onboarding_next_button.dart';
import 'package:incacook/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:incacook/features/onboarding/presentation/widgets/onboarding_skip.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
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
