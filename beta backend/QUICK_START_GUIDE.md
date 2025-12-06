# Quick Start Guide - Running & Testing EVENTOS Backend

**Step-by-step guide to get the backend running and test all endpoints.**

---

## 🚀 Quick Start (TL;DR)

```bash
# 1. Install dependencies
npm install

# 2. Set up .env file (copy from .env.example and fill in values)
cp .env.example .env

# 3. Start database (Docker)
docker-compose up -d db

# 4. Run migrations
npm run prisma:generate
npm run prisma:migrate

# 5. Start server
npm run dev

# 6. Test (in another terminal)
# Windows PowerShell:
.\test-api.ps1

# Linux/Mac:
chmod +x test-api.sh
./test-api.sh
```

**Server will be running at**: `http://localhost:3000`  
**Health check**: `http://localhost:3000/health`

---

## Prerequisites

- **Node.js** 20+ installed ([Download](https://nodejs.org/))
- **PostgreSQL** 12+ installed OR **Docker** installed
- **npm** or **yarn** package manager
- **Postman** or **curl** for testing (optional)

### ⚠️ Windows Users Note

If using **Windows Command Prompt (CMD)**, use `^` for line continuation instead of `\`.  
**PowerShell** users can use backtick `` ` `` for line continuation.  
**Recommended**: Use PowerShell or single-line commands for easier testing.

---

## Step 1: Clone & Install

```bash
# Navigate to project directory
cd "C:\eventos_app\beta backend"

# Install dependencies
npm install
```

**Expected Output**: Dependencies installed successfully.

---

## Step 2: Set Up Environment Variables

### 2.1 Create `.env` File

```bash
# Copy the example file
cp .env.example .env
```

### 2.2 Edit `.env` File

Open `.env` and fill in the values:

```env
# Server
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:3000

# Database (if using local PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/eventos_db?schema=public

# JWT Secrets (generate strong secrets)
JWT_ACCESS_SECRET=your-super-secret-access-token-key-min-32-characters-long
JWT_REFRESH_SECRET=your-super-secret-refresh-token-key-min-32-characters-long
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:8080

# Payment Gateways (optional for now)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
```

**Generate JWT Secrets** (if needed):
```bash
# On Linux/Mac
openssl rand -base64 32

# On Windows PowerShell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

---

## Step 3: Set Up Database

### Option A: Using Docker (Recommended)

```bash
# Start PostgreSQL container
docker-compose up -d db

# Wait a few seconds for database to start
# Check if it's running
docker-compose ps
```

**Expected Output**: Database container running on port 5432 (or 5433 if using default config).

### Option B: Using Local PostgreSQL

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE eventos_db;

# Create user (optional)
CREATE USER eventos WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE eventos_db TO eventos;

# Exit
\q
```

Update `DATABASE_URL` in `.env`:
```env
DATABASE_URL=postgresql://eventos:your_password@localhost:5432/eventos_db?schema=public
```

---

## Step 4: Run Database Migrations

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations (creates all tables)
npm run prisma:migrate
```

**When prompted**, enter a migration name (e.g., `init`).

**Expected Output**: 
- Prisma Client generated
- Migration files created in `prisma/migrations/`
- Database tables created

**Verify Database**:
```bash
# Open Prisma Studio (optional)
npm run prisma:studio
```
This opens a GUI at `http://localhost:5555` to view your database.

---

## Step 5: Start the Development Server

```bash
npm run dev
```

**Expected Output**:
```
[INFO] Database connected successfully
[INFO] Server is running on port 3000
[INFO] Environment: development
[INFO] Health check: http://localhost:3000/health
```

**Keep this terminal open** - the server will auto-reload on file changes.

---

## Step 6: Test the API

### 6.1 Health Check

**Test**: Basic server health

```bash
curl http://localhost:3000/health
```

**Expected Response**:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-12-04T...",
  "environment": "development",
  "database": "connected",
  "uptime": 123.456
}
```

✅ **If you see this, the server is running!**

---

### 6.2 Test Authentication

#### A. Sign Up (Create User)

**Windows Command Prompt (CMD)** - Use `^` for line continuation:
```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"
```
access token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5Y2E3NDllYy0yZmIzLTQzOWYtYmNmOC01MmIzYzI5MWUzN2IiLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQ09OU1VNRVIiLCJpYXQiOjE3NjQ4ODIzNzcsImV4cCI6MTc2NDg4MzI3N30.5NxBaxanOnNrCLb_43Bg4LIHzjppPEuRKHxYR8mUslw"

**Windows PowerShell** - Use backtick `` ` `` for line continuation:
```powershell
curl -X POST http://localhost:3000/api/v1/auth/signup `
  -H "Content-Type: application/json" `
  -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}'
```

**Linux/Mac (Bash)** - Use `\` for line continuation:
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "CONSUMER"
  }'
```

**Single Line (All Platforms)**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"password123\",\"role\":\"CONSUMER\"}"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-here",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "CONSUMER"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Save the `accessToken`** - you'll need it for protected endpoints! 
("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyMzRlYmI4Mi01N2NkLTRkMzQtOTE3ZS1lMTIzYWRmNDE3ODMiLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZSI6IkFETUlOIiwiaWF0IjoxNzY0ODgxNzE1LCJleHAiOjE3NjQ4ODI2MTV9.rII82aADVqeKUlhsE7IEyJaQOfVxxvAuQ0gBoULn52U")

#### B. Sign Up as Owner

**Windows Command Prompt (CMD)**:
```cmd
curl -X POST http://localhost:3000/api/v1/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}"
```

**Windows PowerShell**:
```powershell
curl -X POST http://localhost:3000/api/v1/auth/signup `
  -H "Content-Type: application/json" `
  -d '{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}'
```

**Linux/Mac (Bash)**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Owner",
    "email": "jane@example.com",
    "password": "password123",
    "role": "OWNER"
  }'
