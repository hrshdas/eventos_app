import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'decor_screen.dart';
import 'rentals_screen.dart';
import 'talent_staff_screen.dart';
import 'packages_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/shared_header_card.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
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
                  const SharedHeaderCard(),
                  const SizedBox(height: 24),
                  const _BrowseCategoriesSection(),
                  const SizedBox(height: 24),
                  const _PopularSection(
                    title: 'Popular Decor for you ',
                    items: [
                      _PopularItem(
                        title: 'Create Your Custom Theme',
                        subtitle: 'Upload a moodboard + fill event details',
                        price: '₹15,000',
                        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                      ),
                      _PopularItem(
                        title: 'Create Your Custom Theme',
                        subtitle: 'Upload a moodboard + fill event details',
                        price: '₹15,000',
                        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _PopularSection(
                    title: 'Popular Rentals for you ',
                    items: [
                      _PopularItem(
                        title: 'Create Your Custom Theme',
                        subtitle: 'Upload a moodboard + fill event details',
                        price: '₹15,000',
                        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                      ),
                      _PopularItem(
                        title: 'Create Your Custom Theme',
                        subtitle: 'Upload a moodboard + fill event details',
                        price: '₹15,000',
                        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                      ),
                    ],
                  ),
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

// Content-only version for use in MainNavigationScreen
class EventScreenContent extends StatelessWidget {
  const EventScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const SharedHeaderCard(),
                const SizedBox(height: 24),
                const _BrowseCategoriesSection(),
                const SizedBox(height: 24),
                const _PopularSection(
                  title: 'Popular Decor for you ',
                  items: [
                    _PopularItem(
                      title: 'Create Your Custom Theme',
                      subtitle: 'Upload a moodboard + fill event details',
                      price: '₹15,000',
                      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                    ),
                    _PopularItem(
                      title: 'Create Your Custom Theme',
                      subtitle: 'Upload a moodboard + fill event details',
                      price: '₹15,000',
                      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _PopularSection(
                  title: 'Popular Rentals for you ',
                  items: [
                    _PopularItem(
                      title: 'Create Your Custom Theme',
                      subtitle: 'Upload a moodboard + fill event details',
                      price: '₹15,000',
                      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                    ),
                    _PopularItem(
                      title: 'Create Your Custom Theme',
                      subtitle: 'Upload a moodboard + fill event details',
                      price: '₹15,000',
                      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
                    ),
                  ],
                ),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Browse Categories Section
class _BrowseCategoriesSection extends StatelessWidget {
  const _BrowseCategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse Categories',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _CategoryCard(
                title: 'Rentals',
                icon: Icons.chair,
                backgroundColor: const Color(0xFFFFF5F0), // Light peach/pink
                iconColor: const Color(0xFF8B4513), // Brown
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RentalsScreen(),
                    ),
                  );
                },
              ),
              _CategoryCard(
                title: 'Talent & Staff',
                icon: Icons.mic,
                backgroundColor: const Color(0xFFF3E8FF), // Light lavender
                iconColor: const Color(0xFF6B7280), // Grey
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TalentStaffScreen(),
                    ),
                  );
                },
              ),
              _CategoryCard(
                title: 'Decor',
                icon: Icons.palette,
                backgroundColor: const Color(0xFFFFF5F0), // Light peach
                iconColor: const Color(0xFFFF6B6B), // Peach/red
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DecorScreen(),
                    ),
                  );
                },
              ),
              _CategoryCard(
                title: 'Ready-to-Book Packages',
                icon: Icons.inventory_2,
                backgroundColor: const Color(0xFFE6FFFA), // Light mint/green
                iconColor: const Color(0xFF10B981), // Green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PackagesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Popular Section (reusable for Decor and Rentals)
class _PopularSection extends StatelessWidget {
  final String title;
  final List<_PopularItem> items;

  const _PopularSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'VIEW ALL',
                style: AppTheme.viewAllText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PopularItemCard(item: item),
              )),
        ],
      ),
    );
  }
}

// Popular Item Data Model
class _PopularItem {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;

  const _PopularItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
  });
}

// Popular Item Card Widget
class _PopularItemCard extends StatelessWidget {
  final _PopularItem item;

  const _PopularItemCard({required this.item});

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
          // Image on left
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 120,
              color: AppTheme.textGrey.withOpacity(0.2),
              child: Image.network(
                item.imageUrl,
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
          // Content on right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Bottom row: Price pill + Request Design button
                Row(
                  children: [
                    // Price pill
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5), // Soft pink/orange
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'From ${item.price}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Request Design button
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle request design action
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkNavy,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Request Design',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
