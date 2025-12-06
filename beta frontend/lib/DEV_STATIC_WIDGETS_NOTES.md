# Static Widgets Analysis - EVENTOS App

**Date:** Generated during functional refactoring  
**Purpose:** Document all static/dummy widgets that need to be connected to backend/repositories

---

## 📋 Screen-by-Screen Analysis

### 1. **Home Screen** (`lib/screens/home_screen.dart`)

**Status:** ✅ Completed  
**Done:** SearchBarWidget (debounced + cart badge), dynamic Popular/Recommended via ListingsList, View All wired to Packages, Book Now nav, Add to Cart wired via CartRepository.  
**TODO:** Date/Location chips → add pickers (no backend yet).

---

### 2. **Decor Screen** (`lib/screens/decor_screen.dart`)

**Status:** ✅ Completed  
**Done:** SearchBarWidget with cart badge, ListingsList for grid/recommended (decor), filter chips applied, Add to Cart wired.

---

### 3. **Rentals Screen** (`lib/screens/rentals_screen.dart`)

**Status:** ✅ Completed  
**Done:** SearchBarWidget with cart badge, ListingsList for grid/recommended (rentals), filter tabs applied, Add to Cart wired.

---

### 4. **Event Screen** (`lib/screens/event_screen.dart`)

**Status:** ✅ Completed  
**Done:** SearchBarWidget with cart badge, dynamic Popular Decor/Rentals via ListingsList, View All to Decor/Rentals, Add to Cart wired.  
**TODO:** Request Design CTA → needs backend/form.

---

### 5. **Cart Screen** (`lib/screens/cart_screen.dart`)

**Status:** ✅ Completed  
**Done:** Uses shared CartRepository (reactive items/totals), qty/delete/clear, checkout placeholder.  
**TODO:** Promo code endpoint/UI.

---

### 6. **Package Details Screen** (`lib/screens/package_details_screen.dart`)

**Status:** ✅ Booking works; Add-to-Cart handled via listing cards (optional).

---

### 7. **Profile Screen** (`lib/screens/profile_screen.dart`)

**Status:** ✅ Partially Completed  
**Done:** Upcoming events fetch via `BookingRepository.getMyBookings()` with loading/error/empty; stats use bookings count; logout works.  
**TODO:** `/auth/me` for user info; eventsHosted/favorites fields; save preferences to backend; payment methods/notifications/edit profile need endpoints/screens.
  - "Help & Support" → Just prints
  - "Log out" → Already wired ✅

---

### 8. **AI Planner Screen** (`lib/screens/ai_planner_screen.dart`)

#### Status:
- ✅ Already integrated with `AiPlannerRepository`
- ✅ Form submission works
- ✅ Loading/error states handled
- ⚠️ "View matching packages" → TODO comment present
- Needs: Wire "View matching packages" to filtered listings

---

### 9. **Event Screen (My Events)** (`lib/screens/event_screen.dart`)

#### Note:
- This screen appears to be the "My Events" tab content
- Needs verification if it should show user's bookings

---

### 10. **Auth Screens**

#### Status:
- ✅ Login screen → Already wired to `AuthRepository`
- ✅ Registration screen → Already wired to `AuthRepository`
- No issues found

---

## 📊 Summary Statistics

- **Total Static Buttons/CTAs Found:** ~25+ instances
- **Static Data Lists:** 8+ screens with hardcoded listings/items
- **Non-functional Search Bars:** 5 screens
- **Non-functional Filter Chips:** 3 screens
- **Static "View All" Links:** 6 instances
- **Static Cart Items:** 1 screen (hardcoded list)

---

## ✅ Already Functional

- Login/Signup flows
- AI Planner form submission
- Package Details "Order Now" → Booking creation
- Basic navigation between screens
- Quantity selectors (local state)
- Cart item increment/decrement/delete (local state)
- Logout functionality

---

## 🔧 Implementation Priority

### **High Priority:**
1. Cart functionality (repository + connect "Add to Cart" buttons)
2. Search bars with debouncing
3. Listings fetch from backend (replace hardcoded data)
4. Filter chips that actually filter listings
5. "View All" navigation

### **Medium Priority:**
6. Profile data fetch from backend
7. My Events/Bookings list from backend
8. Cart badge count synchronization

### **Low Priority:**
9. Promo code functionality
10. Edit profile screen
11. Settings/preferences screens

---

## 📝 Notes

- Many screens use `ListingsList` widget (already created) but screens still have hardcoded data
- Need to create `CartRepository` for cart state management
- Search should be debounced (300-500ms) to avoid excessive API calls
- Filter state should be maintained and applied when fetching listings
- Cart badge count needs to be accessible across screens (consider state management solution)