```

**Single Line (All Platforms)**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup -H "Content-Type: application/json" -d "{\"name\":\"Jane Owner\",\"email\":\"jane@example.com\",\"password\":\"password123\",\"role\":\"OWNER\"}"
```

**Save this `accessToken` too** - owners can create listings.
"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODI0NDcsImV4cCI6MTc2NDg4MzM0N30.avbtReD5uvnbPwCxG5MLcIPIFt6Z3YaNftl1ABKOkE0"

#### C. Login

**Windows Command Prompt (CMD)**:
```cmd
curl -X POST http://localhost:3000/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

**Windows PowerShell**:
```powershell
curl -X POST http://localhost:3000/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"john@example.com\",\"password\":\"password123\"}'
```

**Linux/Mac (Bash)**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Single Line (All Platforms)**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

**Expected Response**: Same as signup (user + tokens).

---

### 6.3 Test User Profile

⚠️ **IMPORTANT**: The Authorization header **MUST** include `Bearer ` (with a space) before the token!

**Windows Command Prompt (CMD)**:
```cmd
curl http://localhost:3000/api/v1/users/me ^
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Example with actual token**:
```cmd
curl http://localhost:3000/api/v1/users/me ^
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5Y2E3NDllYy0yZmIzLTQzOWYtYmNmOC01MmIzYzI5MWUzN2IiLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQ09OU1VNRVIiLCJpYXQiOjE3NjQ4ODIzNzcsImV4cCI6MTc2NDg4MzI3N30.5NxBaxanOnNrCLb_43Bg4LIHzjppPEuRKHxYR8mUslw"
```

