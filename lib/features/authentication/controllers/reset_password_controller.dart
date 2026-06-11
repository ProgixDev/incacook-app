import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';
import 'package:incacook/core/utils/popups/fullscreen_loader.dart';
import 'package:incacook/features/authentication/data/models/requests/password_reset_request.dart';
import 'package:incacook/features/authentication/data/models/requests/password_update_request.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/presentation/screens/login.dart';

/// Drives the second half of the forgot-password flow: confirm the 6-digit
/// code emailed by `reset-request`, then set a new password.
///
/// The chain is three backend calls:
///   1. `verify-reset-otp` → recovery session (persisted as the bearer).
///   2. `password/update` → sets the new password using that bearer.
///   3. `signout` → drop the recovery session so the user logs in fresh.
class ResetPasswordController extends GetxController {
  ResetPasswordController({
    required this.email,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final String email;
  final AuthRepository _authRepository;

  final code = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final hidePassword = true.obs;
  final isLoading = false.obs;

  /// Seconds remaining before "Renvoyer le code" re-enables.
  final resendSecondsLeft = 0.obs;
  Timer? _resendTimer;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // We arrive here right after a code was sent, so start the cooldown.
    _startResendCooldown();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    code.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }

  String? validateCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return AppTexts.resetCodeRequired;
    if (!RegExp(r'^\d{6,10}$').hasMatch(v)) return AppTexts.resetCodeInvalid;
    return null;
  }

  String? validateConfirm(String? value) {
    if (value != password.text) return AppTexts.passwordsDoNotMatch;
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;
    isLoading.value = true;

    var loaderShown = false;
    try {
      CustomFullscreenLoader.openLoadingDialog(
        'Réinitialisation...',
        AppAnimations.loading,
      );
      loaderShown = true;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;

      // 1. Confirm the code → recovery session (tokens persisted).
      await _authRepository.verifyResetOtp(
        email: email,
        code: code.text.trim(),
      );

      // 2. Set the new password using the recovery bearer.
      await _authRepository.updatePassword(
        PasswordUpdateRequest(newPassword: password.text),
      );

      // 3. Drop the recovery session so the user logs in fresh. Swallow any
      // signout error — the password is already changed; tokens are cleared
      // regardless by AuthRepository.signout's finally.
      try {
        await _authRepository.signout();
      } catch (_) {}

      CustomFullscreenLoader.stopLoading();
      loaderShown = false;

      CustomLoaders.successSnackBar(
        title: 'Mot de passe modifié',
        message: AppTexts.resetPasswordSuccess,
      );
      Get.offAll<void>(() => const LoginScreen());
    } on ApiFailure catch (e) {
      // 400 from verify-reset-otp = wrong/expired code; show friendly copy.
      final message =
          e.statusCode == 400 ? AppTexts.resetCodeInvalidOrExpired : e.message;
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: message);
    } catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    } finally {
      if (loaderShown) CustomFullscreenLoader.stopLoading();
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (resendSecondsLeft.value > 0) return;
    try {
      await _authRepository.requestPasswordReset(
        PasswordResetRequest(email: email),
      );
      CustomLoaders.successSnackBar(
        title: 'Code renvoyé',
        message: 'Un nouveau code a été envoyé à $email',
      );
      _startResendCooldown();
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendSecondsLeft.value = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSecondsLeft.value <= 1) {
        resendSecondsLeft.value = 0;
        t.cancel();
      } else {
        resendSecondsLeft.value--;
      }
    });
  }
}