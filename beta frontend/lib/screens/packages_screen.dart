import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/shared_header_card.dart';
import '../features/listings/data/listings_repository.dart';
import '../features/listings/domain/models/listing.dart';
import '../core/api/app_api_exception.dart';
import '../api/api_config.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  int _currentIndex = 0;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';
  Map<String, dynamic> _incomingFilters = const {};
  String? _categoryFilter; // 'decor' | 'rental' | 'package' | null for All

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
    final crossCategory = (_incomingFilters['crossCategory'] == true);
    final hasExplicitCategory = _incomingFilters.containsKey('category');

    // Build filters dynamically. If crossCategory is true, do not force 'package'.
    final effectiveFilters = <String, dynamic>{
      'isActive': true,
      if (!crossCategory && !hasExplicitCategory) 'category': 'package',
      if (crossCategory && _categoryFilter != null) 'category': _categoryFilter,
      if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      ..._incomingFilters,
    };

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
              if (crossCategory) ...[
                const SizedBox(height: 12),
                // Category chips for cross-category search
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isActive: _categoryFilter == null,
                        onTap: () => setState(() => _categoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Decor',
                        isActive: _categoryFilter == 'decor',
                        onTap: () => setState(() => _categoryFilter = 'decor'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Rentals',
                        isActive: _categoryFilter == 'rental',
                        onTap: () => setState(() => _categoryFilter = 'rental'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Packages',
                        isActive: _categoryFilter == 'package',
                        onTap: () => setState(() => _categoryFilter = 'package'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _FilterTabsRow(
                selectedIndex: _selectedFilterIndex,
                onTap: (index) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              _PackagesGrid(
                filters: effectiveFilters,
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

// Filter Tabs Row (restored)
class _FilterTabsRow extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _FilterTabsRow({
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
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryColor, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(filters[index]['icon'] as IconData, size: 16, color: AppTheme.textDark),
                    const SizedBox(width: 6),
                    Text(filters[index]['label'] as String,
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 12)),
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

class _PackagesGrid extends StatefulWidget {
  final Map<String, dynamic> filters;
  const _PackagesGrid({required this.filters});

  @override
  State<_PackagesGrid> createState() => _PackagesGridState();
}

class _PackagesGridState extends State<_PackagesGrid> {
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
        child: Center(child: Text('No packages found', style: TextStyle(color: AppTheme.textGrey))),
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
          return _PackageCard(
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

class _PackageCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviews;
  final String price;
  final String imageUrl;
  final String? listingId;

  const _PackageCard({
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
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    final recommendedItems = [
      {
        'title': 'Complete Wedding Package',
        'rating': 4.9,
        'reviews': 456,
        'price': '₹50,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
      },
      {
        'title': 'Corporate Event Package',
        'rating': 4.8,
        'reviews': 312,
        'price': '₹35,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _PackageCard(
                  title: recommendedItems[0]['title'] as String,
                  rating: recommendedItems[0]['rating'] as double,
                  reviews: recommendedItems[0]['reviews'] as int,
                  price: recommendedItems[0]['price'] as String,
                  imageUrl: recommendedItems[0]['imageUrl'] as String,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PackageCard(
                  title: recommendedItems[1]['title'] as String,
                  rating: recommendedItems[1]['rating'] as double,
                  reviews: recommendedItems[1]['reviews'] as int,
                  price: recommendedItems[1]['price'] as String,
                  imageUrl: recommendedItems[1]['imageUrl'] as String,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
