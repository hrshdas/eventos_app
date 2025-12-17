# Rental Marketplace Backend

A production-ready B2C rental marketplace backend built with Node.js, TypeScript, Express, PostgreSQL, and Prisma ORM. Features include user authentication, listing management, booking system, payment integration (Stripe), and an AI party planner.

## Features

- 🔐 JWT-based authentication (access + refresh tokens)
- 📦 Listings management (rentals + professionals)
- 📅 Booking system with availability checking
- 💳 Payment integration (Stripe/Razorpay placeholder)
- 🤖 AI Party Planner endpoint (dummy implementation)
- ✅ Request validation with Zod
- 🛡️ Role-based access control (CONSUMER, OWNER, ADMIN)
- 📝 Comprehensive error handling
- 🗄️ PostgreSQL database with Prisma ORM

## Tech Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT (jsonwebtoken)
- **Validation**: Zod
- **Payment**: Stripe (test mode)
- **Password Hashing**: bcryptjs

## Project Structure

```
src/
├── index.ts              # Application entry point
├── app.ts                # Express app setup
├── config/
│   ├── env.ts           # Environment configuration
│   └── db.ts            # Prisma client setup
├── prisma/
│   └── schema.prisma    # Database schema
├── routes/              # API route definitions
├── controllers/         # Request handlers
├── services/            # Business logic
├── middleware/          # Express middleware
├── types/               # TypeScript type definitions
└── utils/               # Utility functions
```

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
npm install
```

### 2. Set Up Environment Variables

Create a `.env` file in the root directory (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/rental_marketplace?schema=public"
JWT_ACCESS_SECRET="your-super-secret-access-token-key"
JWT_REFRESH_SECRET="your-super-secret-refresh-token-key"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"
PORT=3000
NODE_ENV=development
STRIPE_SECRET_KEY="sk_test_your_stripe_secret_key"
STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret"
# Google Sign-In (set one or multiple)
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_ID_ANDROID=""
GOOGLE_CLIENT_ID_IOS=""
GOOGLE_CLIENT_ID_WEB=""
```

> Note: You can set either a single `GOOGLE_CLIENT_ID` or platform-specific client IDs. The backend validates Google ID tokens against any of the configured client IDs.

### 3. Set Up Database

#### Create PostgreSQL Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE rental_marketplace;

# Exit
\q
```

#### Run Prisma Migrations

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

This will:
- Create all database tables
- Set up relationships and indexes
- Generate the Prisma Client

### 4. Start Development Server

```bash
npm run dev
```

The server will start on `http://localhost:3000` (or your configured PORT).

## API Endpoints

### Health Check
- `GET /health` - Server health check

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/google` - Sign in with Google (exchange idToken for JWTs)

### Users
- `GET /api/users/me` - Get current user profile (protected)

### Listings
- `GET /api/listings` - Get all listings (public, with filters)
- `GET /api/listings/:id` - Get listing by ID (public)
- `POST /api/listings` - Create listing (OWNER/ADMIN)
- `PATCH /api/listings/:id` - Update listing (OWNER/ADMIN)
- `DELETE /api/listings/:id` - Delete listing (OWNER/ADMIN)

### Bookings
- `POST /api/bookings` - Create booking (authenticated)
- `GET /api/bookings/me` - Get user's bookings (authenticated)
- `GET /api/bookings/owner` - Get owner's bookings (OWNER/ADMIN)

### Payments
- `POST /api/payments/initiate` - Initiate payment (authenticated)
- `POST /api/payments/webhook` - Payment webhook (Stripe)

### AI Party Planner
- `POST /api/ai/party-planner` - Generate party plan (public)

## Testing the Flow

### 1. Sign Up

```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "OWNER"
  }'
```

### 2. Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 3. Google Sign-In (server verification)

```bash
# Replace <ID_TOKEN> with a token from your Flutter app or Google Playground
curl -X POST http://localhost:3000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "<ID_TOKEN>"
  }'