**Windows PowerShell**:
```powershell
curl http://localhost:3000/api/v1/users/me `
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Linux/Mac (Bash)**:
```bash
curl http://localhost:3000/api/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Single Line (All Platforms)**:
```bash
curl http://localhost:3000/api/v1/users/me -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Common Mistake**: ❌ `-H "Authorization: YOUR_TOKEN"` (missing "Bearer ")  
**Correct Format**: ✅ `-H "Authorization: Bearer YOUR_TOKEN"`

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "id": "uuid-here",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": null,
    "role": "CONSUMER",
    "createdAt": "2024-12-04T...",
    "updatedAt": "2024-12-04T..."
  }
}
```

---

### 6.4 Test Listings

#### A. Create Listing (as Owner)

⚠️ **CRITICAL**: You **MUST** use an **OWNER** or **ADMIN** token! CONSUMER tokens will return `403 Forbidden: Insufficient permissions`.

⚠️ **TOKEN ISSUES**: If you get `"Invalid or expired token"`, your token may be corrupted. Get a fresh token by logging in again (see Step 6.2.C above). See `TOKEN_TROUBLESHOOTING.md` for help.

⚠️ **WINDOWS USERS**: Use `^` (not `\`) for line continuation in CMD, or use the single-line command below!

**Windows Command Prompt (CMD) - Single Line (EASIEST)**:
```cmd
curl -X POST http://localhost:3000/api/v1/listings -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODM3MDYsImV4cCI6MTc2NDg4NDYwNn0.FlHsexrZqaevbhkVhTk6fycpWgmuH3BHhsSXJgoIxAc" -d "{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue perfect for weddings and events\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\",\"images\":[\"https://example.com/venue1.jpg\"]}"
```

**Windows Command Prompt (CMD) - Multi-Line** (use `^` not `\`):
```cmd
curl -X POST http://localhost:3000/api/v1/listings ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODI0NDcsImV4cCI6MTc2NDg4MzM0N30.avbtReD5uvnbPwCxG5MLcIPIFt6Z3YaNftl1ABKOkE0" ^
  -d "{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue perfect for weddings and events\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\",\"images\":[\"https://example.com/venue1.jpg\"]}"
```

**Windows PowerShell** (use backtick `` ` `` not `\`):
```powershell
curl -X POST http://localhost:3000/api/v1/listings `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjQwNTdhYi05MzdhLTQyOTItODcwNy01MWQ2OTc4YjQ0NjciLCJlbWFpbCI6ImphbmVAZXhhbXBsZS5jb20iLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NjQ4ODI0NDcsImV4cCI6MTc2NDg4MzM0N30.avbtReD5uvnbPwCxG5MLcIPIFt6Z3YaNftl1ABKOkE0" `
  -d '{\"title\":\"Beautiful Wedding Venue\",\"description\":\"A stunning venue perfect for weddings and events\",\"category\":\"venue\",\"pricePerDay\":5000,\"location\":\"New York, NY\",\"images\":[\"https://example.com/venue1.jpg\"]}'
```

**Linux/Mac (Bash)** - Use `\` for line continuation:
```bash
curl -X POST http://localhost:3000/api/v1/listings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_OWNER_TOKEN" \
  -d '{
    "title": "Beautiful Wedding Venue",
    "description": "A stunning venue perfect for weddings and events",
    "category": "venue",
    "pricePerDay": 5000,
    "location": "New York, NY",
    "images": ["https://example.com/venue1.jpg"]
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "id": "listing-uuid",
    "ownerId": "owner-uuid",
    "title": "Beautiful Wedding Venue",
    "description": "A stunning venue perfect for weddings and events",
    "category": "venue",
    "pricePerDay": 5000,
    "location": "New York, NY",
    "images": ["https://example.com/venue1.jpg"],
    "isActive": true,
    "createdAt": "2024-12-04T...",
    "updatedAt": "2024-12-04T..."
  }
}
```

**Save the `id`** - you'll need it for bookings.
"7920063e-6355-49d2-ae0d-e419c1c48bd4"

#### B. Get All Listings (Public)

```bash
curl http://localhost:3000/api/v1/listings
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "listings": [...],
    "total": 1,
    "page": 1,
    "limit": 10
  }
}
```

#### C. Get Listing by ID (Public)

```bash
# Replace LISTING_ID with the id from create listing
curl http://localhost:3000/api/v1/listings/LISTING_ID
```

#### D. Filter Listings

```bash
# Filter by category
curl "http://localhost:3000/api/v1/listings?category=venue"

