import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:incacook/core/config/supabase_config.dart';
import 'package:incacook/core/utils/log.dart';
import 'package:incacook/features/authentication/services/oauth_session_snapshot.dart';

/// Hosted social sign-in via Supabase OAuth — currently used for Facebook.
/// Google uses [NativeGoogleAuthService] instead so users stay in the native
/// Google account chooser instead of the hosted Supabase browser redirect.
///
/// Flow:
///   1. [signIn] opens an external browser at Supabase's authorize URL (PKCE).
///   2. The user authenticates; Supabase redirects to
///      `incacook://auth/callback` (registered in both native projects).
///   3. supabase_flutter's deep-link observer catches the redirect, exchanges
///      the PKCE code for a session, and fires `onAuthStateChange`.
///   4. We surface the resulting [Session]; the caller copies the tokens into
///      [TokenStorage] (the backend owns refresh from then on).
///
/// Cancellation (backing out of the browser) can't be observed directly with
/// an external-browser OAuth, so if no session arrives within
/// [_redirectTimeout] we surface a clean [OAuthSignInException] and release
/// the button spinner instead of hanging.
class SupabaseOAuthService extends GetxService {
  SupabaseOAuthService({GoTrueClient? auth}) : _authOverride = auth;

  static SupabaseOAuthService get instance => Get.find();

  // Injectable for tests; otherwise resolved lazily so construction never
  // touches Supabase.instance before main()'s initialize() has run.
  final GoTrueClient? _authOverride;
  GoTrueClient get _auth => _authOverride ?? Supabase.instance.client.auth;

  /// Debug timeout for the OAuth round-trip. If the deep-link callback hasn't
  /// fired within this window the flow is treated as failed (clean error +
  /// spinner released) instead of hanging — the usual cause is a provider /
  /// dashboard misconfig (redirect_uri_mismatch, the Facebook app still in
  /// Development mode, or `incacook://auth/callback` missing from Supabase's
  /// Redirect URLs). Kept short for debugging; raise it for production if real
  /// logins routinely take longer than this.
  static const Duration _redirectTimeout = Duration(minutes: 5);

  /// The Supabase session cached by a callback that completed while the app
  /// was backgrounded or being relaunched. Bootstrap copies this into
  /// IncaCook's TokenStorage through [OAuthSessionRecovery].
  OAuthSessionSnapshot? get currentSessionSnapshot {
    if (!SupabaseConfig.isConfigured) return null;
    final session = _auth.currentSession;
    if (session == null) return null;
    return OAuthSessionSnapshot(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: session.expiresAt ?? 0,
    );
  }

  /// Launches [provider]'s OAuth browser and resolves with the Supabase
  /// [Session] once the redirect lands. Throws [OAuthSignInException] on a
  /// launch/provider failure OR when no callback/session arrives within
  /// [_redirectTimeout] (abandoned or misconfigured). Never logs tokens.
  Future<Session> signIn(OAuthProvider provider) async {
    final completer = Completer<Session>();
    // Only accept SIGNED_IN events that arrive *after* we launch the browser.
    // onAuthStateChange replays the latest state to new listeners, so without
    // this gate a previously-persisted session could resolve the completer
    // before the new OAuth even starts.
    var launched = false;

    final sub = _auth.onAuthStateChange.listen(
      (state) {
        if (!launched) return;
        if (state.event == AuthChangeEvent.signedIn && state.session != null) {
          if (!completer.isCompleted) completer.complete(state.session);
        }
      },
      onError: (Object e) {
        // Supabase routes OAuth callback errors here (getSessionFromUrl →
        // notifyException → addError), e.g. Facebook returning no email. Gate
        // on `launched` so a replayed error from a previous attempt can't fail
        // this one before it starts. Map the missing-email case specifically.
        if (!launched || completer.isCompleted) return;
        completer.completeError(_authStreamError(e));
      },
    );

    // Also watch the raw callback deep link for an `error=...` — it usually
    // arrives slightly before Supabase finishes getSessionFromUrl, so this
    // fails fast with the specific message and the safe logs below. (A global
    // permanent onAuthStateChange listener in main() absorbs the matching
    // Supabase error so it can never go unhandled if our per-sign-in listener
    // has already been cancelled.) Never logs the auth code / tokens.
    final linkSub = AppLinks().uriLinkStream.listen((uri) {
      if (!launched || !_isAuthCallback(uri)) return;
      final error = uri.queryParameters['error'];
      if (error == null) return; // success → handled by onAuthStateChange
      final description = uri.queryParameters['error_description'];
      logError('[DeepLink] received auth callback: true');
      logError('[Auth][OAuth] callback error: $error');
      logError(
        '[Auth][OAuth] callback error_description exists: ${description != null}',
      );
      logError(
        '[Auth][OAuth] provider=${provider.name} session received: false',
      );
      if (!completer.isCompleted) {
        completer.completeError(_callbackError(description));
      }
    });

    // Provider-specific params that push the IdP to ask which account to use
    // instead of silently reusing the browser session (see [_accountSelectionParams]).
    final queryParams = _accountSelectionParams(provider);
    // Safe: provider + the flag only — never tokens. e.g.
    // "[Auth][OAuth] provider=google prompt=select_account".
    final paramsDesc = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join(' ');
    logError('[Auth][OAuth] provider=${provider.name} $paramsDesc');

    // Explicitly request the email scope (Facebook returns no email without it
    // → "Error getting user email from external provider"). Safe log — scopes
    // are not secrets. e.g. "[Auth][OAuth] provider=facebook scopes=email public_profile".
    final scopes = _scopesFor(provider);
    logInfo(
      '[Auth][OAuth] provider=${provider.name} scopes=${scopes ?? 'default'}',
    );

    try {
      bool opened;
      try {
        opened = await _auth.signInWithOAuth(
          provider,
          redirectTo: SupabaseConfig.oauthRedirectUrl,
          // Google returns email by default; Facebook needs it explicitly.
          scopes: scopes,
          // Both providers must run in the external browser on Android;
          // in-app webviews are blocked by Google/Facebook.
          authScreenLaunchMode: LaunchMode.externalApplication,
          queryParams: queryParams,
        );
      } on Object catch (e) {
        // Wrap any plugin/provider error (never the token) so the UI can
        // show the generic "réessayer" message.
        throw OAuthSignInException(e.toString());
      }
      logError(
        '[Auth][OAuth] provider=${provider.name} signInWithOAuth returned: $opened',
      );
      if (!opened) {
        throw const OAuthSignInException(
          "Impossible d'ouvrir la page de connexion.",
        );
      }
      launched = true;

      logWarning(
        '[Auth][OAuth] provider=${provider.name} waiting for callback',
      );
      final Session session;
      try {
        session = await completer.future.timeout(_redirectTimeout);
      } on TimeoutException {
        // No deep-link callback within the window — almost always a provider /
        // dashboard misconfig (see [_redirectTimeout]). Surface a clean error;
        // the caller resets the button spinner in its finally.
        logError('[Auth][OAuth] provider=${provider.name} timeout');
        logError(
          '[Auth][OAuth] provider=${provider.name} session received: false',
        );
        throw const OAuthSignInException(
          'Aucune réponse de connexion. Veuillez réessayer.',
        );
      }
      logWarning(
        '[Auth][OAuth] provider=${provider.name} session received: true',
      );
      return session;
    } finally {
      await sub.cancel();
      await linkSub.cancel();
    }
  }

