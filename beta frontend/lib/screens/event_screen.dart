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
                  SharedHeaderCard(
                    onSearch: (q) {
                      final query = q.trim();
                      if (query.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PackagesScreen(),
                          settings: RouteSettings(arguments: {
                            'filters': {'search': query},
                          }),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const _BrowseCategoriesSection(),
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
                SharedHeaderCard(
                  onSearch: (q) {
                    final query = q.trim();
                    if (query.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PackagesScreen(),
                        settings: RouteSettings(arguments: {
                          'filters': {'search': query},
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _BrowseCategoriesSection(),
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