# Filter by location
curl "http://localhost:3000/api/v1/listings?location=New York"

# Filter by price range
curl "http://localhost:3000/api/v1/listings?minPrice=1000&maxPrice=10000"
```

---

### 6.5 Test Bookings

#### A. Create Booking (as Consumer)

```bash
# Use CONSUMER access token and LISTING_ID from above
curl -X POST http://localhost:3000/api/v1/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI5Y2E3NDllYy0yZmIzLTQzOWYtYmNmOC01MmIzYzI5MWUzN2IiLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQ09OU1VNRVIiLCJpYXQiOjE3NjQ4ODIzNzcsImV4cCI6MTc2NDg4MzI3N30.5NxBaxanOnNrCLb_43Bg4LIHzjppPEuRKHxYR8mUslw" \
  -d '{
    "listingId": "LISTING_ID",
    "startDate": "2024-06-01T10:00:00Z",
    "endDate": "2024-06-03T18:00:00Z"
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "id": "booking-uuid",
    "listingId": "listing-uuid",
    "userId": "consumer-uuid",
    "startDate": "2024-06-01T10:00:00.000Z",
    "endDate": "2024-06-03T18:00:00.000Z",
    "status": "PENDING",
    "totalAmount": 10000,
    "paymentId": null,
    "createdAt": "2024-12-04T...",
    "updatedAt": "2024-12-04T..."
  }
}
```

**Save the `id`** - you'll need it for payments.

#### B. Get My Bookings

```bash
curl http://localhost:3000/api/v1/bookings/me \
  -H "Authorization: Bearer CONSUMER_ACCESS_TOKEN"
```

#### C. Get Owner Bookings

```bash
curl http://localhost:3000/api/v1/bookings/owner \
  -H "Authorization: Bearer OWNER_ACCESS_TOKEN"
```

---

### 6.6 Test Payments

#### A. Create Payment Intent

**Windows Command Prompt (CMD)**:
```cmd
curl -X POST http://localhost:3000/api/v1/payments/create ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer CONSUMER_ACCESS_TOKEN" ^
  -d "{\"bookingId\":\"BOOKING_ID\",\"amount\":10000,\"currency\":\"USD\"}"
```

**Windows PowerShell**:
```powershell
curl -X POST http://localhost:3000/api/v1/payments/create `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer CONSUMER_ACCESS_TOKEN" `
  -d '{\"bookingId\":\"BOOKING_ID\",\"amount\":10000,\"currency\":\"USD\"}'
```

**Linux/Mac (Bash)**:
```bash
curl -X POST http://localhost:3000/api/v1/payments/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CONSUMER_ACCESS_TOKEN" \
  -d '{
    "bookingId": "BOOKING_ID",
    "amount": 10000,
    "currency": "USD"
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "paymentId": "payment-uuid",
    "paymentIntentId": "pi_mock_1234567890_abc123",
    "status": "PENDING",
    "amount": 10000,
    "currency": "USD"
  }
}
```

**Note**: This is a mock payment - no real money is processed.

#### B. Test Webhook (Mock)

```bash
curl -X POST http://localhost:3000/api/v1/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "type": "payment_intent.succeeded",
    "provider": "STRIPE",
    "paymentIntentId": "pi_mock_1234567890_abc123",
    "data": {
      "object": {
        "id": "pi_mock_1234567890_abc123"
      }
    }
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "message": "Webhook processed",
  "received": true
}
```

**Check**: The booking status should now be `PAID` (verify via `/api/v1/bookings/me`).

---

### 6.7 Test AI Planner

**Windows Command Prompt (CMD)**:
```cmd
curl -X POST http://localhost:3000/api/v1/ai-planner/suggest ^
  -H "Content-Type: application/json" ^
  -d "{\"eventType\":\"wedding\",\"budget\":10000,\"guests\":100,\"location\":\"outdoor\",\"date\":\"2024-06-15\",\"vibe\":\"elegant\",\"theme\":\"rustic\"}"
