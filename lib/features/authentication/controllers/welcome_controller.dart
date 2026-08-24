import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/native_apple_auth_service.dart';
import 'package:incacook/core/services/native_google_auth_service.dart';
import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/presentation/screens/complete_email_screen.dart';
import 'package:incacook/features/authentication/services/post_auth_router.dart';
import 'package:incacook/core/utils/log.dart';

/// Drives the welcome/login screens' social sign-in.
///
/// Google uses native Google Sign-In, then exchanges the Google tokens for a
/// Supabase session. Facebook still uses the Supabase hosted OAuth flow
/// ([SupabaseOAuthService]). After either path lands a Supabase session we:
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
    NativeGoogleAuthService? googleAuth,
    NativeAppleAuthService? appleAuth,
    AuthRepository? authRepository,
    PostAuthRouter? router,
  }) : _oauth = oauth ?? Get.find<SupabaseOAuthService>(),
       _googleAuth = googleAuth ?? Get.find<NativeGoogleAuthService>(),
       _appleAuth = appleAuth ??
           (Get.isRegistered<NativeAppleAuthService>()
               ? Get.find<NativeAppleAuthService>()
               : Get.put(NativeAppleAuthService(), permanent: true)),
       _authRepository = authRepository ?? Get.find<AuthRepository>(),
       _router = router ?? Get.find<PostAuthRouter>();

  final SupabaseOAuthService _oauth;
  final NativeGoogleAuthService _googleAuth;
  final NativeAppleAuthService _appleAuth;
  final AuthRepository _authRepository;
  final PostAuthRouter _router;

  /// Per-provider in-flight flags. Each button binds to its own flag for the
  /// spinner; [isAnySocialLoading] disables *all* buttons so no two
  /// providers can run at once and no button can double-launch.
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;
  final isAppleLoading = false.obs;

  bool get isAnySocialLoading =>
      isGoogleLoading.value || isFacebookLoading.value || isAppleLoading.value;

  Future<void> signInWithGoogle() => _signInWithNativeGoogle();

  Future<void> signInWithApple() => _signInWithNativeApple();

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
    logInfo('[Auth][$tag] button clicked');
    try {
      logInfo('[Auth][$tag] starting Supabase OAuth');
      final session = await _oauth.signIn(provider);
      logInfo('[Auth][$tag] callback/session received: true');

      await _completeSocialSignIn(tag: tag, session: session);
    } on OAuthEmailMissingException {
      // With Facebook email-optional enabled in Supabase, a no-email account
      // still produces a session and follows sync.needsEmail below. If the
      // hosted project is not configured that way, there is no provider
      // identity to preserve; never create a separate email-only account and
      // mislabel it as Facebook recovery.
      logError('[Auth][$tag] callback/session received: false');
      CustomLoaders.errorSnackBar(
        title: errorTitle,
        message: AppTexts.facebookNoEmailError,
      );
    } on OAuthSignInException {
      // Launch failure, or no callback/session within the timeout. Surface a
      // clean toast (loading is reset in the finally below).
      logError('[Auth][$tag] callback/session received: false');
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

  Future<void> _signInWithNativeGoogle() async {
    if (isAnySocialLoading) return;
    isGoogleLoading.value = true;
    const tag = 'Google';
    logInfo('[Auth][$tag] button clicked');
    try {
      logInfo('[Auth][$tag] starting native Google Sign-In');
      final session = await _googleAuth.signIn();
      if (session == null) return;
      logInfo('[Auth][$tag] native session received: true');

      await _completeSocialSignIn(tag: tag, session: session);
    } on OAuthSignInException {
      logError('[Auth][$tag] native session received: false');
      CustomLoaders.errorSnackBar(
        title: AppTexts.googleSignInTitle,
        message: AppTexts.googleSignInError,
      );
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.googleSignInTitle,
        message: e.message,
      );
    } catch (_) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.googleSignInTitle,
        message: AppTexts.googleSignInError,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> _signInWithNativeApple() async {
    if (isAnySocialLoading) return;
    isAppleLoading.value = true;
    const tag = 'Apple';
    logInfo('[Auth][$tag] button clicked');
    try {
      logInfo('[Auth][$tag] starting native Sign in with Apple');
      final result = await _appleAuth.signIn();
      if (result == null) return;
      logInfo('[Auth][$tag] native session received: true');

      await _completeSocialSignIn(
        tag: tag,
        session: result.session,
        // Apple sends given/family name ONLY on the very first
        // authorization — persist it now, it's unrecoverable afterwards.
        overrideFirstName: result.firstName,
        overrideLastName: result.lastName,
      );
    } on OAuthSignInException {
      logError('[Auth][$tag] native session received: false');
      CustomLoaders.errorSnackBar(
        title: AppTexts.appleSignInTitle,
        message: AppTexts.appleSignInError,
      );
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.appleSignInTitle,
        message: e.message,
      );
    } catch (_) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.appleSignInTitle,
        message: AppTexts.appleSignInError,
      );
    } finally {
      isAppleLoading.value = false;
    }
  }

  Future<void> _completeSocialSignIn({
    required String tag,
    required Session session,
    String? overrideFirstName,
    String? overrideLastName,
  }) async {
    await _authRepository.persistOAuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: session.expiresAt ?? 0,
    );
    // Apple's identity token carries no name claim — persistOAuthSession's
    // JWT-claim decode leaves authFirstName/authLastName null for it. Apply
    // the name from the (first-authorization-only) Apple credential after,
    // so it isn't lost for the rest of onboarding.
    if ((overrideFirstName != null || overrideLastName != null) &&
        Get.isRegistered<UserController>()) {
      UserController.instance.setAuthName(
        firstName: overrideFirstName,
        lastName: overrideLastName,
      );
    }
    _logAvatarPresence(session);
    _logEmailPresence(tag, session);

    final sync = await _authRepository.syncOAuthUser();
    logWarning(
      '[Auth][$tag] backend sync called '
      '(profileExists=${sync.profileExists} needsEmail=${sync.needsEmail})',
    );

    // Provider returned no email (e.g. Facebook) → collect + verify one before
    // onboarding, otherwise POST /v1/users fails with EMAIL_REQUIRED.
    if (sync.needsEmail) {
      final completed = await Get.to<bool>(() => const CompleteEmailScreen());
      if (completed != true) return;
    }

    final decision = await _router.decide();
    _router.navigateTo(decision);
  }

  /// Logs only *whether* the OAuth identity carried an avatar — never the URL.
  /// The Prisma User stores an internal `avatarPath` (storage object key), not
  /// an external URL, so a Google/Facebook photo is informational only: it's
  /// never forced onto the profile and a missing one can't crash signup.
  void _logAvatarPresence(Session session) {
    final meta = session.user.userMetadata;
    bool nonEmpty(Object? v) => v is String && v.isNotEmpty;
    final hasAvatar =
        meta != null &&
        (nonEmpty(meta['avatar_url']) || nonEmpty(meta['picture']));
    logInfo('[Auth][OAuth] avatar exists: $hasAvatar');
  }

  /// Safe, presence-only logging of where (if anywhere) the OAuth identity
  /// carried an email. Never logs the address value itself.
  void _logEmailPresence(String tag, Session session) {
    final user = session.user;
    bool has(Object? v) => v is String && v.isNotEmpty;
    final identityEmail =
        user.identities?.any((i) => has(i.identityData?['email'])) ?? false;
    logInfo('[Auth][$tag] user.email present: ${has(user.email)}');
    logInfo(
      '[Auth][$tag] userMetadata.email present: ${has(user.userMetadata?['email'])}',
    );
    logInfo('[Auth][$tag] identity email present: $identityEmail');
  }
}
