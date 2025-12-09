import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 2; // Cart tab

  final List<CartItem> _items = [
    CartItem(
      title: 'Premium BBQ Grill Set',
      subtitle: 'BBQ Equipment',
      imageUrl:
          'https://images.unsplash.com/photo-1558036117-15d82a90b9b9?w=600',
      pricePerDay: 2500,
      days: 1,
      quantity: 1,
    ),
    CartItem(
      title: 'Floral Stage Decor',
      subtitle: 'Decor • Indoor',
      imageUrl:
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=600',
      pricePerDay: 3200,
      days: 1,
      quantity: 1,
    ),
    CartItem(
      title: 'Pro DJ Console',
      subtitle: 'Audio • Equipment',
      imageUrl:
          'https://images.unsplash.com/photo-1551817958-20204c6a6d76?w=600',
      pricePerDay: 1800,
      days: 1,
      quantity: 1,
    ),
  ];

  double get subtotal {
    return _items.fold<double>(
      0,
      (sum, item) => sum + (item.pricePerDay * item.days * item.quantity),
    );
  }

  double get serviceFee => 250.0; // example fixed fee
  double get taxes => (subtotal * 0.05); // 5% example tax
  double get total => subtotal + serviceFee + taxes;

  void _incrementQty(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    });
  }

  void _decrementQty(int index) {
    setState(() {
      final q = _items[index].quantity;
      if (q > 1) {
        _items[index] = _items[index].copyWith(quantity: q - 1);
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _items.clear();
    });
    // ignore: avoid_print
    print('Cart cleared');
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.lightGrey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(
                itemCount: _items.length,
                onClearAll: _clearAll,
              ),
              const SizedBox(height: 16),
              // Cart Items
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListView.builder(
                  itemCount: _items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Dismissible(
                      key: ValueKey('${item.title}-$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteItem(index),
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                      child: _CartItemCard(
                        item: item,
                        onDecrement: () => _decrementQty(index),
                        onIncrement: () => _incrementQty(index),
                        onDelete: () => _deleteItem(index),
                      ),
                    );
                  },
                ),
              ),
              // Optional: Coupon / Note row
              const _CouponRow(),
              // Summary
              _SummaryCard(
                subtotal: subtotal,
                serviceFee: serviceFee,
                taxes: taxes,
                total: total,
              ),
              const SizedBox(height: 100), // spacer before bottom button/nav
            ],
          ),
        ),
      ),
      // Bottom fixed checkout button + BottomNavigationBar in a single area
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkout button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ignore: avoid_print
                    print('Proceed to Checkout: Pay ₹${_formatMoney(total)}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Proceeding to checkout — ₹${_formatMoney(total)}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Proceed to Checkout — ₹${_formatMoney(total)}',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Divider between button and nav
          const Divider(height: 1, thickness: 0.5),
          // Bottom nav
          BottomNavigationBar(
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
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    // Simple formatter: 7930.0 -> 7,930.00
    final str = value.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final reg = RegExp(r'(\d+)(\d{3})');
    String formatted = intPart;
    while (reg.hasMatch(formatted)) {
      formatted = formatted.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return '$formatted.$decPart';
  }
}

class _Header extends StatelessWidget {
  final int itemCount;
  final VoidCallback onClearAll;

  const _Header({
    required this.itemCount,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    const headerHeight = 180.0;

    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Text(
                  'My Cart',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: onClearAll,
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.delete_sweep_outlined, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: 0.85,
              child: const Text(
                'Review your selected items before checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.85)),
              ),
              child: Text(
                '$itemCount item${itemCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
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
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: AppTheme.textGrey.withOpacity(0.2),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 28, color: AppTheme.textGrey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Price and duration
                Row(
                  children: [
                    Text(
                      '₹${item.pricePerDay}/day',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(x ${item.days} day${item.days == 1 ? '' : 's'})',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quantity + Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Delete
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(18),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.delete_outline, color: AppTheme.textGrey, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              // Qty selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyIcon(
                      icon: Icons.remove,
                      onTap: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QtyIcon(
                      icon: Icons.add,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.textDark,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double subtotal;
  final double serviceFee;
  final double taxes;
  final double total;

  const _SummaryCard({
    required this.subtotal,
    required this.serviceFee,
    required this.taxes,
    required this.total,
  });

  String _formatMoney(double value) {
    final str = value.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final reg = RegExp(r'(\d+)(\d{3})');
    String formatted = intPart;
    while (reg.hasMatch(formatted)) {
      formatted = formatted.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return '$formatted.$decPart';
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textDark,
            fontSize: bold ? 15.5 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
          _row('Subtotal', '₹${_formatMoney(subtotal)}'),
          const SizedBox(height: 8),
          _row('Service fee', '₹${_formatMoney(serviceFee)}'),
          const SizedBox(height: 8),
          _row('Taxes', '₹${_formatMoney(taxes)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _row(
            'Total',
            '₹${_formatMoney(total)}',
            bold: true,
            valueColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
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
          const Icon(Icons.local_offer_outlined, color: AppTheme.textDark),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Apply promo code',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // ignore: avoid_print
              print('Apply promo code tapped');
            },
            borderRadius: BorderRadius.circular(18),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.chevron_right, color: AppTheme.textGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final int pricePerDay;
  final int days;
  final int quantity;

  CartItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.pricePerDay,
    required this.days,
    required this.quantity,
  });

  CartItem copyWith({
    String? title,
    String? subtitle,
    String? imageUrl,
    int? pricePerDay,
    int? days,
    int? quantity,
  }) {
    return CartItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      days: days ?? this.days,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Content-only version for embedding inside MainNavigationScreen tab (no bottom nav / checkout button)
class CartScreenContent extends StatefulWidget {
  const CartScreenContent({super.key});

  @override
  State<CartScreenContent> createState() => _CartScreenContentState();
}

class _CartScreenContentState extends State<CartScreenContent> {
  final List<CartItem> _items = [
    CartItem(
      title: 'Premium BBQ Grill Set',
      subtitle: 'BBQ Equipment',
      imageUrl:
          'https://images.unsplash.com/photo-1558036117-15d82a90b9b9?w=600',
      pricePerDay: 2500,
      days: 1,
      quantity: 1,
    ),
    CartItem(
      title: 'Floral Stage Decor',
      subtitle: 'Decor • Indoor',
      imageUrl:
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=600',
      pricePerDay: 3200,
      days: 1,
      quantity: 1,
    ),
  ];

  double get subtotal => _items.fold<double>(
        0,
        (sum, item) => sum + (item.pricePerDay * item.days * item.quantity),
      );
  double get serviceFee => 250.0;
  double get taxes => subtotal * 0.05;
  double get total => subtotal + serviceFee + taxes;

  void _incrementQty(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    });
  }

  void _decrementQty(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _Header(itemCount: _items.length, onClearAll: _clearAll),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: _items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _CartItemCard(
                  item: item,
                  onDecrement: () => _decrementQty(index),
                  onIncrement: () => _incrementQty(index),
                  onDelete: () => _deleteItem(index),
                );
              },
            ),
            const _CouponRow(),
            _SummaryCard(
              subtotal: subtotal,
              serviceFee: serviceFee,
              taxes: taxes,
              total: total,
            ),
            const SizedBox(height: 12),
            // Checkout button within tab content
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // ignore: avoid_print
                      print('Proceed to Checkout: Pay ₹${_formatMoney(total)}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Proceeding to checkout — ₹${_formatMoney(total)}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Proceed to Checkout — ₹${_formatMoney(total)}',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double value) {
    final str = value.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final reg = RegExp(r'(\d+)(\d{3})');
    String formatted = intPart;
    while (reg.hasMatch(formatted)) {
      formatted = formatted.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return '$formatted.$decPart';
  }
}