```

**Windows PowerShell**:
```powershell
curl -X POST http://localhost:3000/api/v1/ai-planner/suggest `
  -H "Content-Type: application/json" `
  -d '{\"eventType\":\"wedding\",\"budget\":10000,\"guests\":100,\"location\":\"outdoor\",\"date\":\"2024-06-15\",\"vibe\":\"elegant\",\"theme\":\"rustic\"}'
```

**Linux/Mac (Bash)**:
```bash
curl -X POST http://localhost:3000/api/v1/ai-planner/suggest \
  -H "Content-Type: application/json" \
  -d '{
    "eventType": "wedding",
    "budget": 10000,
    "guests": 100,
    "location": "outdoor",
    "date": "2024-06-15",
    "vibe": "elegant",
    "theme": "rustic"
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "theme": "rustic elegant",
    "suggestedDecor": [...],
    "suggestedRentals": [...],
    "suggestedStaff": [...],
    "budgetBreakdown": [...],
    "totalEstimatedCost": 10000,
    "recommendations": [...]
  }
}
```

---

## Step 7: Test Error Handling

### 7.1 Test Validation Errors

```bash
# Missing required field
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "invalid-email"
  }'
```

**Expected Response** (400):
```json
{
  "success": false,
  "message": "Validation error",
  "code": "VALIDATION_ERROR",
  "details": [
    {
      "path": "body.password",
      "message": "Required"
    },
    {
      "path": "body.email",
      "message": "Invalid email format"
    }
  ]
}
```

### 7.2 Test Unauthorized Access

```bash
# Try to access protected endpoint without token
curl http://localhost:3000/api/v1/users/me
```

**Expected Response** (401):
```json
{
  "success": false,
  "message": "No token provided",
  "code": "UNAUTHORIZED",
  "details": null
}
```

### 7.3 Test Forbidden Access

```bash
# Try to create listing as CONSUMER (should fail)
curl -X POST http://localhost:3000/api/v1/listings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CONSUMER_ACCESS_TOKEN" \
  -d '{
    "title": "Test",
    "description": "Test",
    "category": "test",
    "pricePerDay": 100,
    "location": "Test"
  }'
```

**Expected Response** (403):
```json
{
  "success": false,
  "message": "Forbidden: Insufficient permissions",
  "code": "FORBIDDEN",
  "details": null
}
```

---

## Step 8: Test Rate Limiting

```bash
# Make 6 rapid requests to auth endpoint (limit is 5)
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test"}'
  echo ""
done
```

**Expected**: First 5 succeed, 6th returns 429 (Too Many Requests):
```json
{
  "success": false,
  "error": "Too many authentication attempts, please try again later.",
  "code": "AUTH_RATE_LIMIT_EXCEEDED"
}
```

---

## Step 9: Using Postman (Alternative)

### 9.1 Import Collection

1. Open Postman
2. Create a new Collection: "EVENTOS API"
3. Add environment variables:
   - `base_url`: `http://localhost:3000`
   - `access_token`: (will be set after login)

### 9.2 Create Requests

**Health Check**:
- Method: `GET`
- URL: `{{base_url}}/health`

**Sign Up**:
- Method: `POST`
- URL: `{{base_url}}/api/v1/auth/signup`
- Body (JSON):
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- Tests (to save token):
  ```javascript
  if (pm.response.code === 201) {
    const jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.data.accessToken);
  }
  ```

**Get Profile**:
- Method: `GET`
- URL: `{{base_url}}/api/v1/users/me`
- Headers: `Authorization: Bearer {{access_token}}`

---

## Step 10: Verify Everything Works

### Complete Flow Test

