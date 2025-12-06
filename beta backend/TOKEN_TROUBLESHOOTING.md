# Token Troubleshooting Guide

**Common issues with JWT tokens and how to fix them**

---

## Issue: "Invalid or expired token"

### Possible Causes:

1. **Token got corrupted during copy-paste** (most common)
   - Extra spaces, line breaks, or missing characters
   - Solution: Get a fresh token

2. **Token expired**
   - Access tokens expire after 15 minutes (default)
   - Solution: Login again to get a new token

3. **Token signature mismatch**
   - Token was modified or corrupted
   - Solution: Get a fresh token

---

## Quick Fix: Get a Fresh OWNER Token

### Step 1: Sign Up as OWNER (if you haven't already)

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}"
```

### Step 2: Login to Get Fresh Token

```cmd
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"jane@example.com\",\"password\":\"password123\"}"
```

**Copy the `accessToken` from the response** - it will look like:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI...,...}
```

### Step 3: Use the Fresh Token

Replace `YOUR_FRESH_TOKEN` in your command:

```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json" -H "Authorization: Bearer YOUR_FRESH_TOKEN" -d "{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\"}"
```

---

## How to Avoid Token Corruption

### ✅ DO:
- Copy the entire token in one go (select all, copy)
- Use single-line commands when possible
- Verify the token has no spaces or line breaks

### ❌ DON'T:
- Copy tokens across multiple lines
- Add spaces or line breaks in the token
- Modify the token manually

---

## Verify Your Token is Valid

### Check Token Format:
A valid JWT has **3 parts** separated by dots (`.`):
```
header.payload.signature
```

Example:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODI0NDcsImV4cCI6MTc2NDg4MzM0N30.avbtReD5uvnbPwCxG5MLcIPIFt6Z3YaNftl1ABKOkE0
```

**Count the dots**: Should be exactly **2 dots**

### Decode Token (Optional - for debugging)

You can decode the token at [jwt.io](https://jwt.io) to check:
- `role`: Should be `"OWNER"` or `"ADMIN"` for listing creation
- `exp`: Expiration timestamp (check if expired)

---

## Common Token Errors

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `"Invalid or expired token"` | Token corrupted or expired | Get fresh token via login |
| `"No token provided"` | Missing `Bearer ` prefix | Use `Authorization: Bearer TOKEN` |
| `"Forbidden: Insufficient permissions"` | Wrong role (e.g., CONSUMER trying to create listing) | Use OWNER/ADMIN token |

---

## Quick Test: Verify Token Works

Test your token with a simple endpoint:

```cmd
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer YOUR_TOKEN"
```

If this works, your token is valid. If it fails, get a fresh token.

---

## Still Having Issues?

1. **Check server is running**: `curl http://localhost:3000/health`
2. **Verify token format**: Should have 2 dots, no spaces
3. **Check token expiration**: Login again if token is old
4. **Use single-line commands**: Avoids copy-paste issues

