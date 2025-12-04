import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/eventos_logo_svg.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  int _currentIndex = 0;
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const _PackagesHeader(),
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
              const _PackagesGrid(),
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(initialIndex: index),
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
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
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

// Packages Header with Pink Background
class _PackagesHeader extends StatelessWidget {
  const _PackagesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4F6D),
            Color(0xFFFF6B5A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Welcome and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hi, Welcome ',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppTheme.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Mumbai, India',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: App Logo
          const SizedBox(height: 8),
          const EventosLogoSvg(height: 36, color: AppTheme.white),
          const SizedBox(height: 16),
          // Row 3: Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppTheme.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search BBQ grill, DJ, tents...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: AppTheme.white,
                        size: 20,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 4: Filter Chips
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Event date',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'City / pin code',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Filter Tabs Row
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filters[index]['icon'] as IconData,
                      size: 16,
                      color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
                    ),
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

// Packages Grid Section
class _PackagesGrid extends StatelessWidget {
  const _PackagesGrid();

  @override
  Widget build(BuildContext context) {
    final packageItems = [
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
      {
        'title': 'Birthday Party Package',
        'rating': 4.7,
        'reviews': 289,
        'price': '₹25,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
      },
      {
        'title': 'Anniversary Celebration',
        'rating': 4.6,
        'reviews': 178,
        'price': '₹30,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400',
      },
    ];

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
        itemCount: packageItems.length,
        itemBuilder: (context, index) {
          return _PackageCard(
            title: packageItems[index]['title'] as String,
            rating: packageItems[index]['rating'] as double,
            reviews: packageItems[index]['reviews'] as int,
            price: packageItems[index]['price'] as String,
            imageUrl: packageItems[index]['imageUrl'] as String,
          );
        },
      ),
    );
  }
}

// Package Card Widget
class _PackageCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviews;
  final String price;
  final String imageUrl;

  const _PackageCard({
    required this.title,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsScreen(
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

// Recommended Section
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