1. ✅ **Health Check** → Server running
2. ✅ **Sign Up** → User created, tokens received
3. ✅ **Login** → Tokens received
4. ✅ **Get Profile** → User data returned
5. ✅ **Create Listing** (as Owner) → Listing created
6. ✅ **Get Listings** → Listings returned
7. ✅ **Create Booking** (as Consumer) → Booking created
8. ✅ **Create Payment** → Payment intent created
9. ✅ **AI Planner** → Suggestions returned
10. ✅ **Error Handling** → Proper error responses

---

## Troubleshooting

### Rate Limit Error

**Error**: `AUTH_RATE_LIMIT_EXCEEDED` or `Too many authentication attempts`

**Solutions**:

1. **Wait for Rate Limit to Reset** (15 minutes):
   - The rate limit resets after 15 minutes
   - Development: 50 requests per 15 minutes
   - Production: 5 requests per 15 minutes

2. **Restart the Server** (Development only):
   ```bash
   # Stop the server (Ctrl+C)
   # Start again - this resets the in-memory rate limit store
   npm run dev
   ```

3. **Use Different IP/Endpoint**:
   - Try the legacy endpoint: `/api/auth/signup` instead of `/api/v1/auth/signup`
   - Or wait a few minutes between attempts

4. **Disable Rate Limiting Temporarily** (Development only):
   - Comment out rate limiter in `src/app.ts`:
     ```typescript
     // app.use('/api/v1/auth', authRateLimiter, authRoutes);
     app.use('/api/v1/auth', authRoutes);
     ```
   - **Remember to re-enable before production!**

**Note**: Rate limiting is working as intended - it's protecting against brute force attacks. In development, limits are more lenient (50 vs 5 in production).

---

### Database Connection Error

**Error**: `Database connection failed`

**Solutions**:
1. Check PostgreSQL is running:
   ```bash
   # Docker
   docker-compose ps
   
   # Local
   psql -U postgres -c "SELECT 1"
   ```

2. Verify `DATABASE_URL` in `.env` is correct
3. Check database exists:
   ```bash
   psql -U postgres -l | grep eventos_db
   ```

### Port Already in Use

**Error**: `EADDRINUSE: address already in use :::3000`

**Solutions**:
1. Change `PORT` in `.env` to another port (e.g., 3001)
2. Or kill the process using port 3000:
   ```bash
   # Windows
   netstat -ano | findstr :3000
   taskkill /PID <PID> /F
   
   # Linux/Mac
   lsof -ti:3000 | xargs kill
   ```

### Migration Errors

**Error**: `Migration failed`

**Solutions**:
1. Check database connection
2. Verify Prisma schema is valid:
   ```bash
   npx prisma validate
   ```
3. Reset database (⚠️ deletes all data):
   ```bash
   npx prisma migrate reset
   ```

### JWT Secret Too Short

**Error**: `JWT_ACCESS_SECRET must be at least 32 characters`

**Solution**: Generate longer secrets (see Step 2.2)

---

## Quick Test Script

Save this as `test-api.sh` (Linux/Mac) or `test-api.ps1` (Windows):

```bash
#!/bin/bash
BASE_URL="http://localhost:3000"

echo "1. Health Check..."
curl -s $BASE_URL/health | jq .

echo -e "\n2. Sign Up..."
SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}')
echo $SIGNUP_RESPONSE | jq .

TOKEN=$(echo $SIGNUP_RESPONSE | jq -r '.data.accessToken')
echo -e "\nToken: $TOKEN"

echo -e "\n3. Get Profile..."
curl -s $BASE_URL/api/v1/users/me \
  -H "Authorization: Bearer $TOKEN" | jq .

echo -e "\n✅ All tests passed!"
```

**Run**:
```bash
chmod +x test-api.sh
./test-api.sh
```

---

## Next Steps

- ✅ Backend is running and tested
- 📝 Review `API_OVERVIEW.md` for complete API documentation
- 🔒 Review `SECURITY_AND_VALIDATION_SUMMARY.md` for security details
- 🚀 Review `ARCHITECTURE_NOTES.md` Section 13 for production deployment

---

**Status**: ✅ Backend is ready for development and testing!

