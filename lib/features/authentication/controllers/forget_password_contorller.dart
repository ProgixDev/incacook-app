import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';
import 'package:incacook/core/utils/popups/fullscreen_loader.dart';
import 'package:incacook/features/authentication/data/models/requests/password_reset_request.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/presentation/screens/reset_password.dart';

class ForgetPasswordController extends GetxController {
  ForgetPasswordController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? Get.find<AuthRepository>();

  static ForgetPasswordController get instance => Get.find();

  final AuthRepository _authRepository;

  //* variables
  final email = TextEditingController();
  final isLoading = false.obs;
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }

  /// Triggers `POST /v1/auth/password/reset-request`, which has Supabase
  /// email a 6-digit recovery code to [email]. On success we hand off to
  /// [ResetPasswordScreen], where the user enters that code and picks a new
  /// password.
  Future<void> sendPasswordResetEmail() async {
    if (!(forgetPasswordFormKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;
    isLoading.value = true;

    var loaderShown = false;
    try {
      CustomFullscreenLoader.openLoadingDialog(
        'Envoi du code de réinitialisation...',
        AppAnimations.loading,
      );
      loaderShown = true;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        // NetworkManager itself toasts; just bail before hitting the wire.
        return;
      }

      final target = email.text.trim();
      await _authRepository.requestPasswordReset(
        PasswordResetRequest(email: target),
      );

      // Stop the loader before navigating so it doesn't outlive the route.
      CustomFullscreenLoader.stopLoading();
      loaderShown = false;

      CustomLoaders.successSnackBar(
        title: 'Email envoyé',
        message: 'Un code de réinitialisation a été envoyé à $target',
      );
      Get.to<void>(() => ResetPasswordScreen(email: target));
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
    } catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    } finally {
      if (loaderShown) CustomFullscreenLoader.stopLoading();
      isLoading.value = false;
    }
  }
}