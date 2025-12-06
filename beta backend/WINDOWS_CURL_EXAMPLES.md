# Windows curl Examples - Quick Reference

**Windows-specific curl command examples for EVENTOS Backend API**

---

## ⚠️ Important: Windows Command Differences

- **CMD**: Use `^` for line continuation (not `\`)
- **PowerShell**: Use backtick `` ` `` for line continuation
- **JSON**: Escape quotes with `\"` in CMD, or use single quotes in PowerShell

---

## Quick Examples

### 1. Sign Up (CMD)

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"
```

### 2. Sign Up (PowerShell)

```powershell
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}'
```

### 3. Login (Single Line - All Windows)

```cmd
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

### 4. Get Profile (Replace YOUR_TOKEN)

⚠️ **CRITICAL**: You **MUST** include `Bearer ` (with space) before the token!

```cmd
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Example with actual token**:
```cmd
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5Y2E3NDllYy0yZmIzLTQzOWYtYmNmOC01MmIzYzI5MWUzN2IiLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQ09OU1VNRVIiLCJpYXQiOjE3NjQ4ODIzNzcsImV4cCI6MTc2NDg4MzI3N30.5NxBaxanOnNrCLb_43Bg4LIHzjppPEuRKHxYR8mUslw"
```

**❌ WRONG**: `-H "Authorization: YOUR_TOKEN"` (missing "Bearer ")  
**✅ CORRECT**: `-H "Authorization: Bearer YOUR_TOKEN"`

### 5. Create Listing (Replace YOUR_TOKEN and values)

```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json" -H "Authorization: Bearer YOUR_TOKEN" -d "{\"title\":\"Test Venue\",\"description\":\"Test\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"Test\"}"
```

---

## Multi-Line Examples (CMD)

### Sign Up with Line Continuation

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"
```

**Note**: In CMD, you must escape all quotes in JSON with `\"`.

---

## Multi-Line Examples (PowerShell)

### Sign Up with Line Continuation

```powershell
curl -X POST http://localhost:3000/api/v1/auth/signup `
  -H "Content-Type: application/json" `
  -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}'
```

**Note**: In PowerShell, you can use single quotes for the JSON string, but still need to escape inner quotes.

---

## Better Alternative: Use PowerShell Invoke-RestMethod

PowerShell has a built-in `Invoke-RestMethod` that's easier to use:

```powershell
$body = @{
    name = "John Doe"
    email = "john@example.com"
    password = "password123"
    role = "CONSUMER"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/signup" -Method Post -Body $body -ContentType "application/json"
```

---

## Using the Test Script (Easiest!)

Instead of manual curl commands, use the automated test script:

**PowerShell**:
```powershell
.\test-api.ps1
```

This script handles all the complexity for you!

---

## Common Issues

### Issue: "No token provided" or "UNAUTHORIZED" error
**Problem**: Missing `Bearer ` prefix in Authorization header  
**❌ WRONG**: `-H "Authorization: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
**✅ CORRECT**: `-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`

The auth middleware requires the format: `Authorization: Bearer <token>` (note the space after "Bearer")

### Issue: "Bad hostname" or "URL rejected"
**Solution**: Remove trailing backslash `\` - use `^` in CMD or `` ` `` in PowerShell

### Issue: Quotes not working
**Solution**: 
- CMD: Use `\"` for all JSON quotes
- PowerShell: Use single quotes `'...'` for the JSON string

### Issue: Command not recognized
**Solution**: Make sure `curl` is installed (comes with Windows 10+), or use PowerShell's `Invoke-RestMethod`

---

## Recommended: Use Postman

For Windows users, **Postman** is often easier than curl:
1. Download Postman
2. Create requests with GUI
3. Save collections for reuse

See `QUICK_START_GUIDE.md` Section 9 for Postman setup.

