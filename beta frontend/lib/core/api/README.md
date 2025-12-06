# API Layer Documentation

This folder contains the core API layer for the Flutter app using Dio.

## Files

- `api_config.dart` - Configuration for base URLs (dev/prod)
- `app_api_exception.dart` - Custom exception class for API errors
- `api_client.dart` - Main API client with Dio
- `api_usage_example.dart` - Example usage code

## Quick Start

### 1. Basic API Call Example

```dart
import 'package:eventos_app/core/api/api_client.dart';
import 'package:eventos_app/core/api/app_api_exception.dart';
import 'package:eventos_app/core/auth/auth_storage.dart';

final apiClient = ApiClient();
final authStorage = AuthStorage();

// Login example
try {
  final response = await apiClient.post(
    '/auth/login',
    data: {
      'email': 'user@example.com',
      'password': 'password123',
    },
  );

  if (response['success'] == true) {
    final data = response['data'] as Map<String, dynamic>?;
    final accessToken = data?['accessToken'] as String?;
    final refreshToken = data?['refreshToken'] as String?;
    
    if (accessToken != null && refreshToken != null) {
      await authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await apiClient.setAccessToken(accessToken);
    }
  }
} on AppApiException catch (e) {
  print('Login failed: ${e.message}');
  print('Status code: ${e.statusCode}');
}
```

### 2. Error Handling in UI (Widget Example)

```dart
import 'package:flutter/material.dart';
import 'package:eventos_app/core/api/api_client.dart';
import 'package:eventos_app/core/api/app_api_exception.dart';
import 'package:eventos_app/core/auth/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _apiClient = ApiClient();
  final _authStorage = AuthStorage();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null) {
          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;

          if (accessToken != null && refreshToken != null) {
            await _authStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            await _apiClient.setAccessToken(accessToken);

            // Navigate to home screen
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } on AppApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (_isLoading)
            CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () => _handleLogin('email', 'password'),
              child: Text('Login'),
            ),
        ],
      ),
    );
  }
}
```

### 3. Error Handling Patterns

#### Handling Specific Status Codes

```dart
try {
  final response = await apiClient.get('/users/profile');
  // Handle success
} on AppApiException catch (e) {
  if (e.statusCode == 401) {
    // Unauthorized - token expired
    // Could trigger token refresh
  } else if (e.statusCode == 404) {
    // Resource not found
  } else if (e.statusCode == 500) {
    // Server error
  } else {
    // Other errors
  }
}
```

#### Using GET, PUT, DELETE

```dart
// GET with query parameters
final response = await apiClient.get(
  '/listings',
  queryParameters: {
    'page': 1,
    'limit': 10,
  },
);

// PUT request
await apiClient.put(
  '/users/profile',
  data: {
    'name': 'John Doe',
  },
);

// DELETE request
await apiClient.delete('/users/account');
```

## Configuration

Edit `api_config.dart` to change base URLs:

```dart
const bool kIsProd = false; // Set to true for production
```

Or use Flutter flavors for environment management.

