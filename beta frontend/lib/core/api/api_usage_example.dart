// Example usage of ApiClient
// This file demonstrates how to use the API client and handle errors

import 'api_client.dart';
import 'app_api_exception.dart';
import '../auth/auth_storage.dart';

/// Example: Login API call
Future<void> exampleLogin() async {
  final apiClient = ApiClient();
  final authStorage = AuthStorage();

  try {
    // Make login request
    final response = await apiClient.post(
      '/auth/login',
      data: {
        'email': 'user@example.com',
        'password': 'password123',
      },
    );

    // Handle successful response
    // Expected response format: { "success": true, "data": { "user": {...}, "accessToken": "...", "refreshToken": "..." } }
    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;

        if (accessToken != null && refreshToken != null) {
          // Save tokens securely
          await authStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );

          // Update API client with access token
          await apiClient.setAccessToken(accessToken);

          print('Login successful!');
        }
      }
    }
  } on AppApiException catch (e) {
    // Handle API errors
    print('Login failed: ${e.message}');
    print('Status code: ${e.statusCode}');
    if (e.details != null) {
      print('Error details: ${e.details}');
    }

    // Handle specific error cases
    if (e.statusCode == 401) {
      print('Invalid credentials');
    } else if (e.statusCode == 404) {
      print('Endpoint not found');
    } else if (e.statusCode == 500) {
      print('Server error');
    }
  } catch (e) {
    // Handle unexpected errors
    print('Unexpected error: $e');
  }
}

/// Example: GET request with authentication
Future<void> exampleGetUserProfile() async {
  final apiClient = ApiClient();

  try {
    // The API client automatically attaches the Authorization header
    // if a token is stored in AuthStorage
    final response = await apiClient.get('/users/profile');

    // Handle response
    if (response['success'] == true) {
      final user = response['data'];
      print('User profile: $user');
    }
  } on AppApiException catch (e) {
    if (e.statusCode == 401) {
      print('Unauthorized - token may be expired');
      // Could trigger token refresh here
    } else {
      print('Failed to get profile: ${e.message}');
    }
  }
}

/// Example: Error handling in UI (Flutter widget)
///
/// In your UI code, you would use it like this:
/// 
/// ```dart
/// class LoginScreen extends StatefulWidget {
///   @override
///   _LoginScreenState createState() => _LoginScreenState();
/// }
/// 
/// class _LoginScreenState extends State<LoginScreen> {
///   final _apiClient = ApiClient();
///   final _authStorage = AuthStorage();
///   bool _isLoading = false;
///   String? _errorMessage;
/// 
///   Future<void> _handleLogin(String email, String password) async {
///     setState(() {
///       _isLoading = true;
///       _errorMessage = null;
///     });
/// 
///     try {
///       final response = await _apiClient.post(
///         '/auth/login',
///         data: {
///           'email': email,
///           'password': password,
///         },
///       );
/// 
///       if (response['success'] == true) {
///         final data = response['data'] as Map<String, dynamic>?;
///         if (data != null) {
///           final accessToken = data['accessToken'] as String?;
///           final refreshToken = data['refreshToken'] as String?;
/// 
///           if (accessToken != null && refreshToken != null) {
///             await _authStorage.saveTokens(
///               accessToken: accessToken,
///               refreshToken: refreshToken,
///             );
///             await _apiClient.setAccessToken(accessToken);
/// 
///             // Navigate to home screen
///             Navigator.pushReplacementNamed(context, '/home');
///           }
///         }
///       }
///     } on AppApiException catch (e) {
///       setState(() {
///         _errorMessage = e.message;
///       });
/// 
///       // Show error snackbar or dialog
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(
///           content: Text(e.message),
///           backgroundColor: Colors.red,
///         ),
///       );
///     } catch (e) {
///       setState(() {
///         _errorMessage = 'An unexpected error occurred';
///       });
///     } finally {
///       setState(() {
///         _isLoading = false;
///       });
///     }
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Column(
///         children: [
///           if (_errorMessage != null)
///             Text(
///               _errorMessage!,
///               style: TextStyle(color: Colors.red),
///             ),
///           if (_isLoading)
///             CircularProgressIndicator()
///           else
///             ElevatedButton(
///               onPressed: () => _handleLogin('email', 'password'),
///               child: Text('Login'),
///             ),
///         ],
///       ),
///     );
///   }
/// }
/// ```

/// Example: PUT request
Future<void> exampleUpdateProfile() async {
  final apiClient = ApiClient();

  try {
    final response = await apiClient.put(
      '/users/profile',
      data: {
        'name': 'John Doe',
        'phone': '+1234567890',
      },
    );

    if (response['success'] == true) {
      print('Profile updated successfully');
    }
  } on AppApiException catch (e) {
    print('Update failed: ${e.message}');
  }
}

/// Example: DELETE request
Future<void> exampleDeleteAccount() async {
  final apiClient = ApiClient();

  try {
    final response = await apiClient.delete('/users/account');
    
    if (response['success'] == true) {
      // Clear tokens after account deletion
      await apiClient.clearAccessToken();
      print('Account deleted successfully');
    }
  } on AppApiException catch (e) {
    print('Delete failed: ${e.message}');
  }
}

/// Example: GET request with query parameters
Future<void> exampleGetListings() async {
  final apiClient = ApiClient();

  try {
    final response = await apiClient.get(
      '/listings',
      queryParameters: {
        'page': 1,
        'limit': 10,
        'category': 'venue',
      },
    );

    if (response['success'] == true) {
      final listings = response['data'] as List?;
      print('Found ${listings?.length ?? 0} listings');
    }
  } on AppApiException catch (e) {
    print('Failed to fetch listings: ${e.message}');
  }
}

