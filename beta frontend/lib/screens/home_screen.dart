import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/eventos_logo_svg.dart';
import '../widgets/listings_list.dart';
import '../core/location/location_provider.dart';
import '../widgets/shared_header_card.dart';
import 'cart_screen.dart';
import '../features/cart/data/cart_repository.dart';
import 'packages_screen.dart';
import 'event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: CartRepository(),
                    builder: (context, _) {
                      return SharedHeaderCard(
                        showCartIcon: true,
                        cartItemCount: CartRepository().itemCount,
                        onCartTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                        onSearch: (q) {
                          final query = q.trim();
                          if (query.isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PackagesScreen(),
                              settings: RouteSettings(arguments: {
                                'filters': {'search': query, 'crossCategory': true},
                              }),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  PopularPackagesSection(searchQuery: _searchQuery),
                  const SizedBox(height: 24),
                  ShopByEventSection(),
                  const SizedBox(height: 24),
                  const RecommendedSection(),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ],
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
        // Map index: Home=0, AI Planner=1, My Events=3, Profile=4
        int mainIndex = index == 0 ? 0 : (index == 1 ? 1 : (index == 2 ? 3 : 4));
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

// Content-only version for use in MainNavigationScreen
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: CartRepository(),
                  builder: (context, _) {
                    return SharedHeaderCard(
                      showCartIcon: true,
                      cartItemCount: CartRepository().itemCount,
                      onCartTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      onSearch: (q) {
                        final query = q.trim();
                        if (query.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PackagesScreen(),
                            settings: RouteSettings(arguments: {
                              'filters': {'search': query, 'crossCategory': true},
                            }),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                PopularPackagesSection(searchQuery: _searchQuery),
                const SizedBox(height: 24),
                ShopByEventSection(),
                const SizedBox(height: 24),
                const RecommendedSection(),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PopularPackagesSection extends StatelessWidget {
  final String searchQuery;
  const PopularPackagesSection({super.key, this.searchQuery = ''});

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
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Popular Packages ',
                        style: AppTheme.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      '',
                      style: AppTheme.sectionTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PackagesScreen()),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('VIEW ALL', style: AppTheme.viewAllText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListingsList(
          filters: {
            'category': 'package',
            'isActive': true,
            if (searchQuery.isNotEmpty) 'search': searchQuery,
            'limit': 20,
          },
          horizontal: true,
          height: 260,
          itemLimit: 10,
        ),
      ],
    );
  }
}

class _PopularPackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int rating;
  final String imageUrl;

  const _PopularPackageCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
                  height: 120,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppTheme.primaryColor,
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
              children: [
                Text(
                  title,
                  style: AppTheme.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.cardSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Rating Stars
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppTheme.starColor,
                      size: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Book Now',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Shop by Event Section (toggleable filters)
class ShopByEventSection extends StatefulWidget {
  final ValueChanged<String?>? onChanged; // Selected filter key or null if cleared

  ShopByEventSection({super.key, this.onChanged});

  @override
  State<ShopByEventSection> createState() => _ShopByEventSectionState();
}

class _ShopByEventSectionState extends State<ShopByEventSection> {
  // -1 means no selection
  int _selectedIndex = -1;

  final List<_FilterOption> _options = const [
    _FilterOption('Event!', Icons.location_on, 'event'),
    _FilterOption('Party', Icons.bolt, 'party'),
    _FilterOption('Birthday', Icons.edit, 'birthday'),
    _FilterOption('Wedding', Icons.celebration, 'wedding'),
  ];

  void _toggle(int index) {
    setState(() {
      // Tap again to clear selection
      _selectedIndex = (_selectedIndex == index) ? -1 : index;
    });
    widget.onChanged?.call(_selectedIndex == -1 ? null : _options[_selectedIndex].key);
  }

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
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Shop by event ',
                        style: AppTheme.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      '',
                      style: AppTheme.sectionTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EventScreen()),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VIEW ALL',
                        style: AppTheme.viewAllText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Category Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < _options.length; i++) ...[
                  _CategoryChip(
                    label: _options[i].label,
                    icon: _options[i].icon,
                    isActive: _selectedIndex == i,
                    onTap: () => _toggle(i),
                  ),
                  if (i < _options.length - 1) const SizedBox(width: 8),
                ]
              ],
            ),
          ),
        ),
        // Theme cards removed - use backend data instead
      ],
    );
  }
}

class _FilterOption {
  final String label;
  final IconData icon;
  final String key;
  const _FilterOption(this.label, this.icon, this.key);
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.white : AppTheme.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.white : AppTheme.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalThemeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;

  const _VerticalThemeCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 120,
              color: AppTheme.textGrey.withOpacity(0.2),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.textGrey.withOpacity(0.2),
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.cardSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Price Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'From $price',
                    style: AppTheme.priceText,
                  ),
                ),
                const SizedBox(height: 12),
                // Request Design Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppTheme.textGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Request Design',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
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
  }
}

// Recommended Section
class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended for your event',
                  style: AppTheme.sectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PackagesScreen()),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'VIEW ALL',
                        style: AppTheme.viewAllText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Use backend listings for recommended section
        ListingsList(
          filters: const {
            'isActive': true,
            'limit': 10,
          },
          horizontal: true,
          height: 280,
          onAddToCart: (listing) {
            final cartRepo = CartRepository();
            cartRepo.addItem(
              listingId: listing.id,
              title: listing.title,
              subtitle: 'Recommended',
              imageUrl: (listing.images?.isNotEmpty ?? false) ? listing.images![0] : '',
              pricePerDay: listing.price ?? 0.0,
              days: 1,
              quantity: 1,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${listing.title} added to cart!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviews;
  final String price;
  final String tag;
  final String imageUrl;

  const _RecommendedCard({
    required this.title,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.tag,
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
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    height: 140,
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews)',
                        style: AppTheme.ratingText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTheme.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Parse numeric price from string like ₹2,500/day
                        double parsedPrice = 0;
                        final raw = price.replaceAll(',', '');
                        final match = RegExp(r"(\d+(?:\.\d+)?)").firstMatch(raw);
                        if (match != null) {
                          parsedPrice = double.tryParse(match.group(1)!) ?? 0;
                        }
                        CartRepository().addItem(
                          listingId: title,
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
                        backgroundColor: AppTheme.darkGrey,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: AppTheme.buttonText,
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
