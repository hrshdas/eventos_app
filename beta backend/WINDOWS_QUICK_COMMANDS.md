# Windows Quick Commands - Copy & Paste Ready

**Ready-to-use curl commands for Windows CMD - Just copy and paste!**

---

## ⚠️ Important Notes

- **Windows CMD**: Use `^` for line continuation (NOT `\`)
- **PowerShell**: Use backtick `` ` `` for line continuation
- **JSON Quotes**: In CMD, escape all quotes with `\"`
- **Easiest**: Use single-line commands (no line continuation needed)

---

## 1. Sign Up as Consumer

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"
```

---

## 2. Sign Up as Owner

```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}"
```

---

## 3. Login

```cmd
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

**Save the `accessToken` from the response!**

---

## 4. Get Your Profile

**Replace `YOUR_TOKEN` with your actual access token:**

```cmd
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer YOUR_TOKEN"
```

**Example with actual token:**
```cmd
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5Y2E3NDllYy0yZmIzLTQzOWYtYmNmOC01MmIzYzI5MWUzN2IiLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQ09OU1VNRVIiLCJpYXQiOjE3NjQ4ODIzNzcsImV4cCI6MTc2NDg4MzI3N30.5NxBaxanOnNrCLb_43Bg4LIHzjppPEuRKHxYR8mUslw"
```

---

## 5. Create Listing (as Owner)

⚠️ **IMPORTANT**: You **MUST** use an **OWNER** or **ADMIN** token! CONSUMER tokens will fail with `403 Forbidden`.

**Replace `OWNER_TOKEN` with your owner access token:**

```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json" -H "Authorization: Bearer OWNER_TOKEN" -d "{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue perfect for weddings and events\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\",\"images\":[\"https://example.com/venue1.jpg\"]}"
```

**Example with actual OWNER token** (from jane@example.com):
```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODI0NDcsImV4cCI6MTc2NDg4MzM0N30.avbtReD5uvnbPwCxG5MLcIPIFt6Z3YaNftl1ABKOkE0" -d "{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue perfect for weddings and events\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\",\"images\":[\"https://example.com/venue1.jpg\"]}"
```

**Common Error**: If you get `403 Forbidden: Insufficient permissions`, you're using a CONSUMER token. Sign up as OWNER first (see Step 2 above).

---

## 6. Get All Listings (Public)

```cmd
curl http://localhost:3000/api/v1/listings
```

---

## 7. Create Booking (as Consumer)

**Replace `CONSUMER_TOKEN` and `LISTING_ID`:**

```cmd
curl -X POST http://localhost:3000/api/v1/bookings -H "Content-Type: application/json" -H "Authorization: Bearer CONSUMER_TOKEN" -d "{\"listingId\":\"LISTING_ID\",\"startDate\":\"2024-06-01T10:00:00Z\",\"endDate\":\"2024-06-03T18:00:00Z\"}"
```

---

## 8. Create Payment Intent (as Consumer)

**Replace `CONSUMER_TOKEN` and `BOOKING_ID`:**

```cmd
curl -X POST http://localhost:3000/api/v1/payments/create -H "Content-Type: application/json" -H "Authorization: Bearer CONSUMER_TOKEN" -d "{\"bookingId\":\"BOOKING_ID\",\"amount\":10000,\"currency\":\"USD\"}"
```

---

## 9. AI Planner Suggestion (Public)

```cmd
curl -X POST http://localhost:3000/api/v1/ai-planner/suggest -H "Content-Type: application/json" -d "{\"eventType\":\"wedding\",\"budget\":10000,\"guests\":100,\"location\":\"outdoor\",\"date\":\"2024-06-15T19:00:00Z\",\"vibe\":\"elegant\",\"theme\":\"rustic\"}"
```

---

## Common Mistakes to Avoid

### ❌ WRONG: Using `\` in Windows CMD
```cmd
curl -X POST http://localhost:3000/api/v1/listings \
  -H "Content-Type: application/json"
```
**Error**: `'-H' is not recognized as an internal or external command`

### ✅ CORRECT: Use `^` in Windows CMD
```cmd
curl -X POST http://localhost:3000/api/v1/listings ^
  -H "Content-Type: application/json"
```

### ✅ BETTER: Use single-line (no continuation needed)
```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json"
```

---

## Even Easier: Use the Test Script!

Instead of manual commands, run the automated test script:

```powershell
.\test-api.ps1
```

This handles everything automatically!

---

## Need Help?

- See `QUICK_START_GUIDE.md` for detailed explanations
- See `WINDOWS_CURL_EXAMPLES.md` for more examples
- Check the troubleshooting section in `QUICK_START_GUIDE.md`

