import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';

class AuthRepository {
  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';
  static const _kUserKey = 'user_json';

  final ApiClient _api;

  AuthRepository(this._api);

  Future<void> _saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessTokenKey, accessToken);
    await prefs.setString(_kRefreshTokenKey, refreshToken);
    await prefs.setString(_kUserKey, jsonEncode(user));
    _api.setAccessToken(accessToken);
  }

  Future<bool> login({required String email, required String password}) async {
    // core ApiClient baseUrl already includes /api/v1
    final resp = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    // Expected shape: { success: true, data: { user, accessToken, refreshToken } }
    final data = resp['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid login response');
    }
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (accessToken == null || refreshToken == null || user == null) {
      throw Exception('Missing tokens or user in login response');
    }
    await _saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
    return true;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    final resp = await _api.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
      if (role != null) 'role': role,
    });
    final data = resp['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid signup response');
    }
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (accessToken == null || refreshToken == null || user == null) {
      throw Exception('Missing tokens or user in signup response');
    }
    await _saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
    return true;
  }

  Future<String> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_kRefreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Missing refresh token');
    }
    final resp = await _api.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    final data = resp['data'] as Map<String, dynamic>?;
    final newAccess = data?['accessToken'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      throw Exception('Invalid refresh response');
    }
    await prefs.setString(_kAccessTokenKey, newAccess);
    _api.setAccessToken(newAccess);
    return newAccess;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kRefreshTokenKey);
    await prefs.remove(_kUserKey);
    _api.setAccessToken(null);
  }

  Future<bool> loadSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccessTokenKey);
    if (token != null && token.isNotEmpty) {
      _api.setAccessToken(token);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_kUserKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }
}
