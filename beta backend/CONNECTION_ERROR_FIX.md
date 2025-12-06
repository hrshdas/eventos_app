# Fix Connection Error - "Check Your Connection"

**Troubleshooting guide for connection errors when logging in**

---

## Quick Checklist

✅ **Backend server is running** on `http://localhost:3000`  
✅ **Flutter app is using correct API URL**  
✅ **CORS is configured** in backend  
✅ **Network permissions** are set in Flutter app  

---

## Step 1: Verify Backend is Running

### Check if backend is running:

**Open a new terminal and run:**
```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "success": true,
  "message": "Server is running",
  "database": "connected"
}
```

### If backend is NOT running:

**Start it:**
```bash
cd "C:\eventos_app\beta backend"
npm run dev
```

You should see:
```
[INFO] Server is running on port 3000
[INFO] Environment: development
```

---

## Step 2: Check Flutter App API URL

### For Android Emulator:
- Use: `http://10.0.2.2:3000` (Android emulator's special IP for localhost)
- **NOT** `http://localhost:3000` (won't work on Android emulator)

### For iOS Simulator:
- Use: `http://localhost:3000` (works on iOS simulator)

### For Physical Device:
- Use: `http://YOUR_COMPUTER_IP:3000` (e.g., `http://192.168.1.100:3000`)
- Find your IP: 
  - Windows: `ipconfig` (look for IPv4 Address)
  - Mac/Linux: `ifconfig` or `ip addr`

### For Web (Flutter Web):
- Use: `http://localhost:3000` (if running on same machine)

---

## Step 3: Update Flutter App Base URL

**Find your API configuration file** (usually in `lib/core/api/` or `lib/config/`):

**Example:**
```dart
// lib/core/api/api_client.dart or similar
class ApiClient {
  // For Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  
  // For iOS Simulator:
  // static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // For Physical Device:
  // static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
}
```

**Update the base URL based on your platform!**

---

## Step 4: Check CORS Configuration

**Verify backend CORS allows your Flutter app:**

**File**: `src/config/env.ts` or `.env`

Make sure these are set:
```env
FRONTEND_URL=http://localhost:8080
CORS_ALLOWED_ORIGINS=http://localhost:8080,http://localhost:5173
```

**For mobile apps**, CORS might not be the issue, but check `src/app.ts`:

```typescript
// Should allow requests with no origin (mobile apps)
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) {
        return callback(null, true);
      }
      // ... rest of config
    }
  })
);
```

---

## Step 5: Check Network Permissions (Android)

**File**: `android/app/src/main/AndroidManifest.xml`

**Make sure you have internet permission:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        android:usesCleartextTraffic="true"  <!-- IMPORTANT for http:// -->
        ...>
    </application>
</manifest>
```

**Note**: `usesCleartextTraffic="true"` is required for `http://` connections (not `https://`).

---

## Step 6: Test API Connection Manually

### Test from Flutter app directory:

**Create a test file** `test_connection.dart`:
```dart
import 'package:http/http.dart' as http;

void main() async {
  // Try different URLs based on your platform
  final urls = [
    'http://localhost:3000/health',
    'http://10.0.2.2:3000/health',  // Android emulator
    'http://192.168.1.100:3000/health',  // Replace with your IP
  ];
  
  for (var url in urls) {
    try {
      final response = await http.get(Uri.parse(url));
      print('✅ $url: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ $url: $e');
    }
  }
}
```

**Run it:**
```bash
dart test_connection.dart
```

This will tell you which URL works!

---

## Step 7: Common Issues & Solutions

### Issue: "Connection refused"
**Cause**: Backend not running  
**Fix**: Start backend with `npm run dev`

### Issue: "Network is unreachable"
**Cause**: Wrong IP address or URL  
**Fix**: Use correct URL for your platform (see Step 2)

### Issue: "CORS error" (Web only)
**Cause**: CORS not configured  
**Fix**: Update `CORS_ALLOWED_ORIGINS` in backend `.env`

### Issue: "Cleartext HTTP not permitted" (Android)
**Cause**: Missing `usesCleartextTraffic`  
**Fix**: Add to `AndroidManifest.xml` (see Step 5)

### Issue: "Timeout"
**Cause**: Firewall blocking or wrong port  
**Fix**: 
- Check Windows Firewall allows port 3000
- Verify backend is on port 3000
- Try `http://127.0.0.1:3000` instead of `localhost`

---

## Quick Fix Commands

### 1. Restart Backend:
```bash
cd "C:\eventos_app\beta backend"
npm run dev
```

### 2. Check Backend Health:
```bash
curl http://localhost:3000/health
```

### 3. Test Login Endpoint:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

### 4. Find Your Computer's IP (for physical device):
```bash
# Windows
ipconfig

# Look for "IPv4 Address" under your network adapter
```

---

## Platform-Specific URLs

| Platform | Base URL |
|----------|----------|
| **Android Emulator** | `http://10.0.2.2:3000` |
| **iOS Simulator** | `http://localhost:3000` |
| **Physical Device** | `http://YOUR_IP:3000` |
| **Flutter Web** | `http://localhost:3000` |

**Replace `YOUR_IP` with your computer's local IP address!**

---

## Still Not Working?

1. **Check backend logs** - Are requests reaching the server?
2. **Check Flutter console** - What's the exact error message?
3. **Try Postman/curl** - Does the API work from there?
4. **Check firewall** - Is Windows Firewall blocking port 3000?

**Share the exact error message and I can help more!**

