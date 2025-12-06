# EVENTOS App - Functional Widget Implementation Summary

**Date:** Generated during comprehensive functional refactoring  
**Status:** Infrastructure Complete, Screen Updates In Progress

---

## ✅ Completed Infrastructure

### 1. **CartRepository** (`lib/features/cart/data/cart_repository.dart`)
- ✅ Singleton pattern with `ChangeNotifier`
- ✅ Methods: `addItem`, `removeItem`, `updateQuantity`, `clearCart`
- ✅ Computed: `itemCount`, `subtotal`, `serviceFee`, `taxes`, `total`
- ✅ Ready to use across the app

### 2. **CartItem Model** (`lib/features/cart/domain/models/cart_item.dart`)
- ✅ Proper model with JSON serialization
- ✅ Fields: `listingId`, `title`, `subtitle`, `imageUrl`, `pricePerDay`, `days`, `quantity`

### 3. **SearchBarWidget** (`lib/widgets/search_bar_widget.dart`)
- ✅ Debounced search (default 500ms)
- ✅ Optional cart icon with dynamic badge count
- ✅ Reusable across all screens
- ✅ Customizable colors and styling

### 4. **Existing Infrastructure** (Already in place)
- ✅ `ListingsRepository` - Fetches listings from backend
- ✅ `ListingsList` widget - Displays listings with loading/error states
- ✅ `ListingCard` widget - Reusable card component
- ✅ `BookingRepository` - Handles bookings
- ✅ `AuthRepository` - Handles authentication (already wired)

---

## 📋 Implementation Patterns

### Pattern 1: Connect Search Bar

```dart
// In your screen's State class:
final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';

// In build method:
SearchBarWidget(
  hintText: 'Search BBQ grill, DJ, tents...',
  showCartIcon: true,
  cartItemCount: CartRepository().itemCount,
  onCartTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CartScreen()),
  ),
  onSearch: (query) {
    setState(() => _searchQuery = query);
    // Trigger listings reload with search query
  },
)
```

### Pattern 2: Display Real Listings

```dart
// Replace hardcoded lists with:
ListingsList(
  filters: {
    'category': 'package',  // or 'decor', 'rentals', etc.
    if (_searchQuery.isNotEmpty) 'query': _searchQuery,
    // Add other filters as needed
  },
  horizontal: true,  // or false for grid
  itemLimit: 10,  // Optional limit
  height: 260,  // For horizontal lists
)
```

### Pattern 3: Wire "Add to Cart" Button

```dart
// In ListingCard or similar widget:
ElevatedButton(
  onPressed: () {
    final cartRepo = CartRepository();
    cartRepo.addItem(
      listingId: listing.id,
      title: listing.title,
      subtitle: listing.category,
      imageUrl: listing.imageUrl ?? '',
      pricePerDay: listing.price ?? 0.0,
      days: 1,
      quantity: 1,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  },
  child: const Text('Add to Cart'),
)
```

### Pattern 4: Update Cart Screen

```dart
class CartScreenContent extends StatefulWidget {
  const CartScreenContent({super.key});

  @override
  State<CartScreenContent> createState() => _CartScreenContentState();
}

class _CartScreenContentState extends State<CartScreenContent> {
  final CartRepository _cartRepo = CartRepository();

  @override
  void initState() {
    super.initState();
    _cartRepo.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartRepo.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {}); // Rebuild when cart changes
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartRepo.items;
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CartItemCard(
          item: item,
          onDecrement: () => _cartRepo.updateQuantity(
            item.listingId,
            item.days,
            item.quantity - 1,
          ),
          onIncrement: () => _cartRepo.updateQuantity(
            item.listingId,
            item.days,
            item.quantity + 1,
          ),
          onDelete: () => _cartRepo.removeItem(item.listingId, item.days),
        );
      },
    );
  }
}
```

### Pattern 5: Wire "View All" Navigation

```dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackagesScreen(), // or DecorScreen, RentalsScreen
      ),
    );
  },
  child: Text('VIEW ALL', style: AppTheme.viewAllText),
)
```

### Pattern 6: Apply Filter Chips