```

### 4. Create Listing (as OWNER)

```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "Beautiful Wedding Venue",
    "description": "A stunning venue for your special day",
    "category": "venue",
    "pricePerDay": 5000,
    "location": "New York, NY",
    "images": ["https://example.com/image1.jpg"]
  }'
```

## Google Token Troubleshooting

If ID token verification fails, use the following Node snippet locally to debug the payload and audiences:

```ts
import { OAuth2Client } from 'google-auth-library';

async function debug(idToken: string, audiences: string[]) {
  const client = new OAuth2Client();
  const ticket = await client.verifyIdToken({ idToken, audience: audiences });
  const payload = ticket.getPayload();
  console.log('Issuer:', payload?.iss);
  console.log('Audience (aud):', payload?.aud);
  console.log('Email:', payload?.email);
}

// Example usage
// debug(process.env.DEBUG_ID_TOKEN as string, [
//   process.env.GOOGLE_CLIENT_ID_ANDROID!,
//   process.env.GOOGLE_CLIENT_ID_IOS!,
//   process.env.GOOGLE_CLIENT_ID_WEB!,
//   process.env.GOOGLE_CLIENT_ID!,
// ].filter(Boolean));
```

## Database Models

- **User**: Users with roles (CONSUMER, OWNER, ADMIN)
- **Listing**: Rental/professional listings
- **Booking**: Bookings with status tracking
- **Payment**: Payment records linked to bookings
- **Review**: Reviews for listings

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm run start` - Start production server
- `npm run prisma:generate` - Generate Prisma Client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio (database GUI)
- `npm run lint` - Run ESLint
- `npm run type-check` - Type check without building

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `JWT_ACCESS_SECRET` | Secret for access tokens | Yes |
| `JWT_REFRESH_SECRET` | Secret for refresh tokens | Yes |
| `JWT_ACCESS_EXPIRES_IN` | Access token expiration | No (default: 15m) |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token expiration | No (default: 7d) |
| `PORT` | Server port | No (default: 3000) |
| `NODE_ENV` | Environment (development/production) | No |
| `STRIPE_SECRET_KEY` | Stripe secret key | No (for payments) |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | No |
| `GOOGLE_CLIENT_ID` | Single Google client ID (fallback) | No |
| `GOOGLE_CLIENT_ID_ANDROID` | Android client ID | No |
| `GOOGLE_CLIENT_ID_IOS` | iOS client ID | No |
| `GOOGLE_CLIENT_ID_WEB` | Web client ID | No |

## Security Notes

- Passwords are hashed using bcryptjs
- JWT tokens are used for authentication
- Role-based access control implemented
- Request validation with Zod
- Environment variables for sensitive data

## Production Considerations

1. **Environment Variables**: Use secure secret management (AWS Secrets Manager, etc.)
2. **Database**: Use connection pooling and read replicas
3. **Rate Limiting**: Add rate limiting middleware
4. **CORS**: Configure CORS properly for your frontend
5. **Logging**: Set up proper logging service (Winston, Pino, etc.)
6. **Monitoring**: Add health checks and monitoring
7. **Testing**: Add unit and integration tests
8. **CI/CD**: Set up automated deployment pipeline

## Next Steps

- [ ] Add unit and integration tests
- [ ] Implement real LLM integration for AI party planner
- [ ] Add email notifications
- [ ] Implement file upload for listing images
- [ ] Add search functionality with full-text search
- [ ] Implement review system endpoints
- [ ] Add pagination metadata
- [ ] Set up API documentation (Swagger/OpenAPI)

## Quick Testing

### Automated Test Script

Run the automated test script to verify all endpoints:

```bash
./test-api.sh
```

This script will:
- Test health check
- Sign up as OWNER and CONSUMER
- Create a listing
- Create a booking
- Test AI party planner

### Manual Testing

1. **Start the server:**
   ```bash
   npm run dev
   ```

2. **Test health check:**
   ```bash
   curl http://localhost:3000/health
   ```

3. **Sign up and test endpoints** (see `TESTING.md` for detailed examples)

For complete testing instructions, see [TESTING.md](./TESTING.md)

## License

ISC
