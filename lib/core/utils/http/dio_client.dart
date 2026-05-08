import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:incacook/core/constants/api_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal();

  late Dio _dio;
  final Logger _logger = Logger();

  Dio get dio {
    _initializeDio();
    return _dio;
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    //? Add Basic Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          //? Add Basic Auth header
          final credentials =
              '${ApiConstants.username}:${ApiConstants.password}';
          final encoded = base64Encode(utf8.encode(credentials));
          options.headers['Authorization'] = 'Basic $encoded';

          _logger.d('Request: ${options.method} ${options.uri}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Body: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            _logger.d('Query Parameters: ${options.queryParameters}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          _logger.d('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.type} - ${error.message}');
          if (error.response != null) {
            _logger.e(
              'Error Response: ${error.response?.statusCode} - ${error.response?.data}',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  //? GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  //? POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  //? PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  //? DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  //? Handle errors
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _logger.e('Timeout error: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        _logger.e(
          'Bad response: ${error.response?.statusCode} - ${error.response?.data}',
        );
        break;
      case DioExceptionType.cancel:
        _logger.e('Request cancelled: ${error.message}');
        break;
      case DioExceptionType.unknown:
        _logger.e('Unknown error: ${error.message}');
        break;
      default:
        _logger.e('Error: ${error.message}');
    }
  }
}
