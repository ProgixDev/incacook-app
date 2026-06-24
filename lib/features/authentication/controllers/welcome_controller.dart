import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/presentation/screens/complete_email_screen.dart';
import 'package:incacook/features/authentication/presentation/screens/facebook_email_completion_screen.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';

/// Drives the welcome/login screens' social sign-in.
///
/// Both Google and Facebook go through the **same** Supabase hosted OAuth
/// flow ([SupabaseOAuthService]) — no native Google Sign-In, no SHA-1/SHA-256,
/// no `SignInHubActivity`, and no client secret in the app. After the browser
/// callback lands a Supabase session we:
///   1. copy the tokens into TokenStorage (the backend owns refresh),
///   2. sync the identity with the backend (`POST /v1/auth/oauth/sync`),
///   3. hand off to [PostAuthRouter] — identical routing to email signin
///      (`role home` / `resume signup` / `no profile yet`), so a first-time
///      user lands at role selection and continues the same onboarding
///      (Prelude phone verification included); a returning user lands home.
///
/// Cancellation is silent. Real failures surface a French toast. Tokens are
/// never logged.
class WelcomeController extends GetxController {
  WelcomeController({
    SupabaseOAuthService? oauth,
    AuthRepository? authRepository,
    PostAuthRouter? router,
  })  : _oauth = oauth ?? Get.find<SupabaseOAuthService>(),
        _authRepository = authRepository ?? Get.find<AuthRepository>(),
        _router = router ?? Get.find<PostAuthRouter>();

  final SupabaseOAuthService _oauth;
  final AuthRepository _authRepository;
  final PostAuthRouter _router;

  /// Per-provider in-flight flags. Each button binds to its own flag for the
  /// spinner; [isAnySocialLoading] disables *both* buttons so the two
  /// providers can never run at once and no button can double-launch.
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;

  bool get isAnySocialLoading =>
      isGoogleLoading.value || isFacebookLoading.value;

  Future<void> signInWithGoogle() => _signInWith(
        provider: OAuthProvider.google,
        tag: 'Google',
        loading: isGoogleLoading,
        errorTitle: AppTexts.googleSignInTitle,
        errorMessage: AppTexts.googleSignInError,
      );

  Future<void> signInWithFacebook() => _signInWith(
        provider: OAuthProvider.facebook,
        tag: 'Facebook',
        loading: isFacebookLoading,
        errorTitle: AppTexts.facebookSignInTitle,
        errorMessage: AppTexts.facebookSignInError,
      );

  Future<void> _signInWith({
    required OAuthProvider provider,
    required String tag,
    required RxBool loading,
    required String errorTitle,
    required String errorMessage,
  }) async {
    // Guard double-launch AND simultaneous Google/Facebook auth.
    if (isAnySocialLoading) return;
    loading.value = true;
    debugPrint('[Auth][$tag] button clicked');
    try {
      debugPrint('[Auth][$tag] starting Supabase OAuth');
      final session = await _oauth.signIn(provider);
      debugPrint('[Auth][$tag] callback/session received: true');

      await _authRepository.persistOAuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: session.expiresAt ?? 0,
      );
      _logAvatarPresence(session);
      _logEmailPresence(tag, session);

      final sync = await _authRepository.syncOAuthUser();
      debugPrint('[Auth][$tag] backend sync called '
          '(profileExists=${sync.profileExists} needsEmail=${sync.needsEmail})');

      // Provider returned no email (e.g. Facebook) → collect + verify one
      // before onboarding, otherwise POST /v1/users fails with EMAIL_REQUIRED.
      if (sync.needsEmail) {
        final completed = await Get.to<bool>(() => const CompleteEmailScreen());
        if (completed != true) return; // user backed out — loading reset below
      }

      final decision = await _router.decide();
      _router.navigateTo(decision);
    } on OAuthEmailMissingException {
      // Provider returned no email AND no Supabase session was created.
      debugPrint('[Auth][$tag] callback/session received: false');
      if (provider != OAuthProvider.facebook) {
        CustomLoaders.errorSnackBar(
          title: errorTitle,
          message: AppTexts.facebookNoEmailError,
        );
        return;
      }
      // Recoverable: collect + verify an email by OTP (PUBLIC endpoints, no
      // session needed), then continue to the same destination as a normal
      // social login. Replaces the old blocking red error.
      debugPrint('[Auth][Facebook] missing email fallback opened');
      final completed =
          await Get.to<bool>(() => const FacebookEmailCompletionScreen());
      if (completed != true) return; // user cancelled → back at login
      // The repository persisted the fresh (email-verified) session; sync the
      // identity and route exactly like a normal social login.
      try {
        final sync = await _authRepository.syncOAuthUser();
        debugPrint('[Auth][Facebook] manual email login synced '
            '(profileExists=${sync.profileExists} needsEmail=${sync.needsEmail})');
        final decision = await _router.decide();
        _router.navigateTo(decision);
      } on ApiFailure catch (e) {
        CustomLoaders.errorSnackBar(title: errorTitle, message: e.message);
      } catch (_) {
        CustomLoaders.errorSnackBar(title: errorTitle, message: errorMessage);
      }
    } on OAuthSignInException {
      // Launch failure, or no callback/session within the timeout. Surface a
      // clean toast (loading is reset in the finally below).
      debugPrint('[Auth][$tag] callback/session received: false');
      CustomLoaders.errorSnackBar(title: errorTitle, message: errorMessage);
    } on ApiFailure catch (e) {
      // Backend rejected the Supabase JWT or the duplicate-email guard fired.
      // Surface the backend message verbatim (already French).
      CustomLoaders.errorSnackBar(title: errorTitle, message: e.message);
    } catch (_) {
      CustomLoaders.errorSnackBar(title: errorTitle, message: errorMessage);
    } finally {
      loading.value = false;
    }
  }

  /// Logs only *whether* the OAuth identity carried an avatar — never the URL.
  /// The Prisma User stores an internal `avatarPath` (storage object key), not
  /// an external URL, so a Google/Facebook photo is informational only: it's
  /// never forced onto the profile and a missing one can't crash signup.
  void _logAvatarPresence(Session session) {
    final meta = session.user.userMetadata;
    bool nonEmpty(Object? v) => v is String && v.isNotEmpty;
    final hasAvatar =
        meta != null && (nonEmpty(meta['avatar_url']) || nonEmpty(meta['picture']));
    debugPrint('[Auth][OAuth] avatar exists: $hasAvatar');
  }

  /// Safe, presence-only logging of where (if anywhere) the OAuth identity
  /// carried an email. Never logs the address value itself.
  void _logEmailPresence(String tag, Session session) {
    final user = session.user;
    bool has(Object? v) => v is String && v.isNotEmpty;
    final identityEmail =
        user.identities?.any((i) => has(i.identityData?['email'])) ?? false;
    debugPrint('[Auth][$tag] user.email present: ${has(user.email)}');
    debugPrint(
        '[Auth][$tag] userMetadata.email present: ${has(user.userMetadata?['email'])}');
    debugPrint('[Auth][$tag] identity email present: $identityEmail');
  }
}
