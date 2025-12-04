import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/eventos_logo_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
                  const HeaderCard(),
                  const SizedBox(height: 24),
                  const PopularPackagesSection(),
                  const SizedBox(height: 24),
                  const ShopByEventSection(),
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
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const HeaderCard(),
                const SizedBox(height: 24),
                const PopularPackagesSection(),
                const SizedBox(height: 24),
                const ShopByEventSection(),
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

// Header Card Widget
class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome and Location Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hi, Welcome ',
                  style: AppTheme.welcomeText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                            style: AppTheme.locationText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // App Title
          const SizedBox(height: 8),
          const EventosLogoSvg(height: 36, color: AppTheme.white),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.darkGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppTheme.textGrey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search BBQ grill, DJ, tents...',
                    style: TextStyle(
                      color: AppTheme.textGrey,
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
                        color: AppTheme.primaryColor,
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
          // Filter Chips Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGrey,
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
                          style: AppTheme.locationText,
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
                    color: AppTheme.darkGrey,
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
                          style: AppTheme.locationText,
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

// Popular Packages Section
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'VIEW ALL',
                      style: AppTheme.viewAllText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 2,
            itemBuilder: (context, index) {
              return _PopularPackageCard(
                title: index == 0 ? 'Boho Chic Party' : 'Retro 80s Night',
                subtitle: index == 0
                    ? 'Rustic elegance meets modern bohemian style with natural'
                    : 'Vibrant neon lights retro aesthetics for',
                rating: index == 0 ? 4 : 5,
                imageUrl: index == 0
                    ? 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400'
                    : 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400',
              );
            },
          ),
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

// Shop by Event Section
class ShopByEventSection extends StatelessWidget {
  const ShopByEventSection({super.key});

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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'VIEW ALL',
                      style: AppTheme.viewAllText,
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
                _CategoryChip(
                  label: 'Event!',
                  icon: Icons.location_on,
                  isActive: true,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Party',
                  icon: Icons.bolt,
                  isActive: false,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Birthday',
                  icon: Icons.edit,
                  isActive: false,
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Wedding',
                  icon: Icons.celebration,
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Vertical Theme Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _VerticalThemeCard(
                title: 'Create Your Custom Theme',
                subtitle: 'Upload a moodboard + fill event details',
                price: '₹15,000',
                imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
              ),
              const SizedBox(height: 16),
              _VerticalThemeCard(
                title: 'Create Your Custom Theme',
                subtitle: 'Upload a moodboard + fill event details',
                price: '₹15,000',
                imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
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
  final IconData icon;
  final bool isActive;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'VIEW ALL',
                      style: AppTheme.viewAllText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _RecommendedCard(
                  title: 'Premium BBQ Grill Set',
                  rating: 4.5,
                  reviews: 128,
                  price: '₹2,500/day',
                  tag: 'Available',
                  imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RecommendedCard(
                  title: 'Professional DJ Equipment',
                  rating: 4.8,
                  reviews: 256,
                  price: '₹8,000/event',
                  tag: 'Available',
                  imageUrl: 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400',
                ),
              ),
            ],
          ),
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
                    onPressed: () {},
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
