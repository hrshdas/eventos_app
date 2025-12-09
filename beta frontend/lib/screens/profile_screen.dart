import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import '../core/auth/auth_controller.dart';
import 'login_screen.dart';
import 'create_listing_screen.dart';
import 'edit_profile_screen.dart';
import '../features/listings/presentation/my_listings_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile tab

  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads (only if we don't have a user)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      // Only refresh if we don't have a user yet
      if (authController.currentUser == null) {
        debugPrint('ProfileScreen: No user found, refreshing...');
        authController.refreshUser();
      } else {
        debugPrint('ProfileScreen: User already exists: ${authController.currentUser?.name}');
        // Optionally refresh to get latest data (phone, etc.) but don't wait for it
        authController.refreshUser().catchError((e) {
          debugPrint('ProfileScreen: Refresh failed but keeping existing user: $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final isOwner = user?.role?.toUpperCase() == 'OWNER';
        
        // Debug: Print user data
        if (user != null) {
          debugPrint('ProfileScreen: Building with user: ${user.name}, email: ${user.email}, role: ${user.role}');
        } else {
          debugPrint('ProfileScreen: Building with null user, isLoading: ${authController.isLoading}');
        }
        
        // Show loading if auth is still initializing
        if (authController.isLoading && user == null) {
          return Scaffold(
            backgroundColor: AppTheme.lightGrey,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.lightGrey,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with overlay stats card
                  _HeaderSection(user: user),
                  SizedBox(height: 70), // Space to accommodate the overlay stats card
                  // Content cards
                  _PersonalInfoCard(user: user),

                  SizedBox(height: 16),
                  if (isOwner) ...[
                    _MyListingsSection(),
                    SizedBox(height: 16),
                  ],
                  _PreferencesCard(),
                  SizedBox(height: 16),
                  _UpcomingEventsCard(),
                  SizedBox(height: 16),
                  _AccountActionsList(isOwner: isOwner, user: user),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // Use central navigation to switch tabs in MainNavigationScreen
              // Map index: Home=0, AI Planner=1, My Events=2, Profile=3
              int mainIndex = index == 0 ? 0 : (index == 1 ? 1 : (index == 2 ? 2 : 3));
              NavigationHelper.navigateToMainScreen(context, mainIndex);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textGrey,
            backgroundColor: AppTheme.white,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'AI Planner'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Events'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic user; // User model from AuthController

  const _HeaderSection({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final headerHeight = 220.0;

    final sidePadding = 20.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient header
        Container(
          width: double.infinity,
          height: headerHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4F6D), Color(0xFFFF6B5A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
            child: Column(
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back arrow
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Settings
                    InkWell(
                      onTap: () {
                        // ignore: avoid_print
                        print('Settings tapped');
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.settings, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Avatar + Name
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.darkGrey,
                          child: Text(
                            user?.initials ?? 'GU',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role == 'OWNER' ? 'Owner' : 'Event Enthusiast',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Overlay stats card
        Positioned(
          bottom: -56,
          left: sidePadding,
          right: sidePadding,
          child: _StatsCard(),
        ),
      ],
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  final dynamic user; // User model from AuthController

  const _PersonalInfoCard({super.key, this.user});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              )),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: AppTheme.textGrey.withOpacity(0.4),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
      child: Column(
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _row('Full Name', user?.name ?? 'Guest User'),
          _divider(),
          _row('Email', user?.email ?? 'Not specified'),
          _divider(),
          _row('Phone', user?.phone ?? 'Not specified'),
          _divider(),
          _row('Role', user?.role ?? 'CONSUMER'),
        ],
      ),
    );
  }
}

class _MyListingsSection extends StatelessWidget {
  const _MyListingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Listings',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyListingsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateListingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create New Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountActionsList extends StatelessWidget {
  final bool isOwner;
  final dynamic user; // User model from AuthController

  const _AccountActionsList({super.key, required this.isOwner, this.user});

  Widget _item({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    final row = InkWell(
      onTap: onTap ??
          () {
            // ignore: avoid_print
            print('$label tapped');
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );

    if (!showDivider) return row;

    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppTheme.textGrey.withOpacity(0.4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
        children: [
          _item(
            icon: Icons.edit,
            label: 'Edit Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _item(icon: Icons.credit_card, label: 'Payment Methods'),
          _item(icon: Icons.notifications, label: 'Notifications'),
          if (isOwner)
            _item(
              icon: Icons.add_business,
              label: 'Create Listing',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateListingScreen(),
                  ),
                );
              },
            ),
          _item(
            icon: Icons.support_agent,
            label: 'Help & Support',
            showDivider: true,
          ),
          _item(
            icon: Icons.logout,
            label: 'Log out',
            showDivider: false,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              // Perform logout
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(label: 'Bookings', value: '0'),
          _StatItem(label: 'Wishlist', value: '0'),
          _StatItem(label: 'Reviews', value: '0'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Preferences',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customize your event recommendations and notifications.',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsCard extends StatelessWidget {
  const _UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Upcoming Events',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have no upcoming events yet.',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Content-only version for use inside MainNavigationScreen tab (no Scaffold/BottomNav)
class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads (only if we don't have a user)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      // Only refresh if we don't have a user yet
      if (authController.currentUser == null) {
        debugPrint('ProfileScreenContent: No user found, refreshing...');
        authController.refreshUser();
      } else {
        debugPrint('ProfileScreenContent: User already exists: ${authController.currentUser?.name}');
        // Optionally refresh to get latest data (phone, etc.) but don't wait for it
        authController.refreshUser().catchError((e) {
          debugPrint('ProfileScreenContent: Refresh failed but keeping existing user: $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileScreenContent.build: Called');
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final isOwner = user?.role?.toUpperCase() == 'OWNER';
        
        // Debug: Print user data
        debugPrint('ProfileScreenContent: Consumer builder called');
        debugPrint('ProfileScreenContent: authController.isLoggedIn: ${authController.isLoggedIn}');
        debugPrint('ProfileScreenContent: authController.isLoading: ${authController.isLoading}');
        if (user != null) {
          debugPrint('ProfileScreenContent: Building with user: ${user.name}, email: ${user.email}, role: ${user.role}');
        } else {
          debugPrint('ProfileScreenContent: Building with null user');
        }
        
        // Show loading if auth is still initializing
        if (authController.isLoading && user == null) {
          debugPrint('ProfileScreenContent: Showing loading indicator');
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _HeaderSection(user: user),
                SizedBox(height: 70),
                _PersonalInfoCard(user: user),
                SizedBox(height: 16),
                if (isOwner) ...[
                  _MyListingsSection(),
                  SizedBox(height: 16),
                ],
                _PreferencesCard(),
                SizedBox(height: 16),
                _UpcomingEventsCard(),
                SizedBox(height: 16),
                _AccountActionsList(isOwner: isOwner, user: user),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}