```dart
// In screen state:
String? _selectedCategory;
String? _selectedTheme;

// Filter chips:
_FilterChip(
  label: 'Wedding',
  isSelected: _selectedCategory == 'wedding',
  onTap: () {
    setState(() {
      _selectedCategory = _selectedCategory == 'wedding' ? null : 'wedding';
    });
    // Reload listings with filter
  },
)

// In ListingsList:
ListingsList(
  filters: {
    if (_selectedCategory != null) 'category': _selectedCategory,
    if (_selectedTheme != null) 'theme': _selectedTheme,
  },
)
```

---

## 🔧 Remaining Implementation Tasks by Screen

### **Home Screen** (`lib/screens/home_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ (Pattern 1) Replace static search bar with `SearchBarWidget`
2. ✅ (Pattern 2) Replace hardcoded `PopularPackagesSection` with `ListingsList`
3. ✅ (Pattern 2) Replace hardcoded `RecommendedSection` with `ListingsList`
4. ✅ (Pattern 5) Wire "VIEW ALL" links to navigate to appropriate screens
5. ✅ (Pattern 3) Wire "Book Now" buttons to navigate to detail screen
6. ✅ (Pattern 3) Wire "Add to Cart" buttons
7. ⚠️ Wire filter chips ("Event date", "City / pin code") - Requires date/location pickers (can be TODO for now)

**Files to modify:**
- `lib/screens/home_screen.dart`

---

### **Decor Screen** (`lib/screens/decor_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ (Pattern 1) Replace static search bar with `SearchBarWidget`
2. ✅ (Pattern 2) Replace hardcoded `_DecorGrid` with `ListingsList`
3. ✅ (Pattern 2) Replace hardcoded `_RecommendedSection` with `ListingsList`
4. ✅ (Pattern 6) Wire filter chips to actually filter listings
5. ✅ (Pattern 3) Wire "Add to Cart" buttons

**Files to modify:**
- `lib/screens/decor_screen.dart`

---

### **Rentals Screen** (`lib/screens/rentals_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ (Pattern 1) Replace static search bar with `SearchBarWidget`
2. ✅ (Pattern 2) Replace hardcoded `_RentalsGrid` with `ListingsList`
3. ✅ (Pattern 2) Replace hardcoded `_RecommendedSection` with `ListingsList`
4. ✅ (Pattern 6) Wire filter chips
5. ✅ (Pattern 3) Wire "Add to Cart" buttons

**Files to modify:**
- `lib/screens/rentals_screen.dart`

---

### **Event Screen** (`lib/screens/event_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ (Pattern 1) Replace static search bar with `SearchBarWidget`
2. ✅ (Pattern 5) Wire "VIEW ALL" for "Popular Decor" → Navigate to `DecorScreen`
3. ✅ (Pattern 5) Wire "VIEW ALL" for "Popular Rentals" → Navigate to `RentalsScreen`
4. ✅ (Pattern 2) Replace hardcoded popular items with `ListingsList`
5. ⚠️ Wire "Request Design" buttons (Can be TODO - may need custom form screen)

**Files to modify:**
- `lib/screens/event_screen.dart`

---

### **Cart Screen** (`lib/screens/cart_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ (Pattern 4) Replace hardcoded `_items` list with `CartRepository().items`
2. ✅ Listen to `CartRepository` changes using `addListener`
3. ✅ Update `subtotal`, `serviceFee`, `taxes`, `total` to use `CartRepository` getters
4. ✅ Wire "Proceed to Checkout" button (Navigate to checkout/booking screen - can be placeholder for now)
5. ⚠️ Wire "Apply promo code" (TODO - needs backend endpoint)

**Files to modify:**
- `lib/screens/cart_screen.dart`
- Remove local `CartItem` class, use `lib/features/cart/domain/models/cart_item.dart` instead

---

### **Package Details Screen** (`lib/screens/package_details_screen.dart`)

**Status:** Partially complete (booking works, needs cart integration)

**Tasks:**
1. ✅ Already has listingId support and fetches from repository (per summary)
2. ✅ (Pattern 3) Wire "Add to Cart" button if present
3. ✅ "Order Now" button already wired to booking ✅

**Files to modify:**
- `lib/screens/package_details_screen.dart` (minor updates if needed)

---

### **Profile Screen** (`lib/screens/profile_screen.dart`)

