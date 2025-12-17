import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import '../core/auth/auth_controller.dart';
import 'login_screen.dart';
import 'create_listing_screen.dart';
import 'edit_profile_screen.dart';
import '../features/listings/presentation/my_listings_screen.dart';
import '../features/bookings/data/booking_repository.dart';
import '../features/bookings/domain/models/booking.dart';
import '../features/notifications/data/notifications_repository.dart';

// ... (rest of the code remains the same)

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
          _item(
            icon: Icons.book_online,
            label: 'My Bookings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyBookingsScreen(),
                ),
              );
            },
          ),
          _item(icon: Icons.credit_card, label: 'Payment Methods'),
          _item(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
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
          if (isOwner)
            _item(
              icon: Icons.event_available,
              label: 'Bookings for my listings',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OwnerBookingsScreen(),
                  ),
                );
              },
            ),
          _item(
            icon: Icons.support_agent,
            label: 'Help & Support',
            showDivider: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
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

// ... (rest of the code remains the same)

// ================== My Bookings Screen ==================
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _repo = BookingRepository();
  bool _loading = true;
  String? _error;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getMyBookings();
      setState(() {
        _bookings = data;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightGrey,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorView(message: _error!, onRetry: _load)
                : _bookings.isEmpty
                    ? const _EmptyView(message: 'You have no bookings yet.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (_, i) => _BookingTile(booking: _bookings[i]),
                      ),
      ),
    );
  }
}

// ================== Owner Bookings Screen ==================
class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final _repo = BookingRepository();
  bool _loading = true;
  String? _error;
  List<Booking> _bookings = [];
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getOwnerBookings();
      setState(() {
        _bookings = data;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Booking b, String status) async {
    setState(() => _actionError = null);
    try {
      final updated = await _repo.updateBookingStatus(bookingId: b.id, status: status);
      final idx = _bookings.indexWhere((x) => x.id == b.id);
      if (idx != -1) {
        setState(() {
          _bookings[idx] = updated;
        });
      }
      // feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking ${status.toLowerCase()}')),
        );
      }
    } catch (e) {
      setState(() => _actionError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings for my listings'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightGrey,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorView(message: _error!, onRetry: _load)
                : _bookings.isEmpty
                    ? const _EmptyView(message: 'No bookings for your listings yet.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (_, i) {
                          final b = _bookings[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.listingTitle ?? 'Untitled Listing',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Status: ${b.status.toUpperCase()}',
                                      style: TextStyle(color: AppTheme.textGrey)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: b.status.toUpperCase() == 'CONFIRMED'
                                            ? null
                                            : () => _updateStatus(b, 'CONFIRMED'),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Confirm'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: b.status.toUpperCase() == 'CANCELLED'
                                            ? null
                                            : () => _updateStatus(b, 'CANCELLED'),
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Cancel'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_actionError != null) ...[
                                    const SizedBox(height: 6),
                                    Text(_actionError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

// ================== Shared UI bits ==================
class _BookingTile extends StatelessWidget {
  final Booking booking;
  const _BookingTile({required this.booking});

  String _format(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.listingTitle ?? 'Untitled Listing',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('From: ${_format(booking.startDate)}  To: ${_format(booking.endDate)}',
                style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 4),
            Text('Status: ${booking.status.toUpperCase()}'),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

// ================== Content-only Profile Screen (for MainNavigationScreen) ==================
class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  @override
  void initState() {
    super.initState();
    // Refresh user on first build if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      if (authController.currentUser == null) {
        authController.refreshUser().catchError((_) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final isOwner = user?.role?.toUpperCase() == 'OWNER';

        if (authController.isLoading && user == null) {
          return const SafeArea(child: Center(child: CircularProgressIndicator()));
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

// ================== Section Widgets reinstated ==================
class _HeaderSection extends StatelessWidget {
  final dynamic user;
  const _HeaderSection({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    const headerHeight = 220.0;
    const sidePadding = 20.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40, height: 40),
                    const Text('Profile', style: TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 40, height: 40),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.darkGrey,
                        child: Text(
                          user?.initials ?? 'GU',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? 'Guest User',
                      style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.role == 'OWNER' ? 'Owner' : 'Event Enthusiast',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
  final dynamic user;
  const _PersonalInfoCard({super.key, this.user});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personal Information', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                },
                child: const Text('Edit', style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _row('Full Name', user?.name ?? 'Guest User'),
          Divider(height: 1, thickness: 0.5, color: AppTheme.textGrey.withOpacity(0.4)),
          _row('Email', user?.email ?? 'Not specified'),
          Divider(height: 1, thickness: 0.5, color: AppTheme.textGrey.withOpacity(0.4)),
          _row('Phone', user?.phone ?? 'Not specified'),
          Divider(height: 1, thickness: 0.5, color: AppTheme.textGrey.withOpacity(0.4)),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Listings', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListingsScreen()));
                },
                child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateListingScreen()));
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create New Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Preferences', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Customize your event recommendations and notifications.', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Upcoming Events', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('You have no upcoming events yet.', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
        ],
      ),
    );
  }
}

// Stats card displayed overlapping the header
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationsRepository();
  bool _loading = true;
  String? _error;
  List<NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.getNotifications();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    try {
      await _repo.markAllRead();
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAll,
            child: const Text('Mark all read'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorView(message: _error!, onRetry: _load)
                : _items.isEmpty
                    ? const _EmptyView(message: 'No notifications')
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final n = _items[i];
                          return ListTile(
                            title: Text(n.title),
                            subtitle: Text(n.body),
                            trailing: n.readAt == null
                                ? const Icon(Icons.circle, size: 10, color: Colors.red)
                                : const SizedBox.shrink(),
                            onTap: () async {
                              if (n.readAt == null) {
                                await _repo.markRead(n.id);
                                if (!mounted) return;
                                setState(() => _items[i] = NotificationItem(
                                      id: n.id,
                                      title: n.title,
                                      body: n.body,
                                      data: n.data,
                                      createdAt: n.createdAt,
                                      readAt: DateTime.now(),
                                    ));
                              }
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

// ================== Help & Support Screen ==================
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _openComposer(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send a message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Describe your issue... (order id, date, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent. Our team will get back to you.')));
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightGrey,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppTheme.textDark),
                  title: const Text('FAQs'),
                  subtitle: const Text('Common questions and answers'),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('FAQs'),
                        content: const Text('Coming soon. For now, please send us a message.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppTheme.textDark),
                  title: const Text('Email us'),
                  subtitle: const Text('support@eventos.app'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppTheme.textDark),
                  title: const Text('Call us'),
                  subtitle: const Text('+91 98765 43210'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.textDark),
                  title: const Text('Send a message'),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                  onTap: () => _openComposer(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}