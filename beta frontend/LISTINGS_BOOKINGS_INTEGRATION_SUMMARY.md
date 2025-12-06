# Listings & Bookings Integration Summary

This document summarizes the listings and bookings integration with the backend API.

## What Was Created

### 1. Models

#### Listing Model (`lib/features/listings/domain/models/listing.dart`)
- Represents a service/item available for booking
- Fields: id, title, description, imageUrl, category, price, rating, etc.
- Methods: `fromJson()`, `toJson()`, `formattedPrice`

#### Booking Model (`lib/features/bookings/domain/models/booking.dart`)
- Represents a user's booking
- Fields: id, listingId, startDate, endDate, numberOfGuests, totalPrice, status, etc.
- Methods: `fromJson()`, `toJson()`

### 2. Repositories

#### ListingsRepository (`lib/features/listings/data/listings_repository.dart`)
- `getListings({filters})` → `List<Listing>`
  - Fetches all listings with optional filters (category, search, price range, etc.)
  - Supports pagination via filters (page, limit)
- `getListingDetail(id)` → `Listing`
  - Fetches a single listing by ID

#### BookingRepository (`lib/features/bookings/data/booking_repository.dart`)
- `createBooking(listingId, startDate, endDate?, numberOfGuests?, ...)` → `Booking`
  - Creates a new booking
- `getMyBookings()` → `List<Booking>`
  - Gets all bookings for the current user

### 3. Backend Endpoints Used

All endpoints use base URL from `api_config.dart`:
- Dev: `http://localhost:3000/api/v1`
- Prod: `https://api.eventos.xyz/api/v1`

#### Listings Endpoints:

1. **GET /listings**
   - Query parameters: category, search, minPrice, maxPrice, location, page, limit
   - Returns: Array of listings or `{ data: [...], listings: [...] }`

2. **GET /listings/:id**
   - Returns: Single listing object or `{ data: {...} }`

#### Booking Endpoints:

1. **POST /bookings**
   ```json
   Request: {
     "listingId": "123",
     "startDate": "2024-01-15T10:00:00Z",
     "endDate": "2024-01-15T18:00:00Z",
     "numberOfGuests": 50,
     "totalPrice": 25000
   }
   
   Response: {
     "success": true,
     "data": {
       "id": "booking_123",
       "listingId": "123",
       "status": "pending",
       ...
     }
   }
   ```

2. **GET /bookings/my**
   - Returns: Array of user's bookings or `{ data: [...], bookings: [...] }`

## Integration Status

### ✅ Completed

1. **Models Created**
   - Listing model with flexible JSON parsing
   - Booking model with date handling

2. **Repositories Created**
   - ListingsRepository with filtering support
   - BookingRepository with booking creation

3. **Reusable Components**
   - `ListingCard` widget for displaying listings

### 🔄 To Be Integrated

1. **Home Screen** (`lib/screens/home_screen.dart`)
   - Update `PopularPackagesSection` to fetch real listings
   - Add loading state while fetching
   - Add error state with retry option
   - Map categories to different sections

2. **Decor Screen** (`lib/screens/decor_screen.dart`)
   - Replace dummy grid with real listings filtered by category='decoration'
   - Add loading/error states

3. **Rentals Screen** (`lib/screens/rentals_screen.dart`)
   - Replace dummy grid with real listings filtered by category='rental'
   - Add loading/error states

4. **Package Details Screen** (`lib/screens/package_details_screen.dart`)
   - Accept `listingId` parameter
   - Fetch listing details on load
   - Wire "Book Now" button to `createBooking()`
   - Show booking success screen after booking

5. **Event Screen** (`lib/screens/event_screen.dart`)
   - Integrate with listings by category='package' or 'venue'

## Example Usage

### Fetching Listings

```dart
final listingsRepo = ListingsRepository();

// Get all listings
final listings = await listingsRepo.getListings();

// Get listings by category
final decorListings = await listingsRepo.getListings(
  filters: {'category': 'decoration'},
);

// Get listings with filters
final filteredListings = await listingsRepo.getListings(
  filters: {
    'category': 'rental',
    'minPrice': 1000,
    'maxPrice': 5000,
    'location': 'Mumbai',
  },
);
```

### Creating a Booking

```dart
final bookingRepo = BookingRepository();

try {
  final booking = await bookingRepo.createBooking(
    listingId: 'listing_123',
    startDate: DateTime.now().add(Duration(days: 7)),
    endDate: DateTime.now().add(Duration(days: 8)),
    numberOfGuests: 50,
    totalPrice: 25000.0,
  );
  
  // Navigate to booking success screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingSuccessScreen(booking: booking),
    ),
  );
} on AppApiException catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
}
```

### Loading & Error States

```dart
class ListingsSection extends StatefulWidget {
  @override
  _ListingsSectionState createState() => _ListingsSectionState();
}

class _ListingsSectionState extends State<ListingsSection> {
  final _repo = ListingsRepository();
  List<Listing> _listings = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final listings = await _repo.getListings();
      setState(() {
        _listings = listings;
        _loading = false;
      });
    } on AppApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        children: [
          Text('Error: $_error'),
          ElevatedButton(
            onPressed: _loadListings,
            child: Text('Retry'),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        return ListingCard(listing: _listings[index]);
      },
    );
  }
}
```

## TODO Items

### High Priority

- [ ] Update `PopularPackagesSection` in home_screen.dart to use real listings
- [ ] Add loading/error states to all listing sections
- [ ] Wire "Book Now" button in package_details_screen.dart
- [ ] Create BookingSuccessScreen or checkout placeholder

### Medium Priority

- [ ] Implement category filtering (map categories to screens)
- [ ] Add pagination for listings (infinite scroll or load more)
- [ ] Implement search functionality
- [ ] Add sorting options (price, rating, date)

### Low Priority

- [ ] Add favorite/bookmark functionality
- [ ] Implement listing image caching
- [ ] Add listing detail page with full information
- [ ] Implement booking cancellation

## Category Mapping

Suggested category mapping for screens:
- Home Screen → All categories (popular/recommended)
- Decor Screen → Category: 'decoration'
- Rentals Screen → Category: 'rental'
- Packages Screen → Category: 'package'
- Event Screen → Categories: 'venue', 'package'

## Error Handling

All repository methods throw `AppApiException` which should be caught in UI:

```dart
try {
  final listings = await listingsRepo.getListings();
} on AppApiException catch (e) {
  // Handle API errors (4xx, 5xx)
  showErrorSnackBar(e.message);
} catch (e) {
  // Handle unexpected errors
  showErrorSnackBar('An unexpected error occurred');
}
```

## Next Steps

1. Start with home screen integration
2. Then update decor/rentals screens
3. Wire up booking flow in package details
4. Test with real backend
5. Add pagination and filtering

