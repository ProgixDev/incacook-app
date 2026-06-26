import 'package:get/get.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/core/services/biometric_auth_service.dart';
import 'package:incacook/core/services/biometric_preference.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';

/// Drives the optional "Connexion biométrique" button on the login screen.
///
/// The button is OFFERED only when ALL of these hold:
///   * the user opted into biometrics ([BiometricPreference.isEnabled]),
///   * a valid session/token is still stored (so they logged in normally once),
///   * the device actually supports biometrics.
///
/// On success it does NOT derive any identity from biometrics — it unlocks the
/// already-stored session and validates/refreshes it through the EXISTING
/// backend auth flow ([PostAuthRouter.decide], which rides the AuthInterceptor's
/// silent refresh), then routes like a normal login. Never logs tokens or
/// biometric results.
class BiometricLoginController extends GetxController {
  BiometricLoginController({
    BiometricAuthService? biometric,
    TokenStorage? tokenStorage,
    PostAuthRouter? router,
  })  : _biometric = biometric ?? BiometricAuthService(),
        _tokens = tokenStorage ?? Get.find<TokenStorage>(),
        _router = router ?? Get.find<PostAuthRouter>();

  final BiometricAuthService _biometric;
  final TokenStorage _tokens;
  final PostAuthRouter _router;

  /// Whether to show the biometric login button at all.
  final canOffer = false.obs;
  final isAuthenticating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _evaluate();
  }

  Future<void> _evaluate() async {
    if (!BiometricPreference.isEnabled) {
      canOffer.value = false;
      return;
    }
    // A token only exists after the user logged in normally at least once.
    if (!await _tokens.hasSession()) {
      canOffer.value = false;
      return;
    }
    canOffer.value = await _biometric.isSupported();
  }

  Future<void> authenticate() async {
    if (isAuthenticating.value) return;
    isAuthenticating.value = true;
    try {
      final ok = await _biometric.authenticate(reason: AppTexts.biometricLoginReason);
      if (!ok) {
        CustomLoaders.errorSnackBar(
          title: AppTexts.biometricLoginTitle,
          message: AppTexts.biometricFailed,
        );
        return;
      }
      // Unlock the stored session: validate/refresh via the existing backend
      // flow (decide() reads /users/me + /onboarding with the stored bearer;
      // the AuthInterceptor silently refreshes on 401), then route normally.
      final route = await _router.decide();
      _router.navigateTo(route);
    } on ApiFailure {
      // Stored session is no longer valid (refresh failed) → normal login.
      CustomLoaders.errorSnackBar(
        title: AppTexts.biometricLoginTitle,
        message: AppTexts.biometricSessionExpired,
      );
    } catch (_) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.biometricLoginTitle,
        message: AppTexts.biometricFailed,
      );
    } finally {
      isAuthenticating.value = false;
    }
  }
}
