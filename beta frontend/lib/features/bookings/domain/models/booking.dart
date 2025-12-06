/// Booking model representing a user's booking
class Booking {
  final String id;
  final String listingId;
  final String? listingTitle;
  final String? listingImageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? numberOfGuests;
  final double? totalPrice;
  final String status; // e.g., 'pending', 'confirmed', 'cancelled'
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata; // Additional booking details

  Booking({
    required this.id,
    required this.listingId,
    this.listingTitle,
    this.listingImageUrl,
    this.startDate,
    this.endDate,
    this.numberOfGuests,
    this.totalPrice,
    this.status = 'pending',
    this.createdAt,
    this.metadata,
  });

  /// Create Booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      listingId: json['listingId']?.toString() ?? json['listing']?.toString() ?? '',
      listingTitle: json['listingTitle']?.toString(),
      listingImageUrl: json['listingImageUrl']?.toString(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      numberOfGuests: json['numberOfGuests'] != null
          ? (json['numberOfGuests'] is num
              ? json['numberOfGuests'].toInt()
              : int.tryParse(json['numberOfGuests'].toString()))
          : json['guests'] != null
              ? (json['guests'] is num ? json['guests'].toInt() : int.tryParse(json['guests'].toString()))
              : null,
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice'] is num
              ? json['totalPrice'].toDouble()
              : double.tryParse(json['totalPrice'].toString()))
          : null,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  /// Convert Booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (numberOfGuests != null) 'numberOfGuests': numberOfGuests,
      if (totalPrice != null) 'totalPrice': totalPrice,
      if (status.isNotEmpty) 'status': status,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

