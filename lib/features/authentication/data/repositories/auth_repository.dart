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

  /// `POST /v1/auth/google` (§3.1a) — exchanges a Google ID token (from
  /// the `google_sign_in` plugin) for a session. Supabase auto-links to
  /// an existing email-password account if one matches the Google
  /// email, so a returning user keeps their `User` row + role.
  ///
  /// Pass [nonce] only if the call site embedded a hashed nonce in the
  /// ID token request — the plain Dart `google_sign_in` flow doesn't,
  /// so it's optional on every caller we have today.
  Future<Session> signInWithGoogle({
    required String idToken,
    String? nonce,
  }) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/google',
      body: <String, dynamic>{
        'idToken': idToken,
        'nonce': ?nonce,
      },
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );
    await _persistSession(result.data);
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

  /// `POST /v1/auth/email/request-otp` (§3.9 *Temporary email-OTP bypass*) —
  /// emails a 6-digit code to the caller's own email (resolved from the
  /// JWT, so no body is sent). Used while the SMS provider is down to
  /// satisfy the same `phoneVerified` gate as [requestPhoneOtp].
  ///
  /// Delete once SMS is restored.
  Future<void> requestEmailOtp() async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/auth/email/request-otp',
      body: null,
      decoder: (_) {},
    );
  }

  /// `POST /v1/auth/email/verify` (§3.9 *Temporary email-OTP bypass*) —
  /// confirms the email OTP and returns a fresh session. Tokens are
  /// swapped in [TokenStorage] before the new [Session] is handed back.
  /// On success `User.phoneVerified` is flipped to `true` server-side but
  /// `User.phone` stays NULL (no phone was captured).
  ///
  /// Delete once SMS is restored.
  Future<Session> verifyEmailOtp({required String code}) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/email/verify',
      body: <String, dynamic>{'code': code},
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
