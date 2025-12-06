/// Cart item model representing an item in the shopping cart
class CartItem {
  final String listingId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double pricePerDay;
  final int days;
  int quantity;

  CartItem({
    required this.listingId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.pricePerDay,
    required this.days,
    required this.quantity,
  });

  CartItem copyWith({
    String? listingId,
    String? title,
    String? subtitle,
    String? imageUrl,
    double? pricePerDay,
    int? days,
    int? quantity,
  }) {
    return CartItem(
      listingId: listingId ?? this.listingId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      days: days ?? this.days,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => pricePerDay * days * quantity;

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'days': days,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      listingId: json['listingId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      days: json['days'] as int,
      quantity: json['quantity'] as int,
    );
  }
}

