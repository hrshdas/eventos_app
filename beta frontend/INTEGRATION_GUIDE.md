# Listings & Bookings Integration Guide

## What Was Created

### ✅ Models & Repositories

1. **Listing Model** (`lib/features/listings/domain/models/listing.dart`)
   - Complete model with flexible JSON parsing
   
2. **Booking Model** (`lib/features/bookings/domain/models/booking.dart`)
   - Complete booking model with date handling

3. **ListingsRepository** (`lib/features/listings/data/listings_repository.dart`)
   - `getListings({filters})` - Fetch listings with optional filters
   - `getListingDetail(id)` - Fetch single listing

4. **BookingRepository** (`lib/features/bookings/data/booking_repository.dart`)
   - `createBooking(...)` - Create a new booking
   - `getMyBookings()` - Get user's bookings

### ✅ Reusable Widgets

1. **ListingCard** (`lib/widgets/listing_card.dart`)
   - Displays a single listing card
   - Handles navigation to details

2. **ListingsList** (`lib/widgets/listings_list.dart`)
   - Complete widget with loading/error states
   - Supports horizontal/vertical scrolling
   - Automatic retry on error

3. **BookingSuccessScreen** (`lib/screens/booking_success_screen.dart`)
   - Shows booking confirmation
   - Navigates to My Events or Home

## Screens That Need Updates

### 1. Home Screen (`lib/screens/home_screen.dart`)

**Update `PopularPackagesSection`:**

```dart
// Replace the current PopularPackagesSection class with:
class PopularPackagesSection extends StatelessWidget {
  const PopularPackagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular Packages', style: AppTheme.sectionTitle),
              Text('VIEW ALL', style: AppTheme.viewAllText),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ListingsList(
          filters: {'limit': 5}, // Get top 5 popular listings
          horizontal: true,
          height: 260,
        ),
      ],
    );
  }
}
```

### 2. Decor Screen (`lib/screens/decor_screen.dart`)

**Update `_DecorGrid`:**

```dart
// Replace _DecorGrid with:
class _DecorGrid extends StatelessWidget {
  const _DecorGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListingsList(
        filters: {'category': 'decoration'}, // Filter by category
        horizontal: false,
      ),
    );
  }
}
```

### 3. Rentals Screen (`lib/screens/rentals_screen.dart`)

**Update `_RentalsGrid`:**

```dart
// Replace _RentalsGrid with:
class _RentalsGrid extends StatelessWidget {
  const _RentalsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListingsList(
        filters: {'category': 'rental'}, // Filter by category
        horizontal: false,
      ),
    );
  }
}
```

### 4. Package Details Screen (`lib/screens/package_details_screen.dart`)

**Option A: Update to accept listingId and fetch details**

```dart
class PackageDetailsScreen extends StatefulWidget {
  final String? listingId; // Make existing params optional
  final String? title;
  final String? imageUrl;
  // ... other optional params

  const PackageDetailsScreen({
    super.key,
    this.listingId,
    this.title,
    this.imageUrl,
    // ... make all optional
  });
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  final ListingsRepository _listingsRepo = ListingsRepository();
  final BookingRepository _bookingRepo = BookingRepository();
  Listing? _listing;
  bool _loading = false;
  bool _bookingLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.listingId != null) {
      _loadListing();
    }
  }

  Future<void> _loadListing() async {
    setState(() => _loading = true);
    try {
      final listing = await _listingsRepo.getListingDetail(widget.listingId!);
      setState(() {
        _listing = listing;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load listing: $e')),
        );
      }
    }
  }

  Future<void> _handleBooking() async {
    if (_listing == null) return;
    
    setState(() => _bookingLoading = true);
    try {
      final booking = await _bookingRepo.createBooking(
        listingId: _listing!.id,
        startDate: DateTime.now().add(const Duration(days: 7)), // Default to 7 days from now
        numberOfGuests: _quantity,
        totalPrice: _listing!.price != null ? _listing!.price! * _quantity : null,
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(booking: booking),
          ),
        );
      }
    } on AppApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _bookingLoading = false);
      }
    }
  }

  // Update Order Now button:
  // Replace onPressed: () {} with onPressed: _handleBooking
  // Add loading state: if (_bookingLoading) CircularProgressIndicator()
}
```

**Option B: Keep current approach, just wire Book Now button**

```dart
// In the Order Now button, add:
onPressed: () async {
  setState(() => _bookingLoading = true);
  try {
    final booking = await BookingRepository().createBooking(
      listingId: 'temp_id', // You'll need to pass listingId to screen
      startDate: DateTime.now().add(const Duration(days: 7)),
      numberOfGuests: _quantity,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(booking: booking),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking failed: $e')),
    );
  } finally {
    setState(() => _bookingLoading = false);
  }
},
```

### 5. Event Screen (`lib/screens/event_screen.dart`)

Similar to Decor/Rentals, filter by category:
- Venues: `{'category': 'venue'}`
- Packages: `{'category': 'package'}`

## Category Mapping

Suggested category values for backend:
- `'decoration'` - Decor items
- `'rental'` - Rental items (tables, chairs, etc.)
- `'venue'` - Venues
- `'package'` - Complete packages
- `'talent'` - Talent/staff

## Example: Complete Integration Pattern

```dart
import '../widgets/listings_list.dart';
import '../features/listings/data/listings_repository.dart';
import '../core/api/app_api_exception.dart';

class MyListingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListingsList(
        filters: {'category': 'rental'},
        horizontal: false,
        onListingTap: () {
          // Custom navigation if needed
        },
        onBookNow: () {
          // Custom booking flow if needed
        },
      ),
    );
  }
}
```

## Error Handling Pattern

All repository methods throw `AppApiException`:

```dart
try {
  final listings = await listingsRepo.getListings();
} on AppApiException catch (e) {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  // Unexpected error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred')),
  );
}
```

## Loading States

The `ListingsList` widget handles loading automatically. For custom loading:

```dart
bool _loading = false;

Future<void> _loadData() async {
  setState(() => _loading = true);
  try {
    // Fetch data
  } finally {
    setState(() => _loading = false);
  }
}

// In build:
if (_loading) {
  return Center(child: CircularProgressIndicator());
}
```

## Testing Checklist

- [ ] Home screen shows listings with loading state
- [ ] Error state shows retry button
- [ ] Decor screen filters by category
- [ ] Rentals screen filters by category
- [ ] Package details can fetch by listingId
- [ ] Book Now button creates booking
- [ ] Booking success screen appears after booking
- [ ] Error messages show for failed bookings

## TODOs for Future Enhancements

1. **Pagination**
   - Add "Load More" button or infinite scroll
   - Update filters with page number

2. **Search**
   - Add search bar to home screen
   - Filter listings by search query

3. **Advanced Filtering**
   - Price range slider
   - Location filter
   - Date availability

4. **Caching**
   - Cache listings locally
   - Refresh on pull-to-refresh

5. **Favorites**
   - Add favorite button to listings
   - Store favorites locally

## Summary

✅ **Created:**
- Models (Listing, Booking)
- Repositories (ListingsRepository, BookingRepository)
- Reusable widgets (ListingCard, ListingsList)
- Booking success screen

🔄 **To Update:**
- Home screen PopularPackagesSection
- Decor screen grid
- Rentals screen grid
- Package details Book Now button
- Event screen (optional)

The `ListingsList` widget makes integration easy - just replace dummy data sections with it!

