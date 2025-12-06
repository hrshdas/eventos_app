# Architecture Analysis & Production Readiness Plan

**Generated:** $(date)  
**Project:** EVENTOS Backend API  
**Stack:** Node.js + TypeScript + Express + Prisma + PostgreSQL + JWT

---

## 1. Current Folder Structure

```
beta backend/
├── src/
│   ├── index.ts                    # Entry point, server startup
│   ├── app.ts                      # Express app configuration
│   ├── config/
│   │   ├── db.ts                   # Prisma client singleton
│   │   └── env.ts                  # Environment configuration
│   ├── routes/
│   │   ├── auth.routes.ts          # Authentication routes
│   │   ├── user.routes.ts          # User profile routes
│   │   ├── listing.routes.ts       # Listing CRUD routes
│   │   ├── booking.routes.ts       # Booking routes
│   │   ├── payment.routes.ts       # Payment routes
│   │   └── ai.routes.ts            # AI party planner routes
│   ├── controllers/
│   │   ├── auth.controller.ts      # Auth request handlers
│   │   ├── listing.controller.ts   # Listing request handlers
│   │   ├── booking.controller.ts   # Booking request handlers
│   │   ├── payment.controller.ts   # Payment request handlers
│   │   └── ai.controller.ts        # AI request handlers
│   ├── services/
│   │   ├── auth.service.ts         # Auth business logic
│   │   ├── listing.service.ts      # Listing business logic
│   │   ├── booking.service.ts      # Booking business logic
│   │   ├── payment.service.ts      # Payment business logic
│   │   └── ai.service.ts           # AI business logic (dummy)
│   ├── middleware/
│   │   ├── authMiddleware.ts       # JWT authentication & RBAC
│   │   ├── errorHandler.ts        # Global error handler
│   │   └── validateRequest.ts      # Zod validation middleware
│   ├── utils/
│   │   ├── jwt.ts                  # JWT token generation/verification
│   │   └── logger.ts               # Simple console logger
│   └── types/
│       └── express.d.ts            # Express Request type extension
├── prisma/
│   └── schema.prisma               # Database schema
├── package.json
├── tsconfig.json
└── docker-compose.yml
```

---

## 2. Existing Routes/Modules Summary

### **Authentication Module** (`/api/auth`)
- ✅ `POST /signup` - User registration with role support
- ✅ `POST /login` - JWT-based login (access + refresh tokens)
- ✅ `POST /refresh` - Refresh access token

### **User Module** (`/api/users`)
- ✅ `GET /me` - Get current user profile (protected)

### **Listings Module** (`/api/listings`)
- ✅ `GET /` - List all listings (public, with filters: category, location, price range, pagination)
- ✅ `GET /:id` - Get listing by ID (public, includes owner & reviews)
- ✅ `POST /` - Create listing (OWNER/ADMIN only)
- ✅ `PATCH /:id` - Update listing (OWNER/ADMIN only, ownership check)
- ✅ `DELETE /:id` - Delete listing (OWNER/ADMIN only, ownership check)

### **Bookings Module** (`/api/bookings`)
- ✅ `POST /` - Create booking (authenticated, validates availability, calculates total)
- ✅ `GET /me` - Get user's bookings (authenticated)
- ✅ `GET /owner` - Get owner's bookings (OWNER/ADMIN only)

### **Payments Module** (`/api/payments`)
- ✅ `POST /initiate` - Initiate payment (Stripe PaymentIntent, authenticated)
- ✅ `POST /webhook` - Stripe webhook handler (raw body parsing)

### **AI Planner Module** (`/api/ai`)
- ⚠️ `POST /party-planner` - Generate party plan (dummy implementation, no real LLM)

---

## 3. Current Middleware & Error Handling

### **Middleware Stack:**
1. **CORS** - Configured with allowed origins from env
2. **express.json()** - Body parsing (except webhook route uses raw)
3. **express.urlencoded()** - URL-encoded body parsing
4. **authMiddleware** - JWT verification, attaches user to `req.user`
5. **requireRole()** - Role-based access control (CONSUMER, OWNER, ADMIN)
6. **validateRequest()** - Zod schema validation (body, query, params)
7. **errorHandler** - Global error handler (last middleware)

