import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/session.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/auth_interceptor.dart';
import 'package:incacook/core/network/jwt_utils.dart';
import 'package:incacook/features/authentication/data/models/requests/password_reset_request.dart';
import 'package:incacook/features/authentication/data/models/requests/password_update_request.dart';
import 'package:incacook/features/authentication/data/models/requests/request_otp_request.dart';
import 'package:incacook/features/authentication/data/models/requests/signin_request.dart';
import 'package:incacook/features/authentication/data/models/requests/signup_request.dart';
import 'package:incacook/features/authentication/data/models/requests/verify_otp_request.dart';

/// Result of `POST /v1/auth/oauth/sync`. Drives post-OAuth routing:
/// `needsEmail` → show the "complete email" step before onboarding.
class OAuthSyncResult {
  const OAuthSyncResult({
    required this.profileExists,
    required this.needsEmail,
    this.email,
  });

  final bool profileExists;
  final bool needsEmail;
  final String? email;

  factory OAuthSyncResult.fromJson(Map<String, dynamic> json) {
    return OAuthSyncResult(
      profileExists: json['profileExists'] as bool? ?? false,
      needsEmail: json['needsEmail'] as bool? ?? false,
      email: json['email'] as String?,
    );
  }
}

/// Repository for everything under `/v1/auth/*`.
///
/// All session-creating methods (signup, signin) **also** persist the
/// returned tokens via [TokenStorage] before returning — callers can
/// assume the next request will carry the right bearer.
///
/// Throws [ApiFailure] on any non-2xx; callers branch on `code`.
class AuthRepository extends GetxService {
  AuthRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static AuthRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/auth/signup` — creates the auth account.
  ///
  /// Tokens are persisted before the returned [Session] is handed back.
  /// The IncaCook profile row is **not** created here; call
  /// `UsersRepository.completeProfile` afterwards.
  Future<Session> signup(SignupRequest req) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/signup',
      body: req.toJson(),
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );
    await _persistSession(result.data);
    return result.data;
  }

  /// `POST /v1/auth/signin` — exchanges email+password for a session.
  Future<Session> signin(SigninRequest req) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/signin',
      body: req.toJson(),
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );
    await _persistSession(result.data);
    return result.data;
  }

  /// Persists a Supabase session obtained **client-side** by the social OAuth
  /// handshake (Google or Facebook via supabase_flutter), so the rest of the
  /// app sees it the same way it sees a backend-issued [Session].
  ///
  /// The hosted OAuth flow hands us raw tokens (no backend [Session]
  /// envelope), so we mirror [_persistSession]'s behaviour — decode the access
  /// token's `user_metadata` for name claims, hydrate [UserController], and
  /// write the tokens to [TokenStorage]. From here the backend's
  /// `/v1/auth/refresh` owns the lifecycle, identical to email login.
  ///
  /// Never logs the tokens.
  Future<void> persistOAuthSession({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    final claims = decodeJwtPayload(accessToken);
    final email = claims?.email;
    final firstName = claims?.givenName ?? _firstOf(claims?.fullName);
    final lastName = claims?.familyName ?? _restOf(claims?.fullName);

    if (Get.isRegistered<UserController>()) {
      final users = UserController.instance;
      if (email != null) users.setAuthEmail(email);
      users.setAuthName(firstName: firstName, lastName: lastName);
    }
    await _api.tokenStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// `POST /v1/auth/oauth/sync` — provider-agnostic post-OAuth identity sync
  /// (Google / Facebook via Supabase). The Supabase JWT (already persisted as
  /// the bearer by [persistOAuthSession]) is validated server-side; the backend
  /// returns the existing IncaCook profile or signals "no profile yet", and
  /// rejects a duplicate email with a 409.
  ///
  /// Returns whether a profile exists and whether the OAuth identity needs an
  /// email collected (`needsEmail` — e.g. Facebook returned none). A non-2xx
  /// (e.g. duplicate-email 409) surfaces as [ApiFailure] for the caller to
  /// toast. Never logs tokens.
  Future<OAuthSyncResult> syncOAuthUser() async {
    final result = await _api.post<OAuthSyncResult>(
      '${ApiConstants.apiPrefix}/auth/oauth/sync',
      body: null,
      decoder: (json) => OAuthSyncResult.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `POST /v1/auth/signout` — revokes the refresh token for this device.
  ///
  /// Always clears local tokens, even if the backend call fails (would
  /// only fail if the token was already invalid).
  Future<void> signout() async {
    try {
      await _api.post<void>(
        '${ApiConstants.apiPrefix}/auth/signout',
        body: null,
        decoder: (_) {},
      );
    } finally {
      await _api.tokenStorage.clear();
    }
  }

  /// `POST /v1/auth/password/reset-request` — emails the account a 6-digit
  /// recovery code (Supabase recovery template, `{{ .Token }}`). The
  /// response is intentionally generic so it never reveals whether the
  /// email is registered.
  Future<void> requestPasswordReset(PasswordResetRequest req) async {
    await _api.dio.post<dynamic>(
      '${ApiConstants.apiPrefix}/auth/password/reset-request',
      data: req.toJson(),
      options: Options(extra: AuthInterceptor.skipAuth()),
    );
  }

  /// `POST /v1/auth/password/verify-reset-otp` — confirms the 6-digit reset
  /// code and returns a short-lived recovery [Session]. The tokens are
  /// persisted so the immediately-following [updatePassword] call carries
  /// the recovery bearer. A wrong/expired code throws [ApiFailure] (400).
  Future<Session> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/password/verify-reset-otp',
      body: <String, dynamic>{'email': email, 'code': code},
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );
    await _persistSession(result.data);
    return result.data;
  }

  /// `POST /v1/auth/password/update` — authenticated.
  ///
  /// Used both for the in-app "change password" flow and the deep-link
  /// recovery flow. For recovery, callers must have written the recovery
  /// access token via [TokenStorage.writeTokens] before calling this.
  Future<void> updatePassword(PasswordUpdateRequest req) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/password/update',
      body: req.toJson(),
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/phone/request-otp` (§3.8) — attaches a phone number
  /// to the bearer's account and triggers SMS OTP. In local dev with
  /// `[auth.sms.test_otp]` configured, the seeded numbers all accept
  /// code `123456`.
  Future<void> requestPhoneOtp(RequestOtpRequest req) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/phone/request-otp',
      body: req.toJson(),
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/phone/verify` (§3.9) — confirms the OTP via Prelude. No new
  /// session is issued (the caller is already authenticated), so the current
  /// tokens stay; we just await the 200 (`{ phoneVerified, phone }`).
  Future<void> verifyPhoneOtp(VerifyOtpRequest req) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/phone/verify',
      body: req.toJson(),
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/email/attach` — attaches an (unconfirmed) email to the
  /// current OAuth user via the backend admin, so the app can then send a
  /// Supabase magic link itself (client-side `signInWithOtp`, keeping the PKCE
  /// verifier in the app). Throws [ApiFailure] (e.g. 409 if the email is taken).
  Future<void> attachEmail(String email) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/email/attach',
      body: <String, dynamic>{'email': email},
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/email/request-otp` — emails a 6-digit code.
  ///
  /// Two uses:
  ///   * email-OTP phone-verification bypass: no [email] (resolved from JWT);
  ///   * OAuth "complete email" (Facebook returned none): pass the [email] the
  ///     user entered — the backend attaches it to the account, then sends the
  ///     code so verifying binds the address to this user.
  Future<void> requestEmailOtp({String? email}) async {
    final normalizedEmail = email?.trim();

    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/email/request-otp',
      body: <String, dynamic>{
        if (normalizedEmail != null && normalizedEmail.isNotEmpty)
          'email': normalizedEmail,
      },
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/email/verify` — confirms the email OTP and returns a fresh
  /// session (tokens swapped in [TokenStorage]). Pass the same [email] used for
  /// the add-email request; omit it for the JWT-email bypass.
  Future<Session> verifyEmailOtp({
    required String code,
    String? email,
  }) async {
    final normalizedEmail = email?.trim();

    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/email/verify',
      body: <String, dynamic>{
        'code': code.trim(),
        if (normalizedEmail != null && normalizedEmail.isNotEmpty)
          'email': normalizedEmail,
      },
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );

