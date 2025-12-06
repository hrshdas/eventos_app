# Physical Device Setup - Connection Fix

**Your laptop IP: `192.168.1.34`**

---

## Quick Fix: Update Flutter App Base URL

### Step 1: Find Your API Configuration File

Look for files like:
- `lib/core/api/api_client.dart`
- `lib/config/api_config.dart`
- `lib/services/api_service.dart`
- `lib/utils/constants.dart`

### Step 2: Update Base URL

**Change from:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

**To:**
```dart
static const String baseUrl = 'http://192.168.1.34:3000/api/v1';
```

**Example:**
```dart
// lib/core/api/api_client.dart
class ApiClient {
  static const String baseUrl = 'http://192.168.1.34:3000/api/v1';
  
  // Login endpoint
  static Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    // ... handle response
  }
}
```

---

## Step 3: Verify Backend is Accessible

### Test from your laptop:
```bash
curl http://192.168.1.34:3000/health
```

**Expected response:**
```json
{
  "success": true,
  "message": "Server is running",
  "database": "connected"
}
```

### Test from your phone (if possible):
Open browser on your phone and go to:
```
http://192.168.1.34:3000/health
```

You should see the JSON response.

---

## Step 4: Check Windows Firewall

Windows Firewall might be blocking port 3000.

### Allow Port 3000:

1. **Open Windows Defender Firewall:**
   - Press `Win + R`
   - Type: `wf.msc`
   - Press Enter

2. **Create Inbound Rule:**
   - Click "Inbound Rules" → "New Rule"
   - Select "Port" → Next
   - Select "TCP" → Specific local ports: `3000` → Next
   - Select "Allow the connection" → Next
   - Check all profiles (Domain, Private, Public) → Next
   - Name: "Node.js Backend Port 3000" → Finish

3. **Create Outbound Rule (same steps):**
   - Click "Outbound Rules" → "New Rule"
   - Follow same steps as above

---

## Step 5: Ensure Same Network

**Important**: Your phone and laptop must be on the **same Wi-Fi network**!

- ✅ Both connected to same Wi-Fi
- ❌ Phone on mobile data, laptop on Wi-Fi
- ❌ Different Wi-Fi networks

---

## Step 6: Restart Backend (if needed)

After updating firewall, restart backend:

```bash
cd "C:\eventos_app\beta backend"
npm run dev
```

---

## Step 7: Test Login Endpoint

### From your laptop (should work):
```bash
curl -X POST http://192.168.1.34:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

### From Flutter app:
The app should now connect to `http://192.168.1.34:3000/api/v1/auth/login`

---

## Complete Example: Flutter API Client

```dart
// lib/core/api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Use your laptop's IP address
  static const String baseUrl = 'http://192.168.1.34:3000/api/v1';
  
  // Login method
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Other API methods...
}
```

---

## Troubleshooting

### ❌ Still getting "Connection error"

1. **Check backend is running:**
   ```bash
   curl http://192.168.1.34:3000/health
   ```

2. **Check firewall:**
   - Windows Firewall might still be blocking
   - Try temporarily disabling firewall to test

3. **Check network:**
   - Ensure phone and laptop on same Wi-Fi
   - Try pinging from phone: `ping 192.168.1.34`

4. **Check backend logs:**
   - Look at backend terminal for incoming requests
   - If no requests appear, connection isn't reaching backend

5. **Try different port:**
   - If 3000 is blocked, change backend port in `.env`:
     ```
     PORT=3001
     ```
   - Update Flutter app to: `http://192.168.1.34:3001/api/v1`

### ❌ "Connection timeout"

- Check if backend is actually running
- Verify IP address is correct
- Check firewall settings

### ❌ "Connection refused"

- Backend not running
- Wrong IP address
- Port not accessible

---

## Quick Checklist

- [ ] Backend running on `http://192.168.1.34:3000`
- [ ] Flutter app base URL updated to `http://192.168.1.34:3000/api/v1`
- [ ] Windows Firewall allows port 3000
- [ ] Phone and laptop on same Wi-Fi network
- [ ] Test `http://192.168.1.34:3000/health` works from laptop
- [ ] Test `http://192.168.1.34:3000/health` works from phone browser

---

## Test Commands

### Test backend from laptop:
```bash
curl http://192.168.1.34:3000/health
```

### Test login endpoint:
```bash
curl -X POST http://192.168.1.34:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

### Test from phone browser:
Open: `http://192.168.1.34:3000/health`

---

**After making these changes, restart your Flutter app and try logging in again!**

