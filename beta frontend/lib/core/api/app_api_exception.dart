import 'package:dio/dio.dart';

// Custom API exception class for handling API errors
class AppApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final dynamic originalError;

  AppApiException({
    required this.message,
    this.statusCode,
    this.details,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'AppApiException: $message (Status: $statusCode)';
    }
    return 'AppApiException: $message';
  }

  // Factory constructor for creating from Dio error
  factory AppApiException.fromDioError(dynamic error) {
    if (error is AppApiException) {
      return error;
    }

    String message = 'An unexpected error occurred';
    int? statusCode;
    Map<String, dynamic>? details;

    try {
      // Handle DioException
      if (error is DioException) {
        final response = error.response;
        if (response != null) {
          statusCode = response.statusCode;
          final data = response.data;
          
          if (data is Map<String, dynamic>) {
            // Try to extract error message from common response formats
            message = data['message'] as String? ??
                data['error'] as String? ??
                data['errorMessage'] as String? ??
                'Request failed with status $statusCode';
            details = data;
          } else if (data is String) {
            message = data;
          } else {
            message = 'Request failed with status $statusCode';
          }
        } else {
          // Network or connection error
          switch (error.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              message = 'Request timeout. Please check your connection.';
              break;
            case DioExceptionType.connectionError:
              message = 'Connection error. Please check your internet connection.';
              break;
            case DioExceptionType.badCertificate:
              message = 'SSL certificate error. Please check your connection.';
              break;
            case DioExceptionType.cancel:
              message = 'Request was cancelled.';
              break;
            default:
              message = error.message ?? 'Network error occurred';
          }
        }
      } else if (error is AppApiException) {
        return error;
      }
    } catch (_) {
      // If parsing fails, use a generic message
      message = error.toString();
    }

    return AppApiException(
      message: message,
      statusCode: statusCode,
      details: details,
      originalError: error,
    );
  }

  // Factory constructor for creating from status code and message
  factory AppApiException.fromResponse({
    required int statusCode,
    required String message,
    Map<String, dynamic>? details,
  }) {
    return AppApiException(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }
}

