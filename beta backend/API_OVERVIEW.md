# API Overview

**EVENTOS Backend API Documentation**

This document provides an overview of the API endpoints, with special focus on Payments and AI Planner modules.

---

## Base URL

- **Development**: `http://localhost:3000`
- **Production**: (configured via environment)

## API Versioning

All endpoints are available under:
- `/api/v1/*` (current version)
- `/api/*` (legacy, backward compatibility)

---

## Authentication

Most endpoints require JWT authentication via Bearer token:

```
Authorization: Bearer <access_token>
```

---

## Payments Module

### Status: **Placeholder (Stubbed)**

The Payments module is currently a production-ready placeholder that simulates payment processing. It's structured to easily integrate with real payment gateways (Stripe, Razorpay) in the future.

**What's Stubbed:**
- Payment intent creation returns mock payment IDs
- Webhook processing simulates success/failure
- No actual money is processed

**What's Real:**
- Database records are created/updated
- Booking status is updated
- Payment status tracking
- Structured service methods ready for gateway integration

### Endpoints

#### 1. Create Payment Intent

**Endpoint**: `POST /api/v1/payments/create`

**Authentication**: Required

**Request Body**:
```json
{
  "bookingId": "uuid-string",
  "amount": 50000,
  "currency": "USD"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "paymentId": "payment-uuid",
    "paymentIntentId": "pi_mock_1234567890_abc123",
    "status": "PENDING",
    "amount": 50000,
    "currency": "USD"
  }
}
```

**Error Responses**:
- `404`: Booking not found
- `400`: Invalid booking status or payment already completed
- `401`: Unauthorized

---

#### 2. Payment Webhook

**Endpoint**: `POST /api/v1/payments/webhook`

**Authentication**: Not required (secured via webhook secret in production)

**Request Body** (Mock):
```json
{
  "type": "payment_intent.succeeded",
  "provider": "STRIPE",
  "data": {
    "object": {
      "id": "pi_mock_1234567890_abc123"
    }
  },
  "paymentIntentId": "pi_mock_1234567890_abc123"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Webhook processed",
  "received": true
}
```

**Webhook Events Supported**:
- `payment_intent.succeeded` / `payment.captured` → Updates payment and booking to SUCCESS/PAID
- `payment_intent.payment_failed` / `payment.failed` → Updates payment to FAILED

**TODO**: 
- Verify webhook signatures in production
- Handle refund events
- Add idempotency checks

---

## AI Planner Module

### Status: **Placeholder (Stubbed)**

The AI Planner module provides event planning suggestions using a structured mock implementation. It's ready for LLM integration (OpenAI, Anthropic) in the future.

**What's Stubbed:**
- Suggestions are generated from templates/rules
- No actual AI/LLM calls
- Responses are deterministic based on input

**What's Real:**
- Structured response format
- Budget calculations
- Category-based recommendations
- Service methods ready for LLM integration

### Endpoints

#### 1. Suggest Event Plan

**Endpoint**: `POST /api/v1/ai-planner/suggest`

**Authentication**: Not required

