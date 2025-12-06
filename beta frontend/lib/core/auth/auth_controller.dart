import 'package:flutter/material.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/models/user.dart';
import '../../core/api/app_api_exception.dart';

/// Controller for managing authentication state across the app
/// Handles app startup authentication check and user state
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  bool _isLoading = true;
  bool _isInitialized = false;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  /// Current authenticated user (null if not logged in)
  User? get currentUser => _currentUser;

  /// Whether authentication check is in progress
  bool get isLoading => _isLoading;

  /// Whether auth has been initialized (startup check completed)
  bool get isInitialized => _isInitialized;

  /// Whether user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initialize authentication state (call on app startup)
  /// Checks stored tokens and fetches current user if logged in
  Future<void> initializeAuth() async {
    if (_isInitialized) {
      debugPrint('AuthController: Already initialized, skipping');
      return;
    }

    debugPrint('AuthController: Starting initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user has stored tokens
      final hasTokens = await _authRepository.isLoggedIn();
      debugPrint('AuthController: Has tokens: $hasTokens');
      
      if (hasTokens) {
        // Try to get current user from backend
        // This will validate the token and return user if valid
        try {
          final user = await _authRepository.getCurrentUser();
          if (user != null) {
            debugPrint('AuthController: User authenticated: ${user.email}');
            _currentUser = user;
          } else {
            // Token exists but is invalid - clear it
            debugPrint('AuthController: Token invalid, clearing tokens');
            _currentUser = null;
            await _authRepository.logout();
          }
        } on AppApiException catch (e) {
          // Token is invalid (401/403) - clear it
          debugPrint('AuthController: Auth error (${e.statusCode}): ${e.message}');
          _currentUser = null;
          await _authRepository.logout();
        } catch (e) {
          // Other error - assume not logged in
          debugPrint('AuthController: Error fetching user: $e');
          _currentUser = null;
          await _authRepository.logout();
        }
      } else {
        debugPrint('AuthController: No tokens found, user not logged in');
        _currentUser = null;
      }
    } catch (e) {
      // On error, assume not logged in and clear any invalid tokens
      debugPrint('AuthController: Initialization error: $e');
      _currentUser = null;
      try {
        await _authRepository.logout();
      } catch (_) {
        // Ignore logout errors
      }
    } finally {
      _isLoading = false;
      _isInitialized = true;
      debugPrint('AuthController: Initialization complete. isLoggedIn: ${isLoggedIn}');
      notifyListeners();
    }
  }

  /// Set current user (called after successful login/signup)
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Clear user (called on logout)
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// Refresh current user data from backend
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      // If refresh fails, user might be logged out
      if (_currentUser != null) {
        _currentUser = null;
        notifyListeners();
      }
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }
}