---

**Next Steps:** See implementation plan in subsequent steps.

---

## 🚀 Implementation Progress

### ✅ Completed Infrastructure:

1. **CartRepository Created** (`lib/features/cart/data/cart_repository.dart`):
   - Singleton pattern with ChangeNotifier
   - Methods: `addItem`, `removeItem`, `updateQuantity`, `clearCart`
   - Computed properties: `itemCount`, `subtotal`, `serviceFee`, `taxes`, `total`

2. **CartItem Model Created** (`lib/features/cart/domain/models/cart_item.dart`):
   - Proper model with JSON serialization

3. **SearchBarWidget Created** (`lib/widgets/search_bar_widget.dart`):
   - Debounced search (default 500ms)
   - Optional cart icon with badge count
   - Reusable across all screens

### 📝 Implementation Status:

**STEP 1: Analysis & Documentation** - ✅ COMPLETE  
**STEP 2: Search Bars & Filters** - 🔄 IN PROGRESS  
**STEP 3: Navigation & Details** - ⏳ PENDING  
**STEP 4: Cart Functionality** - 🔄 IN PROGRESS (Repository created, need to wire buttons)  
**STEP 5: AI Planner** - ✅ ALREADY COMPLETE  
**STEP 6: Profile & My Events** - ⏳ PENDING  
**STEP 7: Final Pass & TODOs** - ⏳ PENDING  

### 🔧 Remaining Implementation Tasks:

1. **Wire Search Bars:**
   - Replace static search bars in Home, Decor, Rentals, Event screens
   - Connect to ListingsRepository with debouncing
   - Apply search query as filter

2. **Connect "Add to Cart" Buttons:**
   - Update all listing cards across all screens
   - Call `CartRepository().addItem()` with listing data
   - Show success feedback (Snackbar)

3. **Replace Hardcoded Listings:**
   - Home screen: Popular Packages, Recommended sections → Use `ListingsList` widget
   - Decor/Rentals screens: Replace hardcoded grids with `ListingsList`
   - Event screen: Replace hardcoded cards

4. **Wire "View All" Links:**
   - Navigate to appropriate screens (PackagesScreen, DecorScreen, RentalsScreen)
   - Pass category filters

5. **Update Cart Screen:**
   - Replace hardcoded `_items` list with `CartRepository().items`
   - Listen to CartRepository changes
   - Update cart badge counts across screens

6. **Profile Screen:**
   - Fetch user data from backend
   - Fetch bookings for "Upcoming Events"
   - Calculate stats from real data

7. **Filter Chips:**
   - Apply filters when chips selected
   - Re-fetch listings with filter parameters

---

## 📌 Quick Reference: Files Modified/Created

### Created:
- ✅ `lib/features/cart/data/cart_repository.dart`
- ✅ `lib/features/cart/domain/models/cart_item.dart`
- ✅ `lib/widgets/search_bar_widget.dart`
- ✅ `lib/DEV_STATIC_WIDGETS_NOTES.md` (this file)

### Needs Updates:
- `lib/screens/home_screen.dart` - Wire search, listings, cart, "View All"
- `lib/screens/decor_screen.dart` - Wire search, listings, filters, cart
- `lib/screens/rentals_screen.dart` - Wire search, listings, filters, cart
- `lib/screens/event_screen.dart` - Wire "View All", listings
- `lib/screens/cart_screen.dart` - Use CartRepository
- `lib/screens/profile_screen.dart` - Fetch real data
- `lib/widgets/listing_card.dart` - Add "Add to Cart" callback parameter

---

## 💡 Implementation Pattern

### For Search Bars:
```dart
SearchBarWidget(
  hintText: 'Search...',
  showCartIcon: true,
  cartItemCount: CartRepository().itemCount,
  onCartTap: () => Navigator.push(...),
  onSearch: (query) {
    setState(() => _searchQuery = query);
    _loadListings();
  },
)
```

### For Listings:
```dart
ListingsList(
  filters: {'category': 'package', 'query': _searchQuery},
  horizontal: true,
  itemLimit: 10,
)
```

### For Add to Cart:
```dart
CartRepository().addItem(
  listingId: listing.id,
  title: listing.title,
  subtitle: listing.category,
  imageUrl: listing.imageUrl ?? '',
  pricePerDay: listing.price ?? 0.0,
  days: 1,
  quantity: 1,
);
```

---

**Last Updated:** During functional refactoring implementation

