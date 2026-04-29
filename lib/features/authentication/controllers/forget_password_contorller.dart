import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  //* variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }

  //* send reset password email
  // void sendPasswordResetEmail() async {
  //   try {
  //     //* start loading
  //     CustomFullscreenLoader.openLoadingDialog(
  //       'Processing your request...',
  //       AppAnimations.check,
  //     );

  //     //* check internet connection
  //     final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* form validation
  //     if (!forgetPasswordFormKey.currentState!.validate()) {
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* send email to reset password
  //     await AuthenticationRepository.instance
  //         .sendPasswordResetEmail(email.text.trim());

  //     //* remove loader
  //     CustomFullscreenLoader.stopLoading();

  //     //* show success screen
  //     CustomLoaders.successSnackBar(
  //       title: 'Email sent',
  //       message: 'Email link sent to reset your password'.tr,
  //     );

  //     //* redirec
  //     Get.to(
  //       () => ResetPasswordScreen(
  //         email: email.text.trim(),
  //       ),
  //     );
  //   } catch (e) {
  //     //* remove loader
  //     CustomFullscreenLoader.stopLoading();
  //     CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
  //   }
  // }

  // resendPasswordResetEmail(String email) async {
  //   try {
  //     //* start loading
  //     CustomFullscreenLoader.openLoadingDialog(
  //       'Processing your request...',
  //       TAnimations.check,
  //     );

  //     //* check internet connection
  //     final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* send email to reset password
  //     await AuthenticationRepository.instance.sendPasswordResetEmail(email);

  //     //* remove loader
  //     CustomFullscreenLoader.stopLoading();

  //     //* show success screen
  //     CustomLoaders.successSnackBar(
  //       title: 'Email sent',
  //       message: 'Email link sent to reset your password'.tr,
  //     );
  //   } catch (e) {
  //     //* remove loader
  //     CustomFullscreenLoader.stopLoading();
  //     CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
  //   }
  // }
}
