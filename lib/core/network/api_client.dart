import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ulid/ulid.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/auth_interceptor.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/core/utils/log.dart';

/// Single entry point for every call against the IncaCook backend.
///
/// Responsibilities:
///   * envelope unwrapping (`{success, data, ...}` → `T`, `{success: false}`
///     → throw [ApiFailure]);
///   * attaches `Authorization: Bearer <accessToken>` and refreshes on 401
///     via [AuthInterceptor];
///   * generates an `Idempotency-Key` (ULID) when one isn't provided for
///     a create-mutating POST.
///
/// Repositories call [get], [post], [patch], [delete] with a `decoder`
/// for the `data` payload. They never see the envelope.
class ApiClient extends GetxService {
  ApiClient({Dio? dio, TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? Get.find<TokenStorage>(),
      _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      AuthInterceptor(dio: _dio, tokenStorage: _tokenStorage),
    );
    _dio.interceptors.add(
      PrettyDioLogger(
        // SECURITY: never log request/response bodies or headers — they carry
        // passwords (POST /auth/signup), bearer tokens (Authorization),
        // refresh/access tokens and OAuth codes. Method + URL + status only.
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
        compact: true,
      ),
    );
    if (_ApiResponseBodyLogger.enabled) {
      _dio.interceptors.add(const _ApiResponseBodyLogger());
    }
  }

  static ApiClient get instance => Get.find();

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;
  TokenStorage get tokenStorage => _tokenStorage;

  Future<ApiSuccess<T>> get<T>(
    String path, {
    required T Function(Object? json) decoder,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send<T>(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      decoder,
    );
  }

  Future<ApiSuccess<T>> post<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
    String? idempotencyKey,
    bool requiresIdempotencyKey = false,
  }) {
    final headers = <String, dynamic>{};
    if (requiresIdempotencyKey || idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey ?? Ulid().toString();
    }
    return _send<T>(
      () => _dio.post<dynamic>(
        path,
        data: body,
        options: Options(headers: headers.isEmpty ? null : headers),
      ),
      decoder,
    );
  }

  Future<ApiSuccess<T>> put<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
  }) {
    return _send<T>(() => _dio.put<dynamic>(path, data: body), decoder);
  }

  Future<ApiSuccess<T>> patch<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
  }) {
    return _send<T>(() => _dio.patch<dynamic>(path, data: body), decoder);
  }

  Future<ApiSuccess<T>> delete<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send<T>(
      () => _dio.delete<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      ),
      decoder,
    );
  }

  Future<ApiSuccess<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? json) decoder,
  ) async {
    try {
      final response = await request();
      return _decodeSuccess<T>(response, decoder);
    } on DioException catch (e) {
      throw _toApiFailure(e);
    }
  }

  ApiSuccess<T> _decodeSuccess<T>(
    Response<dynamic> response,
    T Function(Object? json) decoder,
  ) {
    // 204 No Content — repositories that hit this path declare T = void
    // and pass a decoder that ignores its argument.
    if (response.statusCode == 204) {
      return ApiSuccess<T>(decoder(null));
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiFailure.transport(
        message: 'Malformed response body (not a JSON object)',
        statusCode: response.statusCode ?? 0,
      );
    }

    final success = body['success'];
    if (success == false) {
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        throw ApiFailure.fromJson(error, fallbackStatus: response.statusCode);
      }
      throw ApiFailure(
        statusCode: response.statusCode ?? 0,
        code: 'INCACOOK_UNKNOWN',
        message: 'Backend reported success=false without error object',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];
    return ApiSuccess<T>(
      decoder(data),
      pagination: pagination is Map<String, dynamic>
          ? Pagination.fromJson(pagination)
          : null,
    );
  }

  ApiFailure _toApiFailure(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return ApiFailure.fromJson(error, fallbackStatus: response?.statusCode);
      }
    }
    // Connection-level failures that never reached the backend (or got no
    // response). Surface a clean, actionable French message instead of a raw
    // Dio dump like "DioExceptionType.connectionTimeout".
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return ApiFailure.transport(
          message: AppTexts.serverUnreachableError,
          code: 'INCACOOK_OFFLINE',
        );
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiFailure.transport(
          message: AppTexts.serverTimeoutError,
          code: 'INCACOOK_TIMEOUT',
        );
      default:
        return ApiFailure.transport(
          message: e.message ?? e.type.name,
          statusCode: response?.statusCode ?? 0,
        );
    }
  }
}

/// Debug-only endpoint response body logger for QA.
///
/// Enable with:
/// `--dart-define=INCACOOK_LOG_API_RESPONSES=true`
///
/// Request bodies and headers stay hidden. Response bodies are redacted and
/// truncated so auth tokens / secrets are not printed accidentally.
class _ApiResponseBodyLogger extends Interceptor {
  const _ApiResponseBodyLogger();

  static const bool enabled = bool.fromEnvironment(
    'INCACOOK_LOG_API_RESPONSES',
  );
  static const int _maxChars = int.fromEnvironment(
    'INCACOOK_LOG_API_RESPONSE_MAX_CHARS',
    defaultValue: 4000,
  );
  static const Set<String> _redactedKeys = {
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'token',
    'authorization',
    'password',
    'otp',
    'code',
    'clientSecret',
    'client_secret',
    'url',
  };

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final method = response.requestOptions.method;
    final uri = response.requestOptions.uri;
    final status = response.statusCode ?? 0;
    final body = _stringify(_redact(response.data));
    logInfo('[API][body] $method $status $uri\n$body');
    handler.next(response);
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, dynamic child) {
        final name = key.toString();
        if (_redactedKeys.contains(name)) {
          return MapEntry(name, '<redacted>');
        }
        return MapEntry(name, _redact(child));
      });
    }
    if (value is List) return value.map(_redact).toList(growable: false);
    return value;
  }

  static String _stringify(Object? value) {
    final text = const JsonEncoder.withIndent('  ').convert(value);
    if (text.length <= _maxChars) return text;
    return '${text.substring(0, _maxChars)}\n... <truncated>';
  }
}