### **Error Handling:**
- ✅ Custom `ApiError` interface with `statusCode`
- ✅ Zod validation errors → 400 with details
- ✅ Prisma errors (P2002 duplicate, P2025 not found) → appropriate status codes
- ✅ Custom API errors → use `statusCode` from error
- ✅ Default 500 for unhandled errors (hides message in production)
- ✅ Error logging via logger utility

---

## 4. Current Prisma Schema & Database Tables

### **Models:**

1. **User**
   - Fields: `id`, `name`, `email` (unique), `phone`, `passwordHash`, `role` (enum: CONSUMER, OWNER, ADMIN)
   - Relations: `ownedListings`, `bookings`, `reviews`
   - Indexes: `email`

2. **Listing**
   - Fields: `id`, `ownerId`, `title`, `description`, `category`, `pricePerDay`, `location`, `images` (string[]), `isActive`
   - Relations: `owner` (User), `bookings`, `reviews`
   - Indexes: `ownerId`, `category`, `location`, `isActive`

3. **Booking**
   - Fields: `id`, `listingId`, `userId`, `startDate`, `endDate`, `status` (enum: PENDING, PAID, CONFIRMED, CANCELLED), `totalAmount`, `paymentId` (optional)
   - Relations: `listing`, `user`, `payment` (optional)
   - Indexes: `listingId`, `userId`, `status`

4. **Payment**
   - Fields: `id`, `bookingId` (unique), `provider` (enum: STRIPE, RAZORPAY), `providerPaymentId`, `status` (enum: PENDING, SUCCESS, FAILED, REFUNDED), `amount`
   - Relations: `booking`
   - Indexes: `bookingId`, `status`, `providerPaymentId`

5. **Review**
   - Fields: `id`, `listingId`, `userId`, `rating` (1-5), `comment`, `createdAt`
   - Relations: `listing`, `user`
   - Indexes: `listingId`, `userId`

### **Database Features:**
- ✅ UUID primary keys
- ✅ Timestamps (`createdAt`, `updatedAt`)
- ✅ Cascade deletes on relations
- ✅ Appropriate indexes for query performance
- ✅ Enums for status fields

---

## 5. Architecture Assessment

### ✅ **What's Good:**

1. **Clean Separation of Concerns**
   - Routes → Controllers → Services pattern is well-established
   - Business logic isolated in services
   - Controllers are thin (just handle HTTP concerns)

2. **Type Safety**
   - TypeScript throughout
   - Prisma generates types
   - Express types extended for `req.user`

3. **Validation**
   - Zod schemas defined in routes
   - Request validation middleware
   - Type-safe validation

4. **Error Handling**
   - Centralized error handler
   - Proper HTTP status codes
   - Error logging

5. **Authentication & Authorization**
   - JWT with access + refresh tokens
   - Role-based access control
   - Middleware composition (authMiddleware + requireRole)

6. **Database Design**
   - Well-normalized schema
   - Proper indexes
   - Cascade deletes configured

7. **Configuration Management**
   - Centralized env config
   - Environment variable validation
   - Type-safe config object

8. **Code Organization**
   - Follows clean architecture principles
   - Consistent naming conventions
   - Modular structure

### ⚠️ **What Must Be Improved for Production:**

#### **A. Missing Production Features**

1. **Logging**
   - ❌ Current logger is console-based only
   - ❌ No structured logging (JSON)
   - ❌ No log levels in production
   - ❌ No log rotation or external log aggregation

2. **Rate Limiting**
   - ❌ No rate limiting middleware
   - ❌ Vulnerable to brute force attacks
   - ❌ No API throttling

3. **Security Enhancements**
   - ❌ No request sanitization (XSS protection)
   - ❌ No helmet.js for security headers
   - ❌ No CSRF protection (if needed for webhooks)
   - ❌ No input sanitization beyond Zod validation
   - ❌ Refresh token not stored/revoked (stateless but no blacklist)

4. **Testing**
   - ❌ No unit tests
   - ❌ No integration tests
   - ❌ No test coverage

5. **Documentation**
   - ❌ No API documentation (Swagger/OpenAPI)
   - ❌ No inline JSDoc comments
   - ❌ No architecture decision records

