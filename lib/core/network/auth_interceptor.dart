import 'dart:async';

import 'package:dio/dio.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';

/// dio interceptor for the IncaCook backend.
///
///   * On request: attach `Authorization: Bearer <access>` if we have one,
///     unless the request opts out via `extra['authRequired'] = false`.
///   * On 401: try a single refresh, replay the original request once,
///     and queue any concurrent 401s behind the same refresh
///     ("single-flight").
///   * If the refresh itself fails, clear tokens and bubble up.
///
/// The "navigate to signin" reaction is intentionally NOT handled here —
/// that's a UI concern. We surface it by clearing tokens and letting the
/// caller catch [ApiFailure] with code [IncaCookErrorCodes.unauthorized].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Completer<String?>? _refreshCompleter;

  static const String _retriedKey = 'incacook.retried';
  static const String _authRequiredKey = 'incacook.authRequired';

  /// Mark a [RequestOptions] (or `Options.extra`) so the interceptor skips
  /// attaching the bearer token (used for /auth/signin, /auth/signup,
  /// /auth/refresh, /auth/password/reset-request).
  static Map<String, dynamic> skipAuth() => const {_authRequiredKey: false};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authRequired = options.extra[_authRequiredKey] != false;
    if (authRequired) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final retried = err.requestOptions.extra[_retriedKey] == true;
    final isRefreshCall =
        err.requestOptions.path.endsWith('/auth/refresh');

    if (status != 401 || retried || isRefreshCall) {
      return handler.next(err);
    }

    try {
      final newAccess = await _refreshOnce();
      if (newAccess == null) return handler.next(err);

      // Replay the original request with the fresh token.
      err.requestOptions.extra[_retriedKey] = true;
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(retryResponse);
    } on ApiFailure catch (_) {
      await _tokenStorage.clear();
      return handler.next(err);
    } catch (_) {
      await _tokenStorage.clear();
      return handler.next(err);
    }
  }

  /// Single-flight refresh: concurrent 401s await the same future.
  Future<String?> _refreshOnce() {
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    _doRefresh()
      .then(completer.complete)
      .catchError(completer.completeError)
      .whenComplete(() {
        if (identical(_refreshCompleter, completer)) {
          _refreshCompleter = null;
        }
      });

    return completer.future;
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    // Use a bare Dio so we don't recurse through this interceptor.
    final bare = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final response = await bare.post<dynamic>(
      '${ApiConstants.apiPrefix}/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final body = response.data;
    if (body is! Map<String, dynamic> || body['success'] != true) {
      return null;
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;

    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    final expiresAt = data['expiresAt'];
    if (access == null || refresh == null) return null;

    await _tokenStorage.writeTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt is int ? expiresAt : 0,
    );
    return access;
  }
}

/// Convenience extension for repositories that need to opt a single call
/// out of the bearer-attach step (the auth endpoints).
extension AuthInterceptorOptions on Options {
  Options skipAuth() => copyWith(extra: AuthInterceptor.skipAuth());
}
