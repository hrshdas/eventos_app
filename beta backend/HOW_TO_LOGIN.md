# How to Login - Quick Guide

**Simple steps to login to EVENTOS app**

---

## Prerequisites

✅ **Backend server must be running** on `http://localhost:3000`

To start the backend:
```bash
cd "C:\eventos_app\beta backend"
npm run dev
```

You should see:
```
[INFO] Server is running on port 3000
```

---

## Method 1: Login via API (Testing)

### Step 1: Use an existing account or create one

**If you don't have an account, sign up first:**

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"Your Name\",\"email\":\"your@email.com\",\"password\":\"yourpassword\",\"role\":\"CONSUMER\"}"
```

### Step 2: Login

**Windows CMD:**
```cmd
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"your@email.com\",\"password\":\"yourpassword\"}"
```

**Windows PowerShell:**
```powershell
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d '{\"email\":\"your@email.com\",\"password\":\"yourpassword\"}'
```

### Step 3: Save the token

From the response, copy the `accessToken` - you'll need it for protected endpoints!

---

## Method 2: Login in Flutter App

### Step 1: Open the app

Run your Flutter app:
```bash
cd C:\eventos_app\  # Your Flutter app directory
flutter run
```

### Step 2: Use the login screen

1. Enter your **email** (e.g., `john@example.com`)
2. Enter your **password** (e.g., `password123`)
3. Tap **Login** button

### Step 3: The app will:

1. Call `POST http://localhost:3000/api/v1/auth/login`
2. Send your email and password
3. Receive `accessToken` and `refreshToken`
4. Store tokens securely (using `flutter_secure_storage`)
5. Navigate to the home screen

---

## Test Accounts (Quick Start)

### Consumer Account:
- **Email**: `john@example.com`
- **Password**: `password123`
- **Role**: CONSUMER

### Owner Account:
- **Email**: `jane@example.com`
- **Password**: `password123`
- **Role**: OWNER

**To create these accounts:**
```cmd
# Consumer
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"

# Owner
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}"
```

---

## Troubleshooting

### ❌ "Connection refused" or "Failed to connect"
**Problem**: Backend server is not running  
**Solution**: Start the backend with `npm run dev` in the backend directory

### ❌ "Invalid email or password"
**Problem**: Wrong credentials or user doesn't exist  
**Solution**: 
- Check email/password spelling
- Sign up first if you don't have an account

### ❌ "No token provided" (in Flutter app)
**Problem**: Token not being stored or sent correctly  
**Solution**: 
- Check `flutter_secure_storage` is working
- Verify token is being added to `Authorization: Bearer <token>` header

### ❌ CORS errors
**Problem**: Frontend URL not allowed  
**Solution**: Check `FRONTEND_URL` and `CORS_ALLOWED_ORIGINS` in backend `.env` file

---

## Login Endpoint Details

**URL**: `POST http://localhost:3000/api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "userpassword"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "User Name",
      "email": "user@example.com",
      "role": "CONSUMER"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Invalid email or password",
  "code": "UNAUTHORIZED"
}
```

---

## Next Steps After Login

1. **Save the token** in your app's secure storage
2. **Add token to headers** for all protected API calls:
   ```
   Authorization: Bearer <accessToken>
   ```
3. **Use refresh token** when access token expires (default: 15 minutes)

---

**Need help?** See `QUICK_START_GUIDE.md` for more details.