6. **Monitoring & Observability**
   - ❌ No health check beyond basic `/health`
   - ❌ No metrics collection (Prometheus, etc.)
   - ❌ No distributed tracing
   - ❌ No error tracking (Sentry, etc.)

7. **Database**
   - ❌ No connection pooling configuration
   - ❌ No query timeout configuration
   - ❌ No database migration strategy documented
   - ❌ No seed data script

8. **Code Quality**
   - ❌ No consistent error response format (some use `error`, some use `message`)
   - ❌ Some controllers have direct Prisma access (user.routes.ts)
   - ❌ No DTOs/interfaces for API responses
   - ❌ Missing input validation on query params (pagination, filters)

#### **B. Code Structure Issues**

1. **Inconsistent Patterns**
   - `user.routes.ts` has inline controller logic (should use controller pattern)
   - Some services return Prisma types directly (should use DTOs)
   - Error messages inconsistent

2. **Missing Abstractions**
   - No repository pattern (direct Prisma in services)
   - No DTOs for API responses
   - No constants file for magic strings/numbers

3. **Type Safety Gaps**
   - Some `any` types in payment controller
   - Prisma types exposed in API responses (should use DTOs)

#### **C. Missing Features**

1. **Review System**
   - Schema exists but no endpoints

2. **File Upload**
   - No image upload handling (images are URLs only)

3. **Search**
   - Basic filtering but no full-text search

4. **Notifications**
   - No email/SMS notifications
   - No in-app notifications

5. **AI Integration**
   - Dummy implementation, needs real LLM integration

6. **Pagination**
   - Basic pagination but no metadata (total pages, hasNext, etc.)

---

## 6. Proposed Clean Architecture Layout

### **Current Structure vs. Proposed:**

The current structure **already follows clean architecture principles** very well! The proposed structure is almost identical, with minor organizational improvements:

```
src/
├── index.ts                    # Entry point (KEEP)
├── app.ts                      # Express app setup (KEEP)
│
├── config/                     # Configuration (KEEP)
│   ├── db.ts
│   ├── env.ts
│   └── constants.ts            # NEW: App constants
│
├── routes/                     # Route definitions (KEEP)
│   ├── auth.routes.ts
│   ├── user.routes.ts
│   ├── listing.routes.ts
│   ├── booking.routes.ts
│   ├── payment.routes.ts
│   └── ai.routes.ts
│
├── controllers/                # Request handlers (KEEP)
│   ├── auth.controller.ts
│   ├── user.controller.ts      # NEW: Extract from user.routes.ts
│   ├── listing.controller.ts
│   ├── booking.controller.ts
│   ├── payment.controller.ts
│   └── ai.controller.ts
│
├── services/                   # Business logic (KEEP)
│   ├── auth.service.ts
│   ├── user.service.ts         # NEW: Extract user logic
│   ├── listing.service.ts
│   ├── booking.service.ts
│   ├── payment.service.ts
│   └── ai.service.ts
│
├── middleware/                 # Express middleware (KEEP)
│   ├── authMiddleware.ts
│   ├── errorHandler.ts
│   ├── validateRequest.ts
│   ├── rateLimiter.ts          # NEW: Rate limiting
│   └── requestLogger.ts        # NEW: Request logging
│
├── utils/                      # Utility functions (KEEP)
│   ├── jwt.ts
│   ├── logger.ts               # ENHANCE: Structured logging
│   └── validators.ts           # NEW: Reusable validators
│
├── types/                      # TypeScript types (KEEP)
│   ├── express.d.ts
│   ├── api.d.ts                # NEW: API response types
│   └── dto.d.ts                # NEW: Data Transfer Objects
│
└── prisma/                     # Database (KEEP)
    ├── schema.prisma
    └── seeds/                  # NEW: Seed scripts
        └── seed.ts
```

### **Key Changes:**
1. ✅ **Keep existing structure** - It's already clean!
2. ➕ **Add missing abstractions** - DTOs, constants, seed scripts
3. ➕ **Extract inline logic** - Move user route logic to controller/service
4. ➕ **Add production middleware** - Rate limiting, request logging
5. ➕ **Enhance utilities** - Structured logging, validators

---

## 7. Refactoring Plan (Non-Destructive)