**Request Body**:
```json
{
  "eventType": "wedding",
  "budget": 10000,
  "guests": 100,
  "location": "outdoor",
  "date": "2024-06-15",
  "vibe": "elegant",
  "theme": "rustic"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "theme": "rustic elegant",
    "suggestedDecor": [
      {
        "name": "rustic themed centerpieces",
        "category": "decor",
        "estimatedCost": 1500,
        "description": "Elegant rustic themed centerpieces for tables"
      },
      {
        "name": "String lights and ambiance lighting",
        "category": "decor",
        "estimatedCost": 1000,
        "description": "Warm lighting to create the perfect atmosphere"
      },
      {
        "name": "Photo backdrop and props",
        "category": "decor",
        "estimatedCost": 500,
        "description": "Custom backdrop matching your theme"
      }
    ],
    "suggestedRentals": [
      {
        "name": "Tables and chairs for 100 guests",
        "category": "furniture",
        "estimatedCost": 2000,
        "description": "Seating arrangement for 100 guests"
      },
      {
        "name": "Sound system and microphone",
        "category": "equipment",
        "estimatedCost": 1000,
        "description": "Professional audio equipment"
      },
      {
        "name": "Table linens and tableware",
        "category": "furniture",
        "estimatedCost": 800,
        "description": "Elegant table settings"
      }
    ],
    "suggestedStaff": [
      {
        "name": "Event coordinator",
        "category": "staff",
        "estimatedCost": 1200,
        "description": "Professional event coordinator to manage the day"
      },
      {
        "name": "Photographer",
        "category": "staff",
        "estimatedCost": 1500,
        "description": "Professional photographer for event coverage"
      },
      {
        "name": "Catering staff",
        "category": "staff",
        "estimatedCost": 500,
        "description": "Service staff for food and beverage"
      }
    ],
    "budgetBreakdown": [
      {
        "category": "Decor",
        "amount": 3000,
        "percentage": 30
      },
      {
        "category": "Rentals",
        "amount": 3800,
        "percentage": 38
      },
      {
        "category": "Staff",
        "amount": 3200,
        "percentage": 32
      }
    ],
    "totalEstimatedCost": 10000,
    "recommendations": [
      "Book your wedding venue at least 2 weeks in advance for best availability",
      "Consider booking a backup photographer in case of emergencies",
      "For 100 guests, plan for approximately 120 servings to account for seconds",
      "The elegant vibe works well with rustic theme - consider coordinating colors"
    ]
  }
}
```

**Error Responses**:
- `400`: Validation error (missing required fields, invalid types)

**TODO**:
- Integrate with OpenAI GPT-4 or Anthropic Claude
- Add context-aware suggestions based on location/date
- Add budget optimization algorithms
- Add real-time availability checking
- Add personalized recommendations based on user history

---

## Other API Endpoints

### Authentication
- `POST /api/v1/auth/signup` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token

### Users
- `GET /api/v1/users/me` - Get current user profile (Auth required)

### Listings
- `GET /api/v1/listings` - List all listings (Public)
- `GET /api/v1/listings/:id` - Get listing by ID (Public)
- `POST /api/v1/listings` - Create listing (Auth + OWNER/ADMIN)
- `PATCH /api/v1/listings/:id` - Update listing (Auth + OWNER/ADMIN)
- `DELETE /api/v1/listings/:id` - Delete listing (Auth + OWNER/ADMIN)

### Bookings
- `POST /api/v1/bookings` - Create booking (Auth required)
- `GET /api/v1/bookings/me` - Get user's bookings (Auth required)
- `GET /api/v1/bookings/owner` - Get owner's bookings (Auth + OWNER/ADMIN)

---

## Error Response Format

All errors follow this consistent format:

```json
{
  "success": false,
  "message": "Error message",
  "code": "ERROR_CODE",
  "details": null
}
```

**Common Error Codes**:
- `VALIDATION_ERROR` - Request validation failed
- `UNAUTHORIZED` - Missing or invalid authentication
- `FORBIDDEN` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `DUPLICATE_ENTRY` - Resource already exists
- `INTERNAL_ERROR` - Server error

---

## Rate Limiting

- **General API**: 100 requests per 15 minutes per IP
- **Auth endpoints**: 5 requests per 15 minutes per IP
- **Payment endpoints**: 10 requests per 15 minutes per IP

---

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

---

## Example Requests

### Create Payment Intent

```bash
curl -X POST http://localhost:3000/api/v1/payments/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "bookingId": "123e4567-e89b-12d3-a456-426614174000",
    "amount": 50000,
    "currency": "USD"
  }'
```

### Suggest Event Plan

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

---

## Future Integrations

### Payments
- [ ] Stripe PaymentIntents API integration
- [ ] Razorpay Orders API integration
- [ ] Payment method validation
- [ ] Currency conversion support
- [ ] Refund processing
- [ ] Webhook signature verification

### AI Planner
- [ ] OpenAI GPT-4 integration
- [ ] Anthropic Claude integration
- [ ] Context-aware suggestions
- [ ] Budget optimization
- [ ] Real-time availability checking
- [ ] Personalized recommendations

---

**Last Updated**: 2024-12-04  
**API Version**: v1

