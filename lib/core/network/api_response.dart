/// Transport-level wrappers for the IncaCook backend envelope.
///
/// The backend always answers with either:
///
///   ```json
///   { "success": true,  "data": <T>, "meta": {...}, "pagination"?: {...} }
///   ```
///
/// or:
///
///   ```json
///   { "success": false, "error": { "statusCode", "code", "message",
///                                  "correlationId", "details"? } }
///   ```
///
/// [ApiClient] unwraps that envelope. Repositories only see [T] on success,
/// or a thrown [ApiFailure] on error. Don't expose [ApiSuccess] / [ApiFailure]
/// to widgets — convert to a feature-level result type in the controller.
library;

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.pagination});

  final T data;
  final Pagination? pagination;
}

/// Thrown by [ApiClient] on any non-2xx response, or on a successful
/// response whose `success` flag is false. Repositories should let it
/// propagate; controllers catch and map it to UI state.
class ApiFailure implements Exception {
  const ApiFailure({
    required this.statusCode,
    required this.code,
    required this.message,
    this.correlationId,
    this.details,
  });

  /// Builds an [ApiFailure] from a backend error envelope's `error` object.
  factory ApiFailure.fromJson(Map<String, dynamic> json, {int? fallbackStatus}) {
    return ApiFailure(
      statusCode: (json['statusCode'] as int?) ?? fallbackStatus ?? 0,
      code: (json['code'] as String?) ?? 'INCACOOK_UNKNOWN',
      message: (json['message'] as String?) ?? 'Unknown error',
      correlationId: json['correlationId'] as String?,
      details: json['details'],
    );
  }

  /// For low-level failures that never reached the backend (timeouts,
  /// no connectivity, malformed response).
  factory ApiFailure.transport({
    required String message,
    int statusCode = 0,
    String code = 'INCACOOK_TRANSPORT',
    String? correlationId,
  }) {
    return ApiFailure(
      statusCode: statusCode,
      code: code,
      message: message,
      correlationId: correlationId,
    );
  }

  final int statusCode;
  final String code;
  final String message;
  final String? correlationId;
  final dynamic details;

  @override
  String toString() =>
      'ApiFailure($statusCode, $code, $message'
      '${correlationId == null ? '' : ', corrId=$correlationId'})';
}

/// Mirrors the backend `pagination` block. Present on list responses only.
class Pagination {
  const Pagination({
    this.hasMore,
    this.total,
    this.nextCursor,
    this.page,
    this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      hasMore: json['hasMore'] as bool?,
      total: json['total'] as int?,
      nextCursor: json['nextCursor'] as String?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  final bool? hasMore;
  final int? total;
  final String? nextCursor;
  final int? page;
  final int? limit;
}
