import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/models/cart_item.dart';

/// Repository for managing cart state (in-memory for now, can sync to backend later)
class CartRepository extends ChangeNotifier {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get serviceFee => 250.0; // Fixed fee

  double get taxes => subtotal * 0.05; // 5% tax

  double get total => subtotal + serviceFee + taxes;

  bool get isEmpty => _items.isEmpty;

  /// Add item to cart or update quantity if already exists
  void addItem({
    required String listingId,
    required String title,
    required String subtitle,
    required String imageUrl,
    required double pricePerDay,
    int days = 1,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere((item) => item.listingId == listingId && item.days == days);
    
    if (existingIndex >= 0) {
      // Update quantity if item already exists
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(CartItem(
        listingId: listingId,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        pricePerDay: pricePerDay,
        days: days,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  /// Remove item from cart
  void removeItem(String listingId, int days) {
    _items.removeWhere((item) => item.listingId == listingId && item.days == days);
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String listingId, int days, int quantity) {
    if (quantity <= 0) {
      removeItem(listingId, days);
      return;
    }
    
    final index = _items.indexWhere((item) => item.listingId == listingId && item.days == days);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get cart item by listing ID and days
  CartItem? getItem(String listingId, int days) {
    try {
      return _items.firstWhere((item) => item.listingId == listingId && item.days == days);
    } catch (e) {
      return null;
    }
  }
}