### **Phase 1: Code Quality Improvements** (Low Risk)

1. **Extract User Route Logic**
   - Move inline controller logic from `user.routes.ts` to `user.controller.ts`
   - Create `user.service.ts` for business logic
   - Keep route file clean (just route definitions)

2. **Standardize Error Responses**
   - Create consistent error response format
   - Update all controllers to use same format
   - Add error response DTOs

3. **Add Constants File**
   - Move magic strings to `config/constants.ts`
   - Define enums for status codes, roles, etc.

4. **Add DTOs/Response Types**
   - Create `types/dto.d.ts` for request/response DTOs
   - Create `types/api.d.ts` for API response wrapper types
   - Replace direct Prisma types in API responses

### **Phase 2: Production Features** (Medium Risk)

5. **Enhance Logging**
   - Replace console logger with structured logger (Winston/Pino)
   - Add request ID tracking
   - Add log levels and formatting

6. **Add Rate Limiting**
   - Install `express-rate-limit`
   - Create `middleware/rateLimiter.ts`
   - Apply to auth endpoints and general API

7. **Add Request Logging**
   - Create `middleware/requestLogger.ts`
   - Log requests with timing, status codes
   - Add request ID middleware

8. **Add Security Middleware**
   - Install `helmet.js`
   - Add security headers
   - Add input sanitization

### **Phase 3: Testing & Documentation** (Low Risk)

9. **Add Tests**
   - Set up Jest/Vitest
   - Add unit tests for services
   - Add integration tests for routes

10. **Add API Documentation**
    - Install Swagger/OpenAPI
    - Document all endpoints
    - Add JSDoc comments

### **Phase 4: Database & Infrastructure** (Medium Risk)

11. **Database Improvements**
    - Add connection pooling config
    - Add query timeout config
    - Create seed script

12. **Add Health Checks**
    - Enhance `/health` endpoint
    - Add database health check
    - Add readiness/liveness probes

---

## 12. Prisma Migration Commands

### **Development Migrations**

```bash
# Create a new migration (interactive)
npm run prisma:migrate

# Or directly:
npx prisma migrate dev --name migration_name

# Generate Prisma Client after schema changes
npm run prisma:generate
```

### **Production Migrations**

```bash
# Deploy migrations to production (non-interactive)
npx prisma migrate deploy

# Generate Prisma Client
npm run prisma:generate
```

### **Migration Workflow**

1. **Development**:
   ```bash
   # Make changes to schema.prisma
   # Then run:
   npm run prisma:migrate
   # This will:
   # - Create migration files
   # - Apply migration to dev database
   # - Regenerate Prisma Client
   ```

2. **Production**:
   ```bash
   # After deploying code with new migrations:
   npm run prisma:generate  # Generate client
   npx prisma migrate deploy  # Apply pending migrations
   ```

### **Important Notes**

- ⚠️ **Never run `prisma migrate dev` in production** - use `migrate deploy`
- ✅ Always run `prisma generate` after schema changes
- ✅ Review migration files in `prisma/migrations/` before deploying
- ✅ Test migrations on staging before production

---

## 8. File-Level Tasks (When Ready to Execute)

### **Immediate (Non-Breaking):**

1. ✅ Create `ARCHITECTURE_NOTES.md` (this file)

2. **Create `src/config/constants.ts`**
   - Define app-wide constants
   - Status codes, default values, etc.

3. **Create `src/types/api.d.ts`**
   - `ApiResponse<T>` generic type
   - `ApiErrorResponse` type
   - Standardize response format

4. **Create `src/types/dto.d.ts`**
   - Request DTOs for each endpoint
   - Response DTOs (exclude sensitive fields)
   - Transform Prisma types to DTOs

5. **Refactor `src/routes/user.routes.ts`**
   - Extract controller logic to `src/controllers/user.controller.ts`
   - Create `src/services/user.service.ts`
   - Keep route file minimal

6. **Enhance `src/middleware/errorHandler.ts`**
   - Standardize error response format
   - Add error codes
   - Improve error logging

### **Next Steps (With Dependencies):**

7. **Enhance `src/utils/logger.ts`**
   - Replace with Winston or Pino
   - Add structured logging (JSON)
   - Add log levels and formatting
   - Add request ID support