    await _persistSession(result.data);
    return result.data;
  }

  Future<void> _persistSession(Session s) async {
    // Decode the access token's `user_metadata` for OAuth name claims
    // (Google → `given_name` / `family_name`). Stays null for email-
    // password signups. Used by the signup wizard's NoProfile path to
    // pre-fill Gate 2's body; without this, a first-time Google user
    // reaches role selection with empty firstName/lastName and POST
    // `/v1/users` returns 400.
    final claims = decodeJwtPayload(s.accessToken);
    final firstName = claims?.givenName ?? _firstOf(claims?.fullName);
    final lastName = claims?.familyName ?? _restOf(claims?.fullName);

    // Mirror the auth identity into the global cache. Useful for
    // screens that need it *before* Gate 2 lands a User row — most
    // notably the OTP step's "we sent a code to …" copy and the
    // wizard's role-selection POST.
    if (Get.isRegistered<UserController>()) {
      UserController.instance
        ..setAuthEmail(s.user.email)
        ..setAuthName(firstName: firstName, lastName: lastName);
    }
    // Persist alongside the tokens so the same values survive hot
    // restart — paired lifetime with the bearer.
    await _api.tokenStorage.writeTokens(
      accessToken: s.accessToken,
      refreshToken: s.refreshToken,
      expiresAt: s.expiresAt,
      email: s.user.email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Splits a `full_name` claim ("Arselene Doe") into its first word.
  /// Used as a fallback when the provider only emits `name`, not
  /// `given_name` / `family_name`.
  static String? _firstOf(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  /// Mirror of [_firstOf] — everything after the first word.
  static String? _restOf(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return null;
    return parts.sublist(1).join(' ');
  }
}
