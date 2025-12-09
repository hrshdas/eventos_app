import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'app_api_exception.dart';
import '../auth/auth_storage.dart';

/// Central API client using Dio
/// Handles base configuration, authentication headers, and error handling
class ApiClient {
  late final Dio _dio;
  final AuthStorage _authStorage;
  String? _accessToken;
  bool _isRefreshing = false;

  /// Callback for when token refresh fails (should logout user)
  void Function()? onTokenRefreshFailed;

  ApiClient({
    AuthStorage? authStorage,
    String? customBaseUrl,
    this.onTokenRefreshFailed,
  })  : _authStorage = authStorage ?? AuthStorage(),
        _accessToken = null {
    _dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to attach Authorization header and handle token refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Normalize path to avoid double /api
          options.path = _normalizePath(options.path);

          // Get token from storage if not already loaded
          if (_accessToken == null) {
            _accessToken = await _authStorage.getAccessToken();
          }

          // Attach Authorization header if token exists
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - try to refresh token
          if (error.response?.statusCode == 401) {
            // Don't retry refresh endpoint itself
            if (error.requestOptions.path == '/auth/refresh') {
              // Refresh failed - logout user
              await _authStorage.clearTokens();
              _accessToken = null;
              onTokenRefreshFailed?.call();
              return handler.next(error);
            }

            // Try to refresh token
            final refreshed = await _refreshTokenIfNeeded();
            if (refreshed) {
              // Retry the original request with new token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed - logout user
              await _authStorage.clearTokens();
              _accessToken = null;
              onTokenRefreshFailed?.call();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // Ensure we don't double-prefix /api and we always have a single leading slash
  String _normalizePath(String path) {
    var p = path.trim();
    if (p.isEmpty) return '/';
    if (!p.startsWith('/')) p = '/$p';
    if (p.startsWith('/api/')) {
      p = p.substring(4); // remove leading '/api'
    } else if (p == '/api') {
      p = '/';
    }
    return p;
  }

  /// Set access token manually (useful after login)
  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    if (token != null && token.isNotEmpty) {
      await _authStorage.saveAccessToken(token);
    }
  }

  /// Clear access token (useful for logout)
  Future<void> clearAccessToken() async {
    _accessToken = null;
    await _authStorage.clearTokens();
  }

  /// Refresh token if needed (called automatically on 401)
  Future<bool> _refreshTokenIfNeeded() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      // Wait a bit and check again (simple approach)
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isRefreshing) {
        // Still refreshing, wait a bit more
        await Future.delayed(const Duration(milliseconds: 500));
        if (_isRefreshing) {
          return false; // Give up after waiting
        }
      }
    }

    final refreshToken = await _authStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    _isRefreshing = true;

    try {
      // Create a new Dio instance without interceptors to avoid recursion
      final refreshDio = Dio(_dio.options);
      final response = await refreshDio.post(
        _normalizePath('/auth/refresh'),
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final newAccessToken = data['accessToken'] as String? ??
              (data['data'] as Map<String, dynamic>?)?['accessToken'] as String?;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            _accessToken = newAccessToken;
            await _authStorage.saveAccessToken(newAccessToken);
            _isRefreshing = false;
            return true;
          }
        }
      }
    } catch (e) {
      // Refresh failed
      _isRefreshing = false;
      return false;
    }

    _isRefreshing = false;
    return false;
  }

  /// Manually refresh token (public method)
  Future<bool> refreshToken() async {
    return await _refreshTokenIfNeeded();
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        _normalizePath(path),
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// Parse response to Map<String, dynamic>
  Map<String, dynamic> _parseResponse(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw AppApiException.fromResponse(
        statusCode: response.statusCode ?? 0,
        message: 'Request failed with status ${response.statusCode}',
        details: response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
      );
    }

    // Handle different response formats
    if (response.data == null) {
      return {'success': true};
    }

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    if (response.data is String) {
      // Try to parse JSON string
      try {
        return {'data': response.data};
      } catch (_) {
        return {'message': response.data};
      }
    }

    // Wrap other types in a map
    return {'data': response.data};
  }

  /// POST request with multipart/form-data (for file uploads)
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> data,
    List<File>? files,
    String fileFieldName = 'images',
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      // Ensure token is loaded (interceptor will use it)
      if (_accessToken == null) {
        _accessToken = await _authStorage.getAccessToken();
      }

      // Create FormData
      final formData = FormData.fromMap(data);

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              fileFieldName,
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      // Prepare options - let interceptor handle Authorization header
      // Remove Content-Type from options if present - Dio will set it automatically for FormData
      Options? requestOptions = options;
      if (options != null && options.headers != null) {
        final headers = Map<String, dynamic>.from(options.headers!);
        headers.remove('Content-Type'); // Let Dio set this automatically
        requestOptions = options.copyWith(headers: headers);
      }

      // Use the interceptor-enabled dio instance - it will add Authorization header automatically
      final response = await _dio.post(
        _normalizePath(path),
        data: formData,
        queryParameters: queryParameters,
        options: requestOptions,
        onSendProgress: onSendProgress,
      );

      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// PATCH request with multipart/form-data (for file uploads)
  Future<Map<String, dynamic>> patchMultipart(
    String path, {
    required Map<String, dynamic> data,
    List<File>? files,
    String fileFieldName = 'images',
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      // Ensure token is loaded (interceptor will use it)
      if (_accessToken == null) {
        _accessToken = await _authStorage.getAccessToken();
      }

      // Create FormData
      final formData = FormData.fromMap(data);

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              fileFieldName,
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      // Prepare options - let interceptor handle Authorization header
      // Remove Content-Type from options if present - Dio will set it automatically for FormData
      Options? requestOptions = options;
      if (options != null && options.headers != null) {
        final headers = Map<String, dynamic>.from(options.headers!);
        headers.remove('Content-Type'); // Let Dio set this automatically
        requestOptions = options.copyWith(headers: headers, method: 'PATCH');
      } else {
        requestOptions = Options(method: 'PATCH');
      }

      // Use the interceptor-enabled dio instance - it will add Authorization header automatically
      final response = await _dio.patch(
        _normalizePath(path),
        data: formData,
        queryParameters: queryParameters,
        options: requestOptions,
        onSendProgress: onSendProgress,
      );

      return _parseResponse(response);
    } on DioException catch (e) {
      throw AppApiException.fromDioError(e);
    }
  }

  /// Get the underlying Dio instance (for advanced use cases)
  Dio get dio => _dio;
}
