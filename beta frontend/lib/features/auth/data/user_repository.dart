import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../domain/models/user.dart';

/// Repository for user profile operations
class UserRepository {
  final ApiClient _apiClient;

  UserRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Update user profile
  /// Note: Backend endpoint may need to be implemented (PUT /users/me)
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? avatar,
  }) async {
    try {
      // TODO: Backend needs to implement PUT /users/me endpoint
      // For now, we'll use PATCH /users/me if available, or return current user
      final response = await _apiClient.put(
        '/users/me',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (avatar != null) 'avatar': avatar,
        },
      );

      Map<String, dynamic>? userData;
      if (response['data'] != null) {
        userData = response['data'] as Map<String, dynamic>?;
      } else {
        userData = response;
      }

      if (userData == null) {
        throw AppApiException(
          message: 'Invalid update profile response',
          statusCode: 200,
        );
      }

      return User.fromJson(userData);
    } on AppApiException catch (e) {
      // If endpoint doesn't exist (404), throw a helpful error
      if (e.statusCode == 404) {
        throw AppApiException(
          message: 'Profile update endpoint not yet implemented on backend',
          statusCode: 404,
        );
      }
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }
}