8. **Create `src/middleware/rateLimiter.ts`**
   - Configure rate limits per route
   - Different limits for auth vs. general API
   - Use `express-rate-limit`

9. **Create `src/middleware/requestLogger.ts`**
   - Log all requests with timing
   - Include request ID
   - Log response status

10. **Add Security Middleware**
    - Install and configure `helmet`
    - Add to `src/app.ts`

11. **Create `prisma/seeds/seed.ts`**
    - Seed development data
    - Add script to `package.json`

12. **Add Tests**
    - Set up test framework
    - Create test utilities
    - Add example tests

13. **Add API Documentation**
    - Install Swagger/OpenAPI
    - Document all endpoints
    - Add to `src/app.ts`

---

## 9. Production Checklist

### **Before Production Deployment:**

- [ ] **Environment Variables**
  - [ ] All secrets in secure vault (not in code)
  - [ ] Environment-specific configs
  - [ ] Validation on startup

- [ ] **Security**
  - [ ] Rate limiting enabled
  - [ ] Helmet.js configured
  - [ ] CORS properly configured
  - [ ] Input sanitization
  - [ ] SQL injection protection (Prisma handles this)
  - [ ] XSS protection

- [ ] **Logging & Monitoring**
  - [ ] Structured logging (JSON)
  - [ ] Log aggregation (CloudWatch, Datadog, etc.)
  - [ ] Error tracking (Sentry)
  - [ ] Metrics collection
  - [ ] Health checks

- [ ] **Database**
  - [ ] Connection pooling configured
  - [ ] Read replicas (if needed)
  - [ ] Backup strategy
  - [ ] Migration strategy

- [ ] **Testing**
  - [ ] Unit tests (>80% coverage)
  - [ ] Integration tests
  - [ ] E2E tests for critical flows

- [ ] **Documentation**
  - [ ] API documentation (Swagger)
  - [ ] Deployment guide
  - [ ] Runbook for operations

- [ ] **Performance**
  - [ ] Load testing
  - [ ] Database query optimization
  - [ ] Caching strategy (Redis, if needed)

- [ ] **CI/CD**
  - [ ] Automated tests in pipeline
  - [ ] Automated deployments
  - [ ] Rollback strategy

---

## 10. Recommendations Summary

### **Keep As-Is:**
- ✅ Folder structure (already clean)
- ✅ Routes → Controllers → Services pattern
- ✅ Prisma schema design
- ✅ Authentication/authorization flow
- ✅ Error handling approach

### **Improve:**
- 🔧 Extract inline logic (user routes)
- 🔧 Standardize error responses
- 🔧 Add DTOs for API responses
- 🔧 Enhance logging (structured)
- 🔧 Add rate limiting
- 🔧 Add security middleware

### **Add:**
- ➕ Tests (unit + integration)
- ➕ API documentation
- ➕ Seed scripts
- ➕ Health checks
- ➕ Monitoring/observability
- ➕ Constants file

---

## 11. Next Steps

**When you're ready to proceed:**

1. Review this document and confirm priorities
2. Start with Phase 1 (non-breaking improvements)
3. Test thoroughly after each change
4. Move to Phase 2 (production features)
5. Add tests and documentation

**I will NOT make any changes until you explicitly approve.** This document serves as a roadmap for future improvements.

---

## 13. Deploying to Production

### **Prerequisites**

- Node.js 20+ installed on server (or use Docker)
- PostgreSQL 12+ database
- Environment variables configured
- Domain/SSL certificate (for HTTPS)

### **Build Process**

1. **Install Dependencies**:
   ```bash
   npm ci --only=production
   ```

2. **Generate Prisma Client**:
   ```bash
   npm run prisma:generate
   ```

3. **Build TypeScript**:
   ```bash
   npm run build
   ```
   This compiles TypeScript to JavaScript in the `dist/` directory.

### **Database Migrations**

**Development** (creates migration files):
```bash
npm run prisma:migrate
# Or: npx prisma migrate dev --name migration_name
```

**Production** (applies pending migrations):
```bash
# Generate Prisma Client first
npm run prisma:generate

# Deploy migrations (non-interactive, safe for production)
npx prisma migrate deploy
```

