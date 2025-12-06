# AI Planner Integration Summary

## What Was Implemented

### ✅ Models Created

1. **AiPlannerRequest** (`lib/features/ai_planner/domain/models/ai_planner_request.dart`)
   - Fields: `eventType`, `date`, `time`, `location`, `guests`, `budget`, `theme`
   - Converts form data to JSON for API request

2. **AiPlan** (`lib/features/ai_planner/domain/models/ai_plan.dart`)
   - Fields: `theme`, `venue`, `eventDescription`, `decorSuggestions`, `rentalSuggestions`, `staffSuggestions`, `foodSuggestions`, `musicSuggestions`, `budgetBreakdown`, `recommendedCategories`
   - Flexible JSON parsing to handle different backend response formats

3. **BudgetBreakdown** (nested in AiPlan)
   - Fields: `totalBudget`, `decorBudget`, `rentalBudget`, `foodBudget`, `staffBudget`, `venueBudget`

### ✅ Repository Created

**AiPlannerRepository** (`lib/features/ai_planner/data/ai_planner_repository.dart`)
- Method: `generatePlan(AiPlannerRequest)` → `Future<AiPlan>`
- Calls `POST /api/v1/ai-planner/suggest`
- Handles errors and throws `AppApiException`

### ✅ Screen Updates

**AI Planner Screen** (`lib/screens/ai_planner_screen.dart`)
- ✅ Replaced fake `Future.delayed` with real API call
- ✅ Added loading state ("Thinking about your event…")
- ✅ Displays real plan data from backend
- ✅ Error handling with SnackBar and retry button
- ✅ Added "Powered by AI (placeholder)" note

## Backend Endpoint

**POST /api/v1/ai-planner/suggest**

### Request Body

```json
{
  "eventType": "Birthday",
  "date": "2024-01-15",
  "time": "18:00",
  "location": "Mumbai, India",
  "guests": "50-80 guests",
  "budget": "₹50,000 – ₹1,00,000",
  "theme": "Boho chic, fairy lights, terrace"
}
```

### Expected Response Format

The code handles multiple response formats:

**Format 1:**
```json
{
  "success": true,
  "data": {
    "theme": "Boho Chic",
    "venue": "Rooftop restaurant in Bandra",
    "eventDescription": "...",
    "decorSuggestions": ["Balloon arch", "Neon sign", "Fairy lights"],
    "rentalSuggestions": ["Tables", "Chairs", "Tents"],
    "staffSuggestions": ["DJ", "Photographer"],
    "foodSuggestions": ["Live BBQ", "Mocktail bar"],
    "musicSuggestions": ["DJ", "Curated playlist"],
    "budgetBreakdown": {
      "totalBudget": 75000,
      "decorBudget": 15000,
      "rentalBudget": 10000,
      "foodBudget": 30000,
      "staffBudget": 10000,
      "venueBudget": 10000
    },
    "recommendedCategories": ["Decor", "Rentals", "Talent & Staff"]
  }
}
```

**Format 2:**
```json
{
  "plan": {
    "theme": "...",
    "decor": ["..."],
    "rentals": ["..."],
    ...
  }
}
```

## Backend Fields Currently Used in UI

### Request Fields (Sent to Backend)

| Field | UI Source | Required | Notes |
|-------|-----------|----------|-------|
| `eventType` | Selected event type pill | ✅ Yes | "Birthday", "Wedding", "Corporate", etc. |
| `location` | Location text field | ✅ Yes | City/location string |
| `date` | Date text field | ❌ Optional | Event date |
| `time` | Time text field | ❌ Optional | Start time |
| `guests` | Guests text field | ❌ Optional | Can be range like "50-80 guests" |
| `budget` | Budget text field | ❌ Optional | Can be range like "₹50,000 – ₹1,00,000" |
| `theme` | Theme text field | ❌ Optional | Theme/vibe description |

### Response Fields (Displayed in UI)

| Field | UI Display | Notes |
|-------|------------|-------|
| `theme` | Bullet line with style icon | "Theme: {theme}" |
| `venue` | Bullet line with place icon | "Venue: {venue}" or falls back to location |
| `decorSuggestions` | Bullet line with palette icon | "Decor: {suggestions joined}" |
| `foodSuggestions` | Bullet line with restaurant icon | "Food: {suggestions joined}" |
| `musicSuggestions` | Bullet line with music icon | "Music: {suggestions joined}" |
| `rentalSuggestions` | Bullet line with chair icon | "Rentals: {suggestions joined}" |
| `staffSuggestions` | Bullet line with people icon | "Staff: {suggestions joined}" |
| `recommendedCategories` | Category chips | Displayed as chips below suggestions |
| `budgetBreakdown` | ⚠️ Not currently displayed | Available in model but not shown in UI |
| `eventDescription` | ⚠️ Not currently displayed | Available in model but not shown in UI |

## UI States

### 1. Empty State
- Shows when no plan has been generated
- Icon + "Your AI plan will appear here" message

### 2. Loading State
- Shows spinner + "Thinking about your event…" message
- Appears while API call is in progress

### 3. Error State
- Shows error icon + error message
- Includes "Retry" button
- Also shows SnackBar with error details

### 4. Success State
- Displays plan suggestions as bullet points
- Shows recommended categories as chips
- "View matching packages" button
- "Powered by AI (placeholder)" note at bottom

