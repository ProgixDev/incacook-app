import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incacook/features/authentication/presentation/screens/welcome.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  //* variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  //* update current index when page scroll
  void updatePageIndicator(int index) => currentPageIndex.value = index;

  //* jump to the new specific dot selected page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index.toDouble());
  }

  //* update current index and jump to next page
  void nextPage() {
    //? change the value depending on how many pages we do have
    if (currentPageIndex.value == 3) {
      final storage = GetStorage();
      if (kDebugMode) {
        print("================ Get Storage NEXT BUTTON ================");
        print(storage.read('isFirstTime'));
      }

      storage.write(
        'isFirstTime',
        false,
      ); //? mark that this is not the user's first time anymore

      if (kDebugMode) {
        print("================ Get Storage NEXT BUTTON ================");
        print(storage.read('isFirstTime'));
      }

      Get.offAll(() => const WelcomeScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  //* update current index and jump to last page
  void skipPage() {
    currentPageIndex.value = 3; //? values start from 0, 1, 2, 3
    pageController.jumpToPage(3);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
