import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../../../core/auth/auth_storage.dart';
import '../domain/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Repository for authentication operations
/// Handles signup, login, token refresh, and session management
class AuthRepository {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  AuthRepository({
    ApiClient? apiClient,
    AuthStorage? authStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _authStorage = authStorage ?? AuthStorage();

  /// Sign up a new user
  /// Returns User on success, throws AppApiException on failure
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (role != null) 'role': role,
        },
      );

      // Handle different response formats
      Map<String, dynamic>? data;
      if (response['data'] != null) {
        data = response['data'] as Map<String, dynamic>?;
      } else {
        data = response;
      }

      if (data == null) {
        throw AppApiException(
          message: 'Invalid signup response',
          statusCode: 200,
        );
      }

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>? ?? data;

      if (accessToken == null || refreshToken == null) {
        throw AppApiException(
          message: 'Missing tokens in signup response',
          statusCode: 200,
        );
      }

      // Save tokens securely
      await _authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Update API client with access token
      await _apiClient.setAccessToken(accessToken);

      // Parse and return user
      return User.fromJson(userData);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }

  /// Login with email and password
  /// Returns User on success, throws AppApiException on failure
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Debug: Print full response
      debugPrint('AuthRepository.login: Full response: $response');
      
      // Handle different response formats
      Map<String, dynamic>? data;
      if (response['data'] != null) {
        data = response['data'] as Map<String, dynamic>?;
        debugPrint('AuthRepository.login: Found data in response.data');
      } else {
        data = response;
        debugPrint('AuthRepository.login: Using response directly as data');
      }

      if (data == null) {
        debugPrint('AuthRepository.login: ERROR - data is null!');
        throw AppApiException(
          message: 'Invalid login response',
          statusCode: 200,
        );
      }

      debugPrint('AuthRepository.login: Extracted data: $data');
      
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>? ?? data;
      
      debugPrint('AuthRepository.login: accessToken: ${accessToken != null ? "present" : "null"}');
      debugPrint('AuthRepository.login: refreshToken: ${refreshToken != null ? "present" : "null"}');
      debugPrint('AuthRepository.login: userData: $userData');

      if (accessToken == null || refreshToken == null) {
        throw AppApiException(
          message: 'Missing tokens in login response',
          statusCode: 200,
        );
      }

      // Save tokens securely
      await _authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Update API client with access token
      await _apiClient.setAccessToken(accessToken);

      // Debug: Print user data
      debugPrint('AuthRepository.login: User data from login: $userData');
      
      // Parse and return user
      final user = User.fromJson(userData);
      debugPrint('AuthRepository.login: Parsed user: ${user.name}, email: ${user.email}, role: ${user.role}');
      return user;
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }

  /// Refresh access token using refresh token
  /// Returns new access token on success, throws AppApiException on failure
  Future<String> refreshToken() async {
    try {
      final refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AppApiException(
          message: 'No refresh token available',
          statusCode: 401,
        );
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      // Handle different response formats
      Map<String, dynamic>? data;
      if (response['data'] != null) {
        data = response['data'] as Map<String, dynamic>?;
      } else {
        data = response;
      }

      final newAccessToken = data?['accessToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw AppApiException(
          message: 'Missing access token in refresh response',
          statusCode: 200,
        );
      }

      // Save new access token
      await _authStorage.saveAccessToken(newAccessToken);
      await _apiClient.setAccessToken(newAccessToken);

      return newAccessToken;
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }

  /// Check if user is logged in based on stored tokens
  Future<bool> isLoggedIn() async {
    return await _authStorage.hasTokens();
  }

  /// Sign in with Google
  /// 1) Prompts account selection
  /// 2) Retrieves idToken
  /// 3) Exchanges idToken with backend at /auth/google for JWTs and User
  Future<User> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '215980053014-guc0aefco4ok5huggo04i6uqsju3cgnd.apps.googleusercontent.com',
      );

      // Ensure a clean state
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final account = await googleSignIn.signIn();
      if (account == null) {
        throw AppApiException(message: 'Google sign-in cancelled');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw AppApiException(message: 'Failed to retrieve Google ID token');
      }

      final response = await _apiClient.post(
        '/auth/google',
        data: { 'idToken': idToken },
      );

      // Response shape matches email login ({ data: { user, accessToken, refreshToken } })
      final Map<String, dynamic> data =
          (response['data'] as Map<String, dynamic>?) ?? response as Map<String, dynamic>;

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>? ?? data;

      if (accessToken == null || refreshToken == null) {
        throw AppApiException(message: 'Missing tokens in Google login response');
      }

      await _authStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      await _apiClient.setAccessToken(accessToken);

      return User.fromJson(userData);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }

  /// Get current user from backend
  /// Returns User if logged in and token is valid, null otherwise
  Future<User?> getCurrentUser() async {
    try {
      // Check if we have tokens
      final hasTokens = await _authStorage.hasTokens();
      if (!hasTokens) {
        return null;
      }

      // Ensure token is loaded in API client
      final accessToken = await _authStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      await _apiClient.setAccessToken(accessToken);

      // Call /users/me endpoint (backend route is /users/me, not /auth/me)
      final response = await _apiClient.get('/users/me');

      // Handle different response formats
      Map<String, dynamic>? userData;
      if (response['data'] != null) {
        userData = response['data'] as Map<String, dynamic>?;
      } else if (response['user'] != null) {
        userData = response['user'] as Map<String, dynamic>?;
      } else {
        userData = response;
      }

      if (userData == null) {
        return null;
      }

      return User.fromJson(userData);
    } on AppApiException catch (e) {
      // If 401 or 403, user is not authenticated
      if (e.statusCode == 401 || e.statusCode == 403) {
        // Clear invalid tokens
        await _authStorage.clearTokens();
        await _apiClient.clearAccessToken();
        return null;
      }
      // Re-throw other errors
      rethrow;
    } catch (e) {
      // On any error, return null (user not authenticated)
      return null;
    }
  }

  /// Logout user - clear all tokens
  Future<void> logout() async {
    await _authStorage.clearTokens();
    await _apiClient.clearAccessToken();
  }
}
