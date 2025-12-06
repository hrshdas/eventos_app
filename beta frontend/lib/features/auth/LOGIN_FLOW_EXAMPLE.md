# Login Flow Example

This document shows the complete login flow from UI → AuthRepository → ApiClient → Backend.

## Complete Login Flow

### 1. UI Layer (Login Screen)

```dart
// lib/screens/login_screen.dart

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  final AuthRepository _authRepo = AuthRepository();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Step 1: Call AuthRepository.login()
      await _authRepo.login(email: email, password: password);

      // Step 6: On success, navigate to main app
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(initialIndex: 0),
        ),
      );
    } on AppApiException catch (e) {
      // Step 6b: Handle API errors (4xx/5xx)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFE53E3E),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Step 6c: Handle unexpected errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
```

### 2. Repository Layer (AuthRepository)

```dart
// lib/features/auth/data/auth_repository.dart

class AuthRepository {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Step 2: Call ApiClient.post() with endpoint and data
      final response = await _apiClient.post(
        '/auth/login',  // Path: /auth/login (baseUrl already includes /api/v1)
        data: {
          'email': email,
          'password': password,
        },
      );

      // Step 5: Parse response and extract tokens
      Map<String, dynamic>? data;
      if (response['data'] != null) {
        data = response['data'] as Map<String, dynamic>?;
      } else {
        data = response;
      }

      final accessToken = data?['accessToken'] as String?;
      final refreshToken = data?['refreshToken'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw AppApiException(
          message: 'Missing tokens in login response',
          statusCode: 200,
        );
      }

      // Step 5b: Save tokens securely
      await _authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Step 5c: Update API client with access token
      await _apiClient.setAccessToken(accessToken);

      return true;
    } on AppApiException {
      rethrow;  // Let UI handle AppApiException
    } catch (e) {
      throw AppApiException(
        message: e.toString(),
        originalError: e,
      );
    }
  }
}
```

### 3. API Client Layer (ApiClient)

```dart
// lib/core/api/api_client.dart

class ApiClient {
  late final Dio _dio;
  final AuthStorage _authStorage;
  String? _accessToken;

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Step 3: Dio interceptor automatically adds Authorization header if token exists
      // Step 3b: Make HTTP POST request to backend
      // Full URL: http://localhost:3000/api/v1/auth/login
      final response = await _dio.post(
        path,  // '/auth/login'
        data: data,  // { email: '...', password: '...' }
        queryParameters: queryParameters,
        options: options,
      );

      // Step 4: Parse and return response
      return _parseResponse(response);
    } on DioException catch (e) {
      // Step 4b: Convert DioException to AppApiException
      throw AppApiException.fromDioError(e);
    }
  }
}
```

### 4. Backend Request/Response

**Request:**
```
POST http://localhost:3000/api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "123",
      "name": "John Doe",
      "email": "user@example.com"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (Error - 401):**
```json
{
  "success": false,
  "message": "Invalid email or password",
  "error": "Invalid credentials"
}
```

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. UI: User taps "Sign in" button                           │
│    - Validates input                                         │
│    - Sets loading state                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. AuthRepository.login(email, password)                    │
│    - Prepares request data                                   │
│    - Calls ApiClient.post('/auth/login', data)              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. ApiClient.post()                                         │
│    - Interceptor adds headers (if needed)                   │
│    - Makes HTTP POST to backend                             │
│    - Full URL: baseUrl + '/auth/login'                      │
│      = http://localhost:3000/api/v1/auth/login              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Backend processes request                                 │
│    - Validates credentials                                   │
│    - Returns JSON response with tokens                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. ApiClient parses response                                 │
│    - Converts to Map<String, dynamic>                       │
│    - Returns to AuthRepository                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. AuthRepository processes response                        │
│    - Extracts accessToken and refreshToken                  │
│    - Saves tokens to secure storage                          │
│    - Updates ApiClient with accessToken                      │
│    - Returns success to UI                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. UI handles result                                         │
│    - On success: Navigate to MainNavigationScreen            │
│    - On error: Show SnackBar with error message              │
│    - Clear loading state                                     │
└─────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

### Case 1: Invalid Credentials (401)

```
1. Backend returns 401 with error message
   ↓
2. ApiClient throws DioException
   ↓
3. AppApiException.fromDioError() wraps it
   ↓
4. AuthRepository rethrows AppApiException
   ↓
5. UI catches AppApiException
   ↓
6. Shows SnackBar: "Invalid email or password"
```

### Case 2: Network Error

```
1. Network timeout/connection error
   ↓
2. DioException (connectionTimeout, etc.)
   ↓
3. AppApiException.fromDioError() converts to user-friendly message
   ↓
4. UI shows: "Request timeout. Please check your connection."
```

### Case 3: Server Error (500)

```
1. Backend returns 500
   ↓
2. AppApiException with statusCode: 500
   ↓
3. UI shows: Server error message from backend
```

## Token Refresh Flow

When a protected API call returns 401:

```
1. ApiClient interceptor detects 401
   ↓
2. Checks if refreshToken exists
   ↓
3. Calls POST /auth/refresh with refreshToken
   ↓
4. Backend returns new accessToken
   ↓
5. ApiClient updates accessToken
   ↓
6. Retries original request with new token
   ↓
7. If refresh fails → Clear tokens → Call onTokenRefreshFailed callback
```

## Example: Making Authenticated API Calls

After login, all subsequent API calls automatically include the Authorization header:

```dart
final apiClient = ApiClient();

// This call automatically includes:
// Authorization: Bearer <accessToken>
final response = await apiClient.get('/users/profile');

// If token expires (401):
// 1. ApiClient automatically refreshes token
// 2. Retries the request
// 3. Returns response transparently
```

