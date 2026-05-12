import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/session.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/auth_interceptor.dart';
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

  /// `POST /v1/auth/password/reset-request` — triggers a recovery email.
  Future<void> requestPasswordReset(PasswordResetRequest req) async {
    await _api.dio.post<dynamic>(
      '${ApiConstants.apiPrefix}/auth/password/reset-request',
      data: req.toJson(),
      options: Options(extra: AuthInterceptor.skipAuth()),
    );
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

  /// `POST /v1/auth/phone/verify` (§3.9) — confirms the OTP and returns
  /// a fresh session. Tokens are swapped in [TokenStorage] before the
  /// new [Session] is handed back.
  Future<Session> verifyPhoneOtp(VerifyOtpRequest req) async {
    final result = await _api.post<Session>(
      '${ApiConstants.apiPrefix}/auth/phone/verify',
      body: req.toJson(),
      decoder: (json) => Session.fromJson(json! as Map<String, dynamic>),
    );
    await _persistSession(result.data);
    return result.data;
  }

  Future<void> _persistSession(Session s) {
    return _api.tokenStorage.writeTokens(
      accessToken: s.accessToken,
      refreshToken: s.refreshToken,
      expiresAt: s.expiresAt,
    );
  }
}
