/// Listing model representing a service/item available for booking
class Listing {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String>? images; // Multiple images
  final String category; // e.g., 'venue', 'decoration', 'rental', 'package'
  final double? price;
  final String? priceUnit; // e.g., 'per day', 'per event', 'per hour'
  final double? rating;
  final int? reviewCount;
  final bool? isAvailable;
  final DateTime? date; // Event date
  final String? time; // Event time
  final String? city; // City
  final String? pincode; // Pincode
  final int? capacity; // Capacity/guests
  final String? createdBy; // User ID who created the listing
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata; // Additional fields

  Listing({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.images,
    required this.category,
    this.price,
    this.priceUnit,
    this.rating,
    this.reviewCount,
    this.isAvailable,
    this.date,
    this.time,
    this.city,
    this.pincode,
    this.capacity,
    this.createdBy,
    this.status = 'PENDING',
    this.createdAt,
    this.metadata,
  });

  /// Create Listing from JSON
  factory Listing.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<String>? imagesList;
    if (json['images'] is List) {
      imagesList = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['imageUrl'] != null || json['image'] != null) {
      // Fallback to single imageUrl for backward compatibility
      imagesList = [json['imageUrl']?.toString() ?? json['image']?.toString() ?? ''];
    }

    // Parse date
    DateTime? parsedDate;
    if (json['date'] != null) {
      if (json['date'] is DateTime) {
        parsedDate = json['date'] as DateTime;
      } else {
        parsedDate = DateTime.tryParse(json['date'].toString());
      }
    }

    // Parse createdAt
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is DateTime) {
        parsedCreatedAt = json['createdAt'] as DateTime;
      } else {
        parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
      }
    }

    return Listing(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      images: imagesList,
      category: json['category']?.toString() ?? 'other',
      price: json['price'] != null
          ? (json['price'] is num ? json['price'].toDouble() : double.tryParse(json['price'].toString()))
          : null,
      priceUnit: json['priceUnit']?.toString() ?? json['unit']?.toString(),
      rating: json['rating'] != null
          ? (json['rating'] is num ? json['rating'].toDouble() : double.tryParse(json['rating'].toString()))
          : null,
      reviewCount: json['reviewCount'] != null
          ? (json['reviewCount'] is num
              ? json['reviewCount'].toInt()
              : int.tryParse(json['reviewCount'].toString()))
          : json['reviews'] != null
              ? (json['reviews'] is num ? json['reviews'].toInt() : int.tryParse(json['reviews'].toString()))
              : null,
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      date: parsedDate,
      time: json['time']?.toString(),
      city: json['city']?.toString(),
      pincode: json['pincode']?.toString(),
      capacity: json['capacity'] != null
          ? (json['capacity'] is num ? json['capacity'].toInt() : int.tryParse(json['capacity'].toString()))
          : null,
      createdBy: json['createdBy']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: parsedCreatedAt,
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  /// Convert Listing to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (images != null) 'images': images,
      'category': category,
      if (price != null) 'price': price,
      if (priceUnit != null) 'priceUnit': priceUnit,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (date != null) 'date': date!.toIso8601String(),
      if (time != null) 'time': time,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (capacity != null) 'capacity': capacity,
      if (createdBy != null) 'createdBy': createdBy,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Get primary image URL (first from images array, fallback to imageUrl)
  String? get primaryImageUrl {
    if (images != null && images!.isNotEmpty) {
      return images!.first;
    }
    return imageUrl;
  }

  /// Copy with method for updating fields
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? images,
    String? category,
    double? price,
    String? priceUnit,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? date,
    String? time,
    String? city,
    String? pincode,
    int? capacity,
    String? createdBy,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      category: category ?? this.category,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      date: date ?? this.date,
      time: time ?? this.time,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      capacity: capacity ?? this.capacity,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    if (price == null) return 'Price on request';
    final unit = priceUnit ?? '';
    return '₹${price!.toStringAsFixed(0)}${unit.isNotEmpty ? '/$unit' : ''}';
  }
}

