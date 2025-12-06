# Rate Limit Issue - Quick Fix

## Problem

You're seeing this error:
```json
{
  "success": false,
  "error": "Too many authentication attempts, please try again later.",
  "code": "AUTH_RATE_LIMIT_EXCEEDED"
}
```

## Why This Happens

The rate limiter is working correctly - it's protecting against brute force attacks. However, during development/testing, you might hit the limit quickly.

## Solutions

### Solution 1: Wait (Easiest)

The rate limit resets after **15 minutes**. Just wait and try again.

### Solution 2: Restart Server (Development)

The rate limiter uses in-memory storage. Restarting the server resets it:

```bash
# Stop server (Ctrl+C)
# Start again
npm run dev
```

### Solution 3: Use Different Endpoint

Try the legacy endpoint (may have different rate limit):

```bash
# Instead of /api/v1/auth/signup
curl -X POST http://localhost:3000/api/auth/signup ...
```

### Solution 4: Adjust Rate Limits for Development

The rate limiter has been updated to be more lenient in development:
- **Development**: 50 requests per 15 minutes
- **Production**: 5 requests per 15 minutes

If you still hit the limit, restart the server (Solution 2).

### Solution 5: Temporarily Disable (Development Only)

**⚠️ Only for development - never do this in production!**

Edit `src/app.ts` and comment out the rate limiter:

```typescript
// Before
app.use('/api/v1/auth', authRateLimiter, authRoutes);

// After (temporary)
app.use('/api/v1/auth', authRoutes);
```

**Remember to restore it before production!**

---

## Current Rate Limits

| Endpoint Type | Development | Production |
|--------------|------------|------------|
| Auth endpoints | 50/15min | 5/15min |
| Payment endpoints | 10/15min | 10/15min |
| General API | 100/15min | 100/15min |

---

## Verify Rate Limit is Reset

Check the response headers:
```bash
curl -I http://localhost:3000/api/v1/auth/signup
```

Look for:
- `RateLimit-Remaining`: Number of requests left
- `RateLimit-Reset`: When the limit resets (Unix timestamp)

---

**Status**: Rate limiter updated to be more development-friendly (50 requests vs 5).