**Status:** Needs updates

**Tasks:**
1. ✅ Fetch user profile from backend (`GET /auth/me` or similar)
   - Replace hardcoded name, email, phone, location
2. ✅ Fetch bookings for "Upcoming Events" from `BookingRepository.getMyBookings()`
   - Filter by upcoming dates
3. ✅ Calculate stats from real data:
   - Events booked: Count from bookings
   - Events hosted: Count from bookings (or separate endpoint)
   - Favorites: Count from favorites (or TODO if endpoint missing)
4. ⚠️ Wire "Edit Profile" button (TODO - needs edit screen + backend endpoint)
5. ⚠️ Wire "Payment Methods" (TODO - needs screen + backend)
6. ⚠️ Wire "Notifications" (TODO - needs screen + backend)
7. ⚠️ Save preferences chips to backend (TODO - needs endpoint)
8. ✅ Logout already wired ✅

**Files to modify:**
- `lib/screens/profile_screen.dart`

---

### **AI Planner Screen** (`lib/screens/ai_planner_screen.dart`)

**Status:** ✅ Already Complete

**Tasks:**
- ✅ Form submission wired to backend
- ✅ Loading/error states handled
- ⚠️ "View matching packages" button has TODO comment - can wire to filtered listings

---

### **ListingCard Widget** (`lib/widgets/listing_card.dart`)

**Status:** Needs minor update

**Tasks:**
1. ✅ Add optional `onAddToCart` callback parameter
2. ✅ Wire "Add to Cart" button if callback provided

**Files to modify:**
- `lib/widgets/listing_card.dart`

---

## 🚀 Quick Start Guide

### Step 1: Update Cart Screen
1. Import `CartRepository` and `CartItem` model
2. Replace local `_items` list with `CartRepository().items`
3. Add listener to rebuild on cart changes
4. Update all calculations to use repository getters

### Step 2: Update Home Screen
1. Replace search bar with `SearchBarWidget`
2. Replace hardcoded sections with `ListingsList` widgets
3. Wire "VIEW ALL" links
4. Wire "Add to Cart" buttons

### Step 3: Update Decor/Rentals Screens
1. Similar to Home screen
2. Apply category filters
3. Wire filter chips

### Step 4: Update Profile Screen
1. Fetch user data in `initState`
2. Display real data
3. Fetch bookings for upcoming events

---

## 📝 Backend Endpoints Required (TODOs)

If endpoints are missing, add clear TODO comments:

1. **User Profile:** `GET /auth/me` or `GET /users/me`
   - Returns: `{ name, email, phone, location, ... }`

2. **Cart Sync:** `GET /cart`, `POST /cart`, `PUT /cart/:id`, `DELETE /cart/:id`
   - Currently using in-memory cart, can sync later

3. **User Preferences:** `GET /users/preferences`, `PUT /users/preferences`
   - For saving event preferences

4. **Promo Codes:** `POST /promo-codes/validate`
   - For applying discount codes

5. **Notifications:** `GET /notifications`
   - For notification list

6. **Payment Methods:** `GET /payment-methods`
   - For saved payment methods

---

## ✅ Checklist

- [x] CartRepository created
- [x] CartItem model created
- [x] SearchBarWidget created
- [x] Documentation created
- [ ] Home screen updated
- [ ] Decor screen updated
- [ ] Rentals screen updated
- [ ] Event screen updated
- [ ] Cart screen updated
- [ ] Profile screen updated
- [ ] ListingCard widget updated
- [ ] All "Add to Cart" buttons wired
- [ ] All "View All" links wired
- [ ] Search bars functional
- [ ] Filter chips functional

---

## 🎯 Priority Order

1. **High Priority:**
   - Cart screen (users can see their cart)
   - Home screen (main entry point)
   - "Add to Cart" buttons (core functionality)

2. **Medium Priority:**
   - Decor/Rentals screens (browsing)
   - Search functionality
   - Filter chips

3. **Low Priority:**
   - Profile screen enhancements
   - Promo codes
   - Advanced filters

---

**Note:** All infrastructure is in place. The remaining work is primarily updating UI screens to use the existing repositories and widgets. Follow the patterns above for consistent implementation.

