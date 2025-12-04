# Testing Guide

## Prerequisites

Before testing, ensure:
1. PostgreSQL is installed and running
2. Database is created and migrations are run
3. `.env` file is configured correctly
4. Dependencies are installed: `npm install`

## Step 1: Start the Server

```bash
npm run dev
```

You should see:
```
[INFO] Database connected successfully
[INFO] Server is running on port 3000
[INFO] Environment: development
[INFO] Health check: http://localhost:3000/health
```

## Step 2: Test Health Check

Open a new terminal and run:

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-..."
}
```

## Step 3: Complete Testing Flow

### 3.1 Sign Up as OWNER

```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Owner",
    "email": "owner@example.com",
    "password": "password123",
    "role": "OWNER"
  }'
```

**Save the `accessToken` and `refreshToken` from the response!**

Expected response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "name": "John Owner",
      "email": "owner@example.com",
      "role": "OWNER"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

### 3.2 Sign Up as CONSUMER

```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Consumer",
    "email": "consumer@example.com",
    "password": "password123",
    "role": "CONSUMER"
  }'
```

**Save the consumer's `accessToken`!**

### 3.3 Login (Alternative)

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "owner@example.com",
    "password": "password123"
  }'
```

### 3.4 Get Current User Profile

```bash
curl -X GET http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3.5 Create a Listing (as OWNER)

Replace `YOUR_ACCESS_TOKEN` with the owner's token:

```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "Beautiful Wedding Venue",
    "description": "A stunning venue perfect for weddings and events",
    "category": "venue",
    "pricePerDay": 5000,
    "location": "New York, NY",
    "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
  }'
```

**Save the `id` from the response!**

### 3.6 Get All Listings (Public)

```bash
curl http://localhost:3000/api/listings
```

With filters:
```bash
curl "http://localhost:3000/api/listings?category=venue&location=New%20York&page=1&limit=10"
```

### 3.7 Get Single Listing (Public)

```bash
curl http://localhost:3000/api/listings/LISTING_ID
```

### 3.8 Create a Booking (as CONSUMER)

Replace `CONSUMER_TOKEN` and `LISTING_ID`:

```bash
curl -X POST http://localhost:3000/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CONSUMER_TOKEN" \
  -d '{
    "listingId": "LISTING_ID",
    "startDate": "2024-06-01T10:00:00Z",
    "endDate": "2024-06-03T18:00:00Z"
  }'
```

**Save the booking `id`!**

### 3.9 Get My Bookings (as CONSUMER)

```bash
curl http://localhost:3000/api/bookings/me \
  -H "Authorization: Bearer CONSUMER_TOKEN"
```

### 3.10 Get Owner's Bookings

```bash
curl http://localhost:3000/api/bookings/owner \
  -H "Authorization: Bearer OWNER_TOKEN"
```

### 3.11 Initiate Payment

```bash
curl -X POST http://localhost:3000/api/payments/initiate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CONSUMER_TOKEN" \
  -d '{
    "bookingId": "BOOKING_ID"
  }'
```

### 3.12 Test AI Party Planner (Public)

```bash
curl -X POST http://localhost:3000/api/ai/party-planner \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2024-06-15",
    "guests": 50,
    "budget": 5000,
    "theme": "elegant",
    "location": "outdoor"
  }'
```

### 3.13 Refresh Access Token

```bash
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'
```

## Step 4: Test Error Cases

### Invalid Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "wrong@example.com",
    "password": "wrongpassword"
  }'
```

Expected: `401 Unauthorized`

### Unauthorized Access
```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Content-Type: application/json" \
  -d '{"title": "Test"}'
```

Expected: `401 Unauthorized`

### Invalid Token
```bash
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer invalid_token"
```

Expected: `401 Unauthorized`

## Step 5: Verify Database

Check that data is being saved:

```bash
# Using Prisma Studio (GUI)
npm run prisma:studio

# Or using psql
psql -U postgres -d rental_marketplace -c "SELECT * FROM users;"
psql -U postgres -d rental_marketplace -c "SELECT * FROM listings;"
psql -U postgres -d rental_marketplace -c "SELECT * FROM bookings;"
```

## Quick Test Checklist

- [ ] Server starts without errors
- [ ] Health check returns 200
- [ ] Can sign up new user
- [ ] Can login with credentials
- [ ] Can get user profile (authenticated)
- [ ] Can create listing (as OWNER)
- [ ] Can browse listings (public)
- [ ] Can create booking (as CONSUMER)
- [ ] Can view own bookings
- [ ] Can initiate payment
- [ ] AI party planner returns plan
- [ ] Can refresh access token
- [ ] Error handling works (401, 403, 404, 400)

## Using Postman or Thunder Client

1. Import the collection (if available)
2. Set base URL: `http://localhost:3000`
3. For authenticated requests, add header:
   - Key: `Authorization`
   - Value: `Bearer YOUR_ACCESS_TOKEN`

## Troubleshooting

### Server won't start
- Check if port 3000 is available: `lsof -i :3000`
- Verify `.env` file exists and has correct values
- Check database connection: `npm run prisma:studio`

### Authentication errors
- Verify JWT secrets in `.env` are set
- Check token expiration (default: 15 minutes)
- Use refresh token to get new access token

### Database errors
- Ensure PostgreSQL is running: `sudo systemctl status postgresql`
- Verify database exists: `psql -U postgres -l | grep rental_marketplace`
- Check migrations: `npm run prisma:migrate`

### 404 errors
- Verify route paths match exactly
- Check if server is running on correct port
- Ensure routes are registered in `app.ts`