## Future Extension Points for Real LLM Integration

### 1. Enhanced Request Fields

**Current:**
- Basic form fields (eventType, location, date, etc.)

**Future Extensions:**
- `preferences`: User preferences (indoor/outdoor, formal/casual)
- `specialRequirements`: Accessibility needs, dietary restrictions
- `previousEvents`: Reference to past events user has booked
- `mood`: Emotional tone (elegant, fun, intimate, etc.)
- `colorScheme`: Preferred colors
- `venueType`: Specific venue preferences

### 2. Enhanced Response Fields

**Current:**
- Basic suggestions (decor, food, music, etc.)

**Future Extensions:**
- `timeline`: Detailed event timeline with hour-by-hour breakdown
- `vendorRecommendations`: Specific vendor/listing IDs to book
- `costEstimates`: More detailed cost breakdown per item
- `alternativeOptions`: Multiple plan variations (budget, premium, etc.)
- `weatherConsiderations`: Weather-based suggestions
- `seasonalSuggestions`: Season-appropriate recommendations
- `localInsights`: Location-specific tips and recommendations
- `sustainabilityOptions`: Eco-friendly alternatives
- `accessibilityFeatures`: Accessibility recommendations

### 3. UI Enhancements

**Budget Breakdown Display:**
- Currently available in model but not displayed
- Could show pie chart or breakdown list
- Allow user to adjust budget allocation

**Event Description:**
- Currently available but not displayed
- Could show full event description card
- Rich text formatting support

**Multiple Plan Options:**
- Show 2-3 plan variations
- Let user compare and choose
- "Generate Alternative" button

**Interactive Plan:**
- Allow editing of suggestions
- "Regenerate this section" buttons
- Save favorite plans

**Vendor Integration:**
- Direct links to book suggested vendors
- "Add to Cart" for suggested items
- Price comparison for suggestions

### 4. Advanced Features

**Conversational AI:**
- Multi-turn conversation to refine plan
- "Tell me more about..." interactions
- Context-aware follow-up questions

**Learning from User Behavior:**
- Track which suggestions users accept/reject
- Improve recommendations over time
- Personalization based on history

**Real-time Updates:**
- Streaming response as AI generates
- Progressive disclosure of suggestions
- Show thinking process

**Integration with Calendar:**
- Check availability for suggested dates
- Suggest alternative dates if conflicts
- Sync with user's calendar

**Social Features:**
- Share plans with friends/collaborators
- Collaborative plan editing
- Public plan templates

### 5. Backend Integration Points

**Current:**
- Single endpoint: `POST /ai-planner/suggest`

**Future Endpoints:**
- `POST /ai-planner/refine` - Refine existing plan
- `POST /ai-planner/regenerate-section` - Regenerate specific section
- `GET /ai-planner/saved-plans` - Get user's saved plans
- `POST /ai-planner/save` - Save a plan
- `POST /ai-planner/chat` - Conversational refinement
- `GET /ai-planner/templates` - Get plan templates by event type

## Testing Checklist

- [ ] Form validation (eventType + location required)
- [ ] Loading state shows during API call
- [ ] Success state displays all plan suggestions
- [ ] Error state shows with retry button
- [ ] SnackBar appears on error
- [ ] "Powered by AI" note is visible
- [ ] All suggestion types display correctly
- [ ] Recommended categories show as chips
- [ ] Handles missing/null fields gracefully
- [ ] Works with different backend response formats

## Example API Request/Response

**Request:**
```json
POST /api/v1/ai-planner/suggest
{
  "eventType": "Birthday",
  "location": "Mumbai, India",
  "guests": "50-80 guests",
  "budget": "₹50,000 – ₹1,00,000",
  "theme": "Boho chic, fairy lights, terrace"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "theme": "Boho Chic with Fairy Lights",
    "venue": "Rooftop restaurant in Bandra",
    "decorSuggestions": ["Balloon arch", "Neon sign", "Fairy lights", "Macrame decorations"],
    "rentalSuggestions": ["Rustic wooden tables", "Vintage chairs", "Fairy light strings"],
    "staffSuggestions": ["DJ", "Photographer", "Event coordinator"],
    "foodSuggestions": ["Live BBQ station", "Mocktail bar", "Dessert table"],
    "musicSuggestions": ["DJ with curated playlist", "Acoustic guitar for ambiance"],
    "recommendedCategories": ["Decor", "Rentals", "Talent & Staff", "Ready-to-book packages"],
    "budgetBreakdown": {
      "totalBudget": 75000,
      "decorBudget": 15000,
      "rentalBudget": 10000,
      "foodBudget": 30000,
      "staffBudget": 10000,
      "venueBudget": 10000
    }
  }
}
```

## Summary

✅ **Completed:**
- Models (AiPlannerRequest, AiPlan, BudgetBreakdown)
- Repository with API integration
- Screen updates with real data display
- Loading/error states
- "Powered by AI" note

🔄 **Ready for Enhancement:**
- Budget breakdown display
- Event description display
- Multiple plan options
- Conversational refinement
- Vendor integration

The infrastructure is complete and ready for real LLM integration. The current implementation works with placeholder/dummy AI endpoints and can easily be extended when real LLM services are integrated.

