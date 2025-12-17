import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/models/cart_item.dart';

/// Repository for managing cart state (in-memory for now, can sync to backend later)
class CartRepository extends ChangeNotifier {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  final List<CartItem> _items = [];

  // Promo state
  String? _promoCode;
  double _discount = 0.0; // absolute amount applied to subtotal
  bool _freeServiceFee = false;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Current discount (absolute amount) derived from promo
  double get discount => _discount.clamp(0.0, subtotal);

  /// Current promo code, if any
  String? get promoCode => _promoCode;

  double get serviceFee => _freeServiceFee ? 0.0 : 250.0; // Fixed fee unless promo waives it

  // Taxes applied on discounted subtotal
  double get taxes => (subtotal - discount) * 0.05; // 5% tax

  double get total => (subtotal - discount) + serviceFee + taxes;

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
    _recalculatePromo();
    notifyListeners();
  }

  /// Remove item from cart
  void removeItem(String listingId, int days) {
    _items.removeWhere((item) => item.listingId == listingId && item.days == days);
    _recalculatePromo();
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
      _recalculatePromo();
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    _promoCode = null;
    _discount = 0.0;
    _freeServiceFee = false;
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

  /// Apply a promo code. Returns true if applied, false if invalid.
  /// Supported codes:
  /// - SAVE10: 10% off subtotal, up to ₹1000
  /// - FLAT200: flat ₹200 off if subtotal ≥ ₹1000
  /// - FREESHIP: waives service fee
  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    bool applied = false;
    _promoCode = null;
    _discount = 0.0;
    _freeServiceFee = false;

    final sub = subtotal;
    switch (c) {
      case 'SAVE10':
        _discount = (sub * 0.10);
        if (_discount > 1000.0) _discount = 1000.0;
        applied = _discount > 0;
        break;
      case 'FLAT200':
        if (sub >= 1000.0) {
          _discount = 200.0;
          applied = true;
        }
        break;
      case 'FREESHIP':
        _freeServiceFee = true;
        applied = true;
        break;
      default:
        applied = false;
    }

    if (applied) {
      _promoCode = c;
      notifyListeners();
      return true;
    } else {
      // Reset
      _promoCode = null;
      _discount = 0.0;
      _freeServiceFee = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove any applied promo
  void removePromo() {
    _promoCode = null;
    _discount = 0.0;
    _freeServiceFee = false;
    notifyListeners();
  }

  void _recalculatePromo() {
    if (_promoCode == null) return;
    final code = _promoCode!;
    // Re-apply same promo on new subtotal
    applyPromo(code);
  }
}
