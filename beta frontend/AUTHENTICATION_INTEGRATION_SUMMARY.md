# Authentication Integration Summary

This document summarizes the authentication integration with the backend API.

## What Was Implemented

### 1. New AuthRepository (`lib/features/auth/data/auth_repository.dart`)

Created a new authentication repository that:
- Uses the new `ApiClient` from `lib/core/api/`
- Handles signup, login, and token refresh
- Stores tokens securely using `AuthStorage`
- Provides `isLoggedIn()` method to check authentication status
- Properly handles errors and throws `AppApiException`

**Methods:**
- `signup({name, email, password, role?})` - Register new user
- `login({email, password})` - Login with credentials
- `refreshToken()` - Refresh access token using refresh token
- `isLoggedIn()` - Check if user has valid tokens
- `logout()` - Clear all tokens

### 2. Token Refresh Interceptor (Updated `ApiClient`)

Enhanced `ApiClient` with automatic token refresh:
- Detects 401 Unauthorized responses
- Automatically attempts to refresh the access token
- Retries the original request with new token
- Handles refresh failures by clearing tokens and calling callback
- Prevents infinite refresh loops

**Key Features:**
- Automatic token refresh on 401 errors
- Single refresh attempt per request
- Callback for logout when refresh fails (`onTokenRefreshFailed`)

### 3. Updated Login Screen (`lib/screens/login_screen.dart`)

- Now uses new `AuthRepository` from `lib/features/auth/data/`
- Proper error handling with `AppApiException`
- Shows user-friendly error messages in SnackBar
- Loading state during API calls
- Navigates to `MainNavigationScreen` on success

### 4. Updated Registration Screen (`lib/screens/registration_screen.dart`)

- Now uses new `AuthRepository` from `lib/features/auth/data/`
- Proper error handling with `AppApiException`
- Shows user-friendly error messages in SnackBar
- Loading state during API calls
- Navigates to `MainNavigationScreen` on success

## Backend Endpoints Used

All endpoints use the base URL from `api_config.dart`:
- Dev: `http://localhost:3000/api/v1`
- Prod: `https://api.eventos.xyz/api/v1`

### Endpoints:

1. **POST /auth/signup**
   ```json
   Request: {
     "name": "John Doe",
     "email": "user@example.com",
     "password": "password123",
     "role": "user" // optional
   }
   
   Response: {
     "success": true,
     "data": {
       "accessToken": "...",
       "refreshToken": "..."
     }
   }
   ```

2. **POST /auth/login**
   ```json
   Request: {
     "email": "user@example.com",
     "password": "password123"
   }
   
   Response: {
     "success": true,
     "data": {
       "accessToken": "...",
       "refreshToken": "..."
     }
   }
   ```

3. **POST /auth/refresh**
   ```json
   Request: {
     "refreshToken": "..."
   }
   
   Response: {
     "success": true,
     "data": {
       "accessToken": "..."
     }
   }
   ```

## Complete Login Flow

```
1. User enters email/password → UI validates input
   ↓
2. UI calls AuthRepository.login(email, password)
   ↓
3. AuthRepository calls ApiClient.post('/auth/login', data)
   ↓
4. ApiClient makes HTTP POST to backend
   ↓
5. Backend validates credentials and returns tokens
   ↓
6. AuthRepository saves tokens to secure storage
   ↓
7. AuthRepository updates ApiClient with accessToken
   ↓
8. UI navigates to MainNavigationScreen
```

## Error Handling

### AppApiException Structure

```dart
class AppApiException {
  final String message;           // User-friendly error message
  final int? statusCode;          // HTTP status code (401, 404, 500, etc.)
  final Map<String, dynamic>? details;  // Additional error details
  final dynamic originalError;    // Original error object
}
```

### Error Handling in UI

```dart
try {
  await authRepository.login(email: email, password: password);
  // Success - navigate to home
} on AppApiException catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.message),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Token Management

### Secure Storage

Tokens are stored using `flutter_secure_storage`:
- Access token: Used for API authentication
- Refresh token: Used to get new access tokens

### Automatic Token Refresh

When an API call returns 401:
1. `ApiClient` detects the 401 error
2. Retrieves refresh token from secure storage
3. Calls `/auth/refresh` endpoint
4. Updates access token in storage
5. Retries the original request
6. If refresh fails → clears tokens → calls `onTokenRefreshFailed` callback

## Files Changed

1. ✅ `lib/core/api/api_client.dart` - Added token refresh interceptor
2. ✅ `lib/features/auth/data/auth_repository.dart` - New authentication repository
3. ✅ `lib/screens/login_screen.dart` - Updated to use new repository
4. ✅ `lib/screens/registration_screen.dart` - Updated to use new repository
5. ✅ `lib/features/auth/LOGIN_FLOW_EXAMPLE.md` - Detailed flow documentation

## Testing the Integration

### Test Login:

1. Run the Flutter app
2. Navigate to login screen
3. Enter valid credentials
4. Should navigate to home screen with bottom nav

### Test Error Handling:

1. Enter invalid credentials
2. Should show error message in SnackBar
3. Try network error (turn off internet)
4. Should show connection error message

### Test Token Refresh:

1. Login successfully
2. Wait for access token to expire (or manually expire it)
3. Make an authenticated API call
4. Should automatically refresh token and retry request

## Next Steps

- [ ] Test with actual backend
- [ ] Handle logout on token refresh failure
- [ ] Add user profile loading after login
- [ ] Implement remember me functionality
- [ ] Add biometric authentication (optional)

