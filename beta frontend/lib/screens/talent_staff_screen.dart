import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'package_details_screen.dart';
import '../widgets/shared_header_card.dart';
import 'packages_screen.dart';
import '../widgets/listings_list.dart';

class TalentStaffScreen extends StatefulWidget {
  const TalentStaffScreen({super.key});

  @override
  State<TalentStaffScreen> createState() => _TalentStaffScreenState();
}

class _TalentStaffScreenState extends State<TalentStaffScreen> {
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
              SharedHeaderCard(
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF4F6D),
                    Color(0xFFFF6B5A),
                  ],
                ),
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
              // Fetch talent listings from backend
              ListingsList(
                filters: const {
                  'category': 'talent',
                  'isActive': true,
                  'limit': 20,
                },
              ),
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