**Important**: 
- ⚠️ **Never run `prisma migrate dev` in production** - use `migrate deploy`
- ✅ Always test migrations on staging first
- ✅ Review migration files before deploying
- ✅ Backup database before running migrations

### **Starting the Application**

**Option 1: Direct Node.js** (Recommended for production)
```bash
# Set NODE_ENV to production
export NODE_ENV=production

# Start the application
npm run start:prod
# Or: node dist/index.js
```

**Option 2: Using PM2** (Process manager)
```bash
# Install PM2 globally
npm install -g pm2

# Start application
pm2 start dist/index.js --name eventos-backend

# Save PM2 configuration
pm2 save
pm2 startup
```

**Option 3: Using Docker** (Containerized)
```bash
# Build and start with docker-compose
docker-compose up -d

# Or build Docker image separately
docker build -t eventos-backend .
docker run -d \
  --name eventos-backend \
  -p 3000:3000 \
  --env-file .env \
  eventos-backend
```

### **Required Environment Variables**

The following environment variables **MUST** be set on the production server:

#### **Required (Application will fail to start if missing)**:
```bash
DATABASE_URL=postgresql://user:password@host:5432/eventos_db?schema=public
JWT_ACCESS_SECRET=your-super-secret-access-token-key-min-32-chars
JWT_REFRESH_SECRET=your-super-secret-refresh-token-key-min-32-chars
```

#### **Recommended (Has defaults but should be set)**:
```bash
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://your-frontend-domain.com
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

#### **Optional (For payment functionality)**:
```bash
STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
RAZORPAY_KEY_ID=rzp_live_your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

### **Production Checklist**

Before deploying, ensure:

- [ ] All environment variables are set
- [ ] Database migrations have been run
- [ ] Prisma Client has been generated
- [ ] TypeScript has been compiled (`npm run build`)
- [ ] Health check endpoint is accessible (`/health`)
- [ ] CORS is configured for production frontend URL
- [ ] JWT secrets are at least 32 characters
- [ ] Database connection is working
- [ ] Rate limiting is configured
- [ ] Error logging is working
- [ ] HTTPS/SSL is configured (via reverse proxy like Nginx)

### **Post-Deployment Verification**

1. **Health Check**:
   ```bash
   curl https://your-api-domain.com/health
   ```

2. **Test Authentication**:
   ```bash
   curl -X POST https://your-api-domain.com/api/v1/auth/signup \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com","password":"test123"}'
   ```

3. **Check Logs**:
   ```bash
   # If using PM2
   pm2 logs eventos-backend
   
   # If using Docker
   docker logs eventos-backend
   ```

### **Docker Deployment**

The project includes:
- `Dockerfile` - Multi-stage build for optimized production image
- `docker-compose.yml` - Complete stack with PostgreSQL

**Quick Start with Docker**:
```bash
# Create .env file with all required variables
cp .env.example .env
# Edit .env with production values

# Start services
docker-compose up -d

# Run migrations
docker-compose exec backend npx prisma migrate deploy

# Check logs
docker-compose logs -f backend
```

**Docker Image Features**:
- Multi-stage build (smaller final image)
- Non-root user for security
- Health checks configured
- Production optimizations

### **Reverse Proxy Setup (Nginx Example)**

For production, use Nginx as a reverse proxy:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### **Monitoring & Maintenance**

- **Health Checks**: Monitor `/health` endpoint
- **Logs**: Set up log aggregation (CloudWatch, Datadog, etc.)
- **Errors**: Integrate error tracking (Sentry, Rollbar)
- **Metrics**: Monitor API response times, error rates
- **Database**: Regular backups, connection pool monitoring
- **Updates**: Keep dependencies updated, security patches applied

### **Rollback Procedure**

If deployment fails:

1. **Stop new version**:
   ```bash
   pm2 stop eventos-backend
   # Or: docker-compose down
   ```

2. **Restore previous version**:
   ```bash
   git checkout <previous-commit>
   npm ci
   npm run build
   npm run start:prod
   ```

3. **Database rollback** (if needed):
   ```bash
   # Restore from backup
   # Or revert specific migration (if supported)
   ```

---

**Status:** ✅ Analysis Complete | 📋 Plan Ready | 🚀 Production Ready

