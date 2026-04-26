import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/features/authentication/domain/user_type.dart';
import 'package:homemade/features/authentication/presentation/screens/signup.dart';

class UserTypeSelectionController extends GetxController {
  static UserTypeSelectionController get instance => Get.find();

  final pageController = PageController();
  final Rx<int> currentPageIndex = 0.obs;

  static const List<UserType> pageOrder = [
    UserType.client,
    UserType.seller,
    UserType.delivery,
  ];

  UserType get selectedUserType => pageOrder[currentPageIndex.value];

  void updatePageIndicator(int index) => currentPageIndex.value = index;

  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void continueToSignup() {
    Get.to(() => SignupScreen(userType: selectedUserType));
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
