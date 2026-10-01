/// Typed exceptions for API communication with user-friendly messages.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.details,
  });

  /// Factory creating an ApiException from HTTP status codes.
  factory ApiException.fromStatusCode(int statusCode, {String? rawDetail, String? code}) {
    switch (statusCode) {
      case 400:
        return ApiException(
          statusCode: 400,
          code: code ?? 'BAD_REQUEST',
          message: rawDetail ?? 'Invalid request. Please verify the information provided.',
        );
      case 401:
        return ApiException(
          statusCode: 401,
          code: code ?? 'UNAUTHORIZED',
          message: 'Your session has expired. Please sign in again.',
        );
      case 403:
        return ApiException(
          statusCode: 403,
          code: code ?? 'FORBIDDEN',
          message: rawDetail ?? "You don't have permission to perform this action.",
        );
      case 404:
        return ApiException(
          statusCode: 404,
          code: code ?? 'NOT_FOUND',
          message: rawDetail ?? 'The requested item could not be found.',
        );
      case 409:
        return ApiException(
          statusCode: 409,
          code: code ?? 'CONFLICT',
          message: rawDetail ?? 'This action has already been performed.',
        );
      case 422:
        return ApiException(
          statusCode: 422,
          code: code ?? 'UNPROCESSABLE_ENTITY',
          message: rawDetail ?? 'Please check the information you entered.',
        );
      case 429:
        return ApiException(
          statusCode: 429,
          code: code ?? 'RATE_LIMITED',
          message: 'Too many requests. Please wait a moment and try again.',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          statusCode: statusCode,
          code: code ?? 'SERVER_ERROR',
          message: 'Server is temporarily unavailable. Please try again shortly.',
        );
      default:
        return ApiException(
          statusCode: statusCode,
          code: code ?? 'UNKNOWN_ERROR',
          message: rawDetail ?? 'An unexpected error occurred ($statusCode).',
        );
    }
  }

  /// Factory creating network/offline exception.
  factory ApiException.networkError([String? customMessage]) {
    return ApiException(
      statusCode: 0,
      code: 'NETWORK_ERROR',
      message: customMessage ?? "You're offline. Check your internet connection and try again.",
    );
  }

  /// Factory creating timeout exception.
  factory ApiException.timeout() {
    return const ApiException(
      statusCode: 408,
      code: 'TIMEOUT',
      message: 'The request took too long to complete. Please try again.',
    );
  }

  @override
  String toString() => message;
}
