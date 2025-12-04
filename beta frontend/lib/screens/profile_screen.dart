import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import '../api/api_client.dart';
import '../auth/auth_repository.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile tab

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.lightGrey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with overlay stats card
              const _HeaderSection(),
              const SizedBox(height: 70), // Space to accommodate the overlay stats card
              // Content cards
              const _PersonalInfoCard(),
              const SizedBox(height: 16),
              const _PreferencesCard(),
              const SizedBox(height: 16),
              const _UpcomingEventsCard(),
              const SizedBox(height: 16),
              const _AccountActionsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Use central navigation to switch tabs in MainNavigationScreen
          NavigationHelper.navigateToMainScreen(context, index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textGrey,
        backgroundColor: AppTheme.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'AI Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = 220.0;
    final sidePadding = 20.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient header
        Container(
          width: double.infinity,
          height: headerHeight,
          decoration: const BoxDecoration(
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
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.darkGrey,
                          child: Text(
                            'RG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Raghav Gupta',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Event Enthusiast',
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
          child: const _StatsCard(),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  Widget _statItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(child: _statItem('12', 'Events booked')),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.textGrey.withOpacity(0.25),
            ),
            Expanded(child: _statItem('4', 'Events hosted')),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.textGrey.withOpacity(0.25),
            ),
            Expanded(child: _statItem('8', 'Favorites')),
          ],
        ),
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard();

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
                  // ignore: avoid_print
                  print('Edit personal info tapped');
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
          _row('Full Name', 'Raghav Gupta'),
          _divider(),
          _row('Email', 'raghav@email.com'),
          _divider(),
          _row('Phone', '+91 98765 43210'),
          _divider(),
          _row('Location', 'Bengaluru, India'),
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatefulWidget {
  const _PreferencesCard();

  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  final List<_PrefChip> _chips = [
    _PrefChip('Birthday Parties', selected: true, icon: Icons.cake),
    _PrefChip('Corporate Events', selected: false, icon: Icons.work),
    _PrefChip('Wedding', selected: true, icon: Icons.favorite),
    _PrefChip('Home Decor', selected: false, icon: Icons.home),
  ];

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
          const Text(
            'Event Preferences',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us what you usually look for so we can recommend better packages.',
            style: TextStyle(
              color: AppTheme.textGrey.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _chips.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _chips[i] = _chips[i].copyWith(selected: !_chips[i].selected);
                    });
                  },
                  child: _PreferenceChip(chip: _chips[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrefChip {
  final String label;
  final bool selected;
  final IconData icon;

  _PrefChip(this.label, {required this.selected, required this.icon});

  _PrefChip copyWith({String? label, bool? selected, IconData? icon}) {
    return _PrefChip(
      label ?? this.label,
      selected: selected ?? this.selected,
      icon: icon ?? this.icon,
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final _PrefChip chip;
  const _PreferenceChip({required this.chip});

  @override
  Widget build(BuildContext context) {
    final selected = chip.selected;
    final bg = selected ? const Color(0xFFFFE5E8) : const Color(0xFFF3F3F3);
    final fg = selected ? AppTheme.primaryColor : AppTheme.textDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.primaryColor.withOpacity(0.45) : Colors.transparent,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            chip.label,
            style: TextStyle(
              color: fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check_circle, size: 14, color: AppTheme.primaryColor),
          ]
        ],
      ),
    );
  }
}

class _UpcomingEventsCard extends StatelessWidget {
  const _UpcomingEventsCard();

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _eventRow({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String statusText,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 44,
              color: AppTheme.textGrey.withOpacity(0.2),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 20, color: AppTheme.textGrey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _statusPill(statusText, statusColor),
        ],
      ),
    );
  }

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
                'Upcoming Events',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  // ignore: avoid_print
                  print('View All upcoming tapped');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _eventRow(
            title: "Neha's Birthday Party",
            subtitle: 'Sat, 21 Dec • 7:00 PM',
            imageUrl:
                'https://images.unsplash.com/photo-1507914372368-b2b085b925a1?w=400',
            statusText: 'Confirmed',
            statusColor: const Color(0xFF10B981), // green
          ),
          _eventRow(
            title: 'Corporate Meet-up',
            subtitle: 'Fri, 10 Jan • 6:30 PM',
            imageUrl:
                'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
            statusText: 'Pending',
            statusColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _AccountActionsList extends StatelessWidget {
  const _AccountActionsList();

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
          _item(icon: Icons.edit, label: 'Edit Profile'),
          _item(icon: Icons.credit_card, label: 'Payment Methods'),
          _item(icon: Icons.notifications, label: 'Notifications'),
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
              final api = ApiClient();
              final auth = AuthRepository(api);
              await auth.logout();
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

// Content-only version for use inside MainNavigationScreen tab (no Scaffold/BottomNav)
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: const [
            _HeaderSection(),
            SizedBox(height: 70),
            _PersonalInfoCard(),
            SizedBox(height: 16),
            _PreferencesCard(),
            SizedBox(height: 16),
            _UpcomingEventsCard(),
            SizedBox(height: 16),
            _AccountActionsList(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}