import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/shared_header_card.dart';
import '../features/listings/data/listings_repository.dart';
import '../features/listings/domain/models/listing.dart';
import '../core/api/app_api_exception.dart';
import '../api/api_config.dart';
import '../features/cart/data/cart_repository.dart';

class DecorScreen extends StatefulWidget {
  const DecorScreen({super.key});

  @override
  State<DecorScreen> createState() => _DecorScreenState();
}

class _DecorScreenState extends State<DecorScreen> {
  int _currentIndex = 0;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';
  Map<String, dynamic> _incomingFilters = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['filters'] is Map<String, dynamic>) {
      _incomingFilters = Map<String, dynamic>.from(args['filters'] as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              SharedHeaderCard(
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF4F6D),
                    Color(0xFFFF6B5A),
                  ],
                ),
                onSearch: (q) => setState(() => _searchQuery = q.trim()),
              ),
              const SizedBox(height: 16),
              _FilterChipsRow(
                selectedIndex: _selectedFilterIndex,
                onTap: (index) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              _DecorGrid(
                filters: {
                  'category': 'decoration',
                  'isActive': true,
                  if (_searchQuery.isNotEmpty) 'search': _searchQuery,
                  ..._incomingFilters,
                },
              ),
              const SizedBox(height: 24),
              const _RecommendedSection(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // Navigate back to MainNavigationScreen with the selected index
        // Map index: Home=0, AI Planner=1, My Events=2, Profile=3
        int mainIndex = index == 0 ? 0 : (index == 1 ? 1 : (index == 2 ? 2 : 3));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(initialIndex: mainIndex),
          ),
          (route) => false,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textGrey,
      backgroundColor: AppTheme.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bolt),
          label: 'AI Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'My Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _DecorGrid extends StatefulWidget {
  final Map<String, dynamic> filters;
  const _DecorGrid({required this.filters});

  @override
  State<_DecorGrid> createState() => _DecorGridState();
}

class _DecorGridState extends State<_DecorGrid> {
  final ListingsRepository _repo = ListingsRepository();
  List<Listing> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await _repo.getListings(filters: widget.filters);
      if (!mounted) return;
      setState(() { _items = resp; _loading = false; });
    } on AppApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _img(Listing l) {
    final p = (l.images != null && l.images!.isNotEmpty) ? l.images!.first : (l.imageUrl ?? '');
    if (p.isEmpty) return '';
    return p.startsWith('http') ? p : '$apiPublicBase/$p';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No decor items found', style: TextStyle(color: AppTheme.textGrey))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final l = _items[index];
          return _DecorCard(
            title: l.title,
            rating: l.rating ?? 0,
            reviews: l.reviewCount ?? 0,
            price: l.formattedPrice,
            imageUrl: _img(l),
            listingId: l.id,
          );
        },
      ),
    );
  }
}

// Filter Chips Row
class _FilterChipsRow extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _FilterChipsRow({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Event Type', 'icon': Icons.celebration},
      {'label': 'Theme / Style', 'icon': Icons.palette},
      {'label': 'Venue Type', 'icon': Icons.business},
      {'label': 'Guests', 'icon': Icons.people},
      {'label': 'Budget', 'icon': Icons.attach_money},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.white : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(filters[index]['icon'] as IconData,
                        size: 16,
                        color: isSelected ? AppTheme.textDark : AppTheme.textGrey),
                    const SizedBox(width: 6),
                    Text(
                      filters[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Decor Card Widget
class _DecorCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviews;
  final String price;
  final String imageUrl;
  final String? listingId;

  const _DecorCard({
    required this.title,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
    this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsScreen(
              listingId: listingId,
              title: title,
              imageUrl: imageUrl,
              rating: rating,
              soldCount: reviews * 10, // Convert reviews to sold count estimate
              price: price,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    color: AppTheme.textGrey.withOpacity(0.2),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.textGrey.withOpacity(0.2),
                          child: const Icon(Icons.image, size: 50),
                        );
                      },
                    ),
                  ),
                  // Available Tag
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Available',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  SizedBox(
                    height: 32,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 11,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '$rating ($reviews)',
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Price
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Parse numeric price if possible from formatted string like ₹2,500/day
                        double parsedPrice = 0;
                        final digits = RegExp(r"(\d[\d,]*)").firstMatch(price.replaceAll(',', ''))?.group(1);
                        if (digits != null) {
                          parsedPrice = double.tryParse(digits) ?? 0;
                        }
                        CartRepository().addItem(
                          listingId: listingId ?? title,
                          title: title,
                          subtitle: '',
                          imageUrl: imageUrl,
                          pricePerDay: parsedPrice,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recommended Section
class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    final recommendedItems = [
      {
        'title': 'Premium BBQ Grill Set',
        'rating': 4.5,
        'reviews': 128,
        'price': '₹2,500/day',
        'imageUrl': 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400',
      },
      {
        'title': 'Professional DJ Equipment',
        'rating': 4.8,
        'reviews': 256,
        'price': '₹8,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Recommended for your event',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendedItems.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Stack(
                        children: [
                          Container(
                            height: 110,
                            width: double.infinity,
                            color: AppTheme.textGrey.withOpacity(0.2),
                            child: Image.network(
                              recommendedItems[index]['imageUrl'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.textGrey.withOpacity(0.2),
                                  child: const Icon(Icons.image, size: 50),
                                );
                              },
                            ),
                          ),
                          // Available Tag
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Available',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          SizedBox(
                            height: 32,
                            child: Text(
                              recommendedItems[index]['title'] as String,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  '${recommendedItems[index]['rating']} (${recommendedItems[index]['reviews']})',
                                  style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Price
                          Text(
                            recommendedItems[index]['price'] as String,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkNavy,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
