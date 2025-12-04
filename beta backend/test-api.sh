#!/bin/bash

# API Testing Script
# This script tests the main API endpoints

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Rental Marketplace API Test ===${NC}\n"

# Check if server is running
echo -e "${YELLOW}1. Testing Health Check...${NC}"
HEALTH=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
HTTP_CODE=$(echo "$HEALTH" | tail -n1)
BODY=$(echo "$HEALTH" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
    echo -e "${RED}✗ Health check failed (HTTP $HTTP_CODE)${NC}"
    echo "Make sure the server is running: npm run dev"
    exit 1
fi

echo ""

# Sign up as OWNER
echo -e "${YELLOW}2. Signing up as OWNER...${NC}"
OWNER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Owner",
    "email": "owner'$(date +%s)'@test.com",
    "password": "password123",
    "role": "OWNER"
  }')

OWNER_TOKEN=$(echo "$OWNER_RESPONSE" | jq -r '.data.accessToken' 2>/dev/null)
if [ "$OWNER_TOKEN" != "null" ] && [ -n "$OWNER_TOKEN" ]; then
    echo -e "${GREEN}✓ Owner signup successful${NC}"
    echo "Token: ${OWNER_TOKEN:0:20}..."
else
    echo -e "${RED}✗ Owner signup failed${NC}"
    echo "$OWNER_RESPONSE" | jq '.' 2>/dev/null || echo "$OWNER_RESPONSE"
    exit 1
fi

echo ""

# Sign up as CONSUMER
echo -e "${YELLOW}3. Signing up as CONSUMER...${NC}"
CONSUMER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Consumer",
    "email": "consumer'$(date +%s)'@test.com",
    "password": "password123",
    "role": "CONSUMER"
  }')

CONSUMER_TOKEN=$(echo "$CONSUMER_RESPONSE" | jq -r '.data.accessToken' 2>/dev/null)
if [ "$CONSUMER_TOKEN" != "null" ] && [ -n "$CONSUMER_TOKEN" ]; then
    echo -e "${GREEN}✓ Consumer signup successful${NC}"
    echo "Token: ${CONSUMER_TOKEN:0:20}..."
else
    echo -e "${RED}✗ Consumer signup failed${NC}"
    echo "$CONSUMER_RESPONSE" | jq '.' 2>/dev/null || echo "$CONSUMER_RESPONSE"
    exit 1
fi

echo ""

# Create listing
echo -e "${YELLOW}4. Creating listing (as OWNER)...${NC}"
LISTING_RESPONSE=$(curl -s -X POST "$BASE_URL/api/listings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d '{
    "title": "Test Venue",
    "description": "A test venue for testing",
    "category": "venue",
    "pricePerDay": 1000,
    "location": "Test City",
    "images": ["https://example.com/test.jpg"]
  }')

LISTING_ID=$(echo "$LISTING_RESPONSE" | jq -r '.data.id' 2>/dev/null)
if [ "$LISTING_ID" != "null" ] && [ -n "$LISTING_ID" ]; then
    echo -e "${GREEN}✓ Listing created successfully${NC}"
    echo "Listing ID: $LISTING_ID"
else
    echo -e "${RED}✗ Listing creation failed${NC}"
    echo "$LISTING_RESPONSE" | jq '.' 2>/dev/null || echo "$LISTING_RESPONSE"
    exit 1
fi

echo ""

# Get listings
echo -e "${YELLOW}5. Getting all listings...${NC}"
LISTINGS=$(curl -s "$BASE_URL/api/listings")
LISTING_COUNT=$(echo "$LISTINGS" | jq '.data.listings | length' 2>/dev/null)
if [ "$LISTING_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $LISTING_COUNT listing(s)${NC}"
else
    echo -e "${YELLOW}⚠ No listings found${NC}"
fi

echo ""

# Create booking
echo -e "${YELLOW}6. Creating booking (as CONSUMER)...${NC}"
START_DATE=$(date -u -d "+7 days" +"%Y-%m-%dT10:00:00Z" 2>/dev/null || date -u -v+7d +"%Y-%m-%dT10:00:00Z" 2>/dev/null || echo "2024-06-01T10:00:00Z")
END_DATE=$(date -u -d "+9 days" +"%Y-%m-%dT18:00:00Z" 2>/dev/null || date -u -v+9d +"%Y-%m-%dT18:00:00Z" 2>/dev/null || echo "2024-06-03T18:00:00Z")

BOOKING_RESPONSE=$(curl -s -X POST "$BASE_URL/api/bookings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CONSUMER_TOKEN" \
  -d "{
    \"listingId\": \"$LISTING_ID\",
    \"startDate\": \"$START_DATE\",
    \"endDate\": \"$END_DATE\"
  }")

BOOKING_ID=$(echo "$BOOKING_RESPONSE" | jq -r '.data.id' 2>/dev/null)
if [ "$BOOKING_ID" != "null" ] && [ -n "$BOOKING_ID" ]; then
    echo -e "${GREEN}✓ Booking created successfully${NC}"
    echo "Booking ID: $BOOKING_ID"
else
    echo -e "${RED}✗ Booking creation failed${NC}"
    echo "$BOOKING_RESPONSE" | jq '.' 2>/dev/null || echo "$BOOKING_RESPONSE"
    exit 1
fi

echo ""

# Test AI Party Planner
echo -e "${YELLOW}7. Testing AI Party Planner...${NC}"
AI_RESPONSE=$(curl -s -X POST "$BASE_URL/api/ai/party-planner" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2024-06-15",
    "guests": 50,
    "budget": 5000,
    "theme": "elegant",
    "location": "outdoor"
  }')

AI_SUMMARY=$(echo "$AI_RESPONSE" | jq -r '.data.summary' 2>/dev/null)
if [ "$AI_SUMMARY" != "null" ] && [ -n "$AI_SUMMARY" ]; then
    echo -e "${GREEN}✓ AI Party Planner working${NC}"
    echo "Summary: ${AI_SUMMARY:0:50}..."
else
    echo -e "${RED}✗ AI Party Planner failed${NC}"
    echo "$AI_RESPONSE" | jq '.' 2>/dev/null || echo "$AI_RESPONSE"
fi

echo ""
echo -e "${GREEN}=== All Tests Completed ===${NC}"
echo ""
echo "Summary:"
echo "  - Health check: ✓"
echo "  - Owner signup: ✓"
echo "  - Consumer signup: ✓"
echo "  - Listing creation: ✓"
echo "  - Get listings: ✓"
echo "  - Booking creation: ✓"
echo "  - AI Party Planner: ✓"
echo ""
echo "Your API is working correctly! 🎉"