  /// Per-provider OAuth query params (forwarded by Supabase onto the IdP's
  /// authorize URL) that ask the provider to let the user pick an account
  /// rather than silently reusing the one already signed in to the browser.
  ///
  /// - **Facebook** has **no** Google-style account-list popup.
  ///   `auth_type=reauthenticate` asks Facebook to re-prompt for credentials
  ///   where it can, but if the browser already holds a logged-in Facebook
  ///   session Facebook may still reuse it. To switch accounts the user has to
  ///   log out of Facebook in the browser (or pick another account on
  ///   Facebook's own page if it offers one).
  static Map<String, String> _accountSelectionParams(OAuthProvider provider) {
    if (provider == OAuthProvider.facebook) {
      return const {'auth_type': 'rerequest', 'return_scopes': 'true'};
    }
    return const {};
  }

  /// OAuth scopes per provider. Facebook must explicitly request `email`
  /// (and `public_profile`) or it returns no email and Supabase fails with
  /// "Error getting user email from external provider".
  static String? _scopesFor(OAuthProvider provider) {
    if (provider == OAuthProvider.facebook) return 'email public_profile';
    return null;
  }

  /// True for our own `incacook://auth/callback` redirect (ignore any other
  /// deep links the app might receive).
  static bool _isAuthCallback(Uri uri) =>
      uri.scheme == 'incacook' && uri.host == 'auth' && uri.path == '/callback';

  /// Maps an OAuth error callback to a user-facing exception. A missing email
  /// (the common Facebook case) gets its own type so the UI can show specific
  /// guidance; everything else is a generic provider failure.
  static Exception _callbackError(String? errorDescription) {
    if (errorDescription != null &&
        errorDescription.toLowerCase().contains('email')) {
      return const OAuthEmailMissingException();
    }
    return const OAuthSignInException('Connexion impossible.');
  }

  /// Maps an error pushed onto the `onAuthStateChange` stream (Supabase's
  /// [AuthException] for a failed callback) to a user-facing exception. Reads
  /// the message text only — never tokens.
  static Exception _authStreamError(Object error) {
    final message = error is AuthException ? error.message : error.toString();
    if (message.toLowerCase().contains('email')) {
      return const OAuthEmailMissingException();
    }
    return const OAuthSignInException('Connexion impossible.');
  }

  /// Clears Supabase's locally-cached session **without** revoking it
  /// server-side (the backend bearer in [TokenStorage] is the live session
  /// and is revoked separately via `/v1/auth/signout`). Called from
  /// [SignOutService] so a subsequent social login starts clean.
  Future<void> signOut() async {
    try {
      await _auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // Best-effort — there may be no Supabase session to clear (e.g. an
      // email/password user). Never block the logout flow.
    }
  }
}

/// Provider/launch-level failure (browser couldn't open, redirect rejected,
/// provider misconfigured) **or** no callback/session within the timeout.
/// Surfaces a clean toast at the UI layer.
class OAuthSignInException implements Exception {
  const OAuthSignInException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The provider authenticated but returned no email (typically a Facebook
/// account with no confirmed email, or the email permission not granted).
/// The UI shows specific guidance for this case.
class OAuthEmailMissingException implements Exception {
  const OAuthEmailMissingException();

  @override
  String toString() => 'OAuthEmailMissingException';
}
