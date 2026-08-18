import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/presentation/screens/welcome.dart';
import 'package:incacook/features/authentication/presentation/screens/complete_email_screen.dart';
import 'package:incacook/features/authentication/services/oauth_session_recovery.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';
import 'package:incacook/features/onboarding/presentation/screens/onboarding.dart';

/// Decides what the user sees on cold start.
///
/// Branches:
///   1. First launch (no `isFirstTime` flag yet) → onboarding carousel.
///   2. No stored session → welcome screen.
///   3. Stored session, bearer still valid → defer to [PostAuthRouter]
///      (role home, resumed signup, or no-profile signup restart).
///   4. Stored session, bearer rejected → tokens cleared, welcome.
///
/// Routing rules live in [PostAuthRouter] so cold-start and live signin
/// stay in sync.
class BootstrapController extends GetxController {
  static BootstrapController get instance => Get.find();

  BootstrapController({
    TokenStorage? tokenStorage,
    PostAuthRouter? router,
    OAuthSessionRecovery? oauthRecovery,
    GetStorage? storage,
  }) : _tokenStorage = tokenStorage ?? Get.find<TokenStorage>(),
       _router = router ?? Get.find<PostAuthRouter>(),
       _oauthRecovery = oauthRecovery ?? Get.find<OAuthSessionRecovery>(),
       _storage = storage ?? GetStorage();

  final TokenStorage _tokenStorage;
  final PostAuthRouter _router;
  final OAuthSessionRecovery _oauthRecovery;
  final GetStorage _storage;

  @override
  void onReady() {
    super.onReady();
    // onReady fires after the first frame, so Get's navigator is ready
    // for offAll(). onInit would fire too early.
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    if (_storage.read<bool>('isFirstTime') != false) {
      Get.offAll<void>(() => const OnBoardingScreen());
      return;
    }

    final hasSession = await _tokenStorage.hasSession();
    if (!hasSession) {
      try {
        final recovered = await _oauthRecovery.recover();
        if (recovered == null) {
          Get.offAll<void>(() => const WelcomeScreen());
          return;
        }
        if (recovered.needsEmail) {
          final completed = await Get.to<bool>(
            () => const CompleteEmailScreen(),
          );
          if (completed != true) {
            Get.offAll<void>(() => const WelcomeScreen());
            return;
          }
        }
      } on ApiFailure catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) {
          await _tokenStorage.clear();
        }
        Get.offAll<void>(() => const WelcomeScreen());
        return;
      } catch (_) {
        Get.offAll<void>(() => const WelcomeScreen());
        return;
      }
    }

    // Rehydrate the in-memory auth email from storage before any screen
    // can read it. Without this, the OTP page on the NoProfile path
    // falls back to the wizard's debug seed after a hot restart.
    if (Get.isRegistered<UserController>()) {
      await UserController.instance.hydrateFromStorage();
    }

    try {
      final decision = await _router.decide();
      _router.navigateTo(decision);
    } on ApiFailure catch (e) {
      // 401/403 means the refresh flow already cleared tokens (see
      // AuthInterceptor). On any other ApiFailure (5xx, transport),
      // we still fall through to welcome — the user can retry signin
      // from there, which will surface the error properly.
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _tokenStorage.clear();
      }
      Get.offAll<void>(() => const WelcomeScreen());
    }
  }
}
