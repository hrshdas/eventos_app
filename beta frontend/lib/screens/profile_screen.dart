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
                                  Text(b.listingTitle ?? 'Listing ${b.listingId}',
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
              booking.listingTitle ?? 'Listing ${booking.listingId}',
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