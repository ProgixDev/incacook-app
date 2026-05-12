import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/helpers/network_manager.dart';
import 'package:incacook/core/utils/popups/fullscreen_loader.dart';
import 'package:incacook/features/authentication/data/models/requests/signin_request.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/client/presentation/client_nav_tabs.dart';
import 'package:incacook/features/delivery/presentation/screens/delivery_home.dart';
import 'package:incacook/features/seller/presentation/seller_nav_tabs.dart';

class LoginController extends GetxController {
  LoginController({
    AuthRepository? authRepository,
    UsersRepository? usersRepository,
  }) : _authRepository = authRepository ?? Get.find<AuthRepository>(),
       _usersRepository = usersRepository ?? Get.find<UsersRepository>();

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;

  // Form state.
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final hidePassword = true.obs;
  final rememberMe = false.obs;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Network state.
  final isLoading = false.obs;
  final submitError = ''.obs;

  static const _kRememberEmail = 'incacook.remember_me_email';

  @override
  void onInit() {
    super.onInit();
    // Restore the last-used email if the user previously checked
    // "remember me". Password is intentionally NOT cached — that's what
    // refresh tokens (`flutter_secure_storage`) are for.
    final saved = localStorage.read<String>(_kRememberEmail);
    if (saved != null && saved.isNotEmpty) {
      email.text = saved;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  /// Email + password sign-in.
  ///
  /// On success, persists tokens (via [AuthRepository.signin]'s side
  /// effect), fetches the user's onboarding state, and routes:
  ///   - `next == null` → the role's home screen
  ///   - any non-null `next` (or onboarding endpoint errors, e.g. when
  ///     the user has tokens but no IncaCook profile row yet) → the
  ///     signup wizard, which picks up from wherever they left off.
  Future<void> emailAndPasswordSignIn() async {
    submitError.value = '';
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      //* start loading
      CustomFullscreenLoader.openLoadingDialog(
        'Logging in...',
        AppAnimations.loading,
      );

      //* check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        CustomFullscreenLoader.stopLoading();
        isLoading.value = false;
        return;
      }

      //* login user using email and password authentication
      await _authRepository.signin(
        SigninRequest(
          email: email.text.trim(),
          password: password.text,
        ),
      );

      //* save data if remember me is selected
      if (rememberMe.value) {
        await localStorage.write(_kRememberEmail, email.text.trim());
      } else {
        await localStorage.remove(_kRememberEmail);
      }

      //* route depending on the user's signup completion
      await _routeAfterSignin();
    } on ApiFailure catch (e) {
      //* remove the loader
      CustomFullscreenLoader.stopLoading();

      // §3.2: 401 → wrong credentials; the message is intentionally
      // vague server-side ("invalid email or password") so we surface
      // it as-is. Other failures surface the backend message verbatim.
      submitError.value = e.message;

      //* show some generic error to the user
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
    } catch (e) {
      //* remove the loader
      CustomFullscreenLoader.stopLoading();
      submitError.value = e.toString();
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Decide where to drop the user post-signin. The onboarding endpoint
  /// is the single source of truth — see `docs/signup-flow.md` §4.
  Future<void> _routeAfterSignin() async {
    try {
      final state = await _usersRepository.fetchOnboarding();
      CustomFullscreenLoader.stopLoading(); // stop loading before redirecting
      if (state.next == null) {
        _goToRoleHome(state.role);
        return;
      }
    } catch (e) {
      CustomFullscreenLoader.stopLoading(); // stop loading before redirecting
      // No profile row yet (signed up but abandoned the wizard) —
      // drop into /signup. Future: wire cold-start wizard resume so
      // the wizard pages to the right step.
    }
    Get.offAllNamed<void>('/signup');
  }

  void _goToRoleHome(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        Get.offAll<void>(() => const NavigationMenu(tabs: kClientNavTabs));
      case UserRole.seller:
        Get.offAll<void>(() => const NavigationMenu(tabs: kSellerNavTabs));
      case UserRole.driver:
        Get.offAll<void>(() => const DeliveryHomeScreen());
    }
  }
}
