import 'package:flutter/material.dart';
import '../features/listings/domain/models/listing.dart';
import '../theme/app_theme.dart';
import '../screens/package_details_screen.dart';
import '../api/api_config.dart';
import '../features/cart/data/cart_repository.dart';

/// Reusable listing card widget
class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;
  final VoidCallback? onAddToCart;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onBookNow,
    this.onAddToCart,
  });

  String _buildImageUrl(String? path, List<String>? images) {
    String? candidate;
    if (images != null && images.isNotEmpty) {
      candidate = images.first;
    } else if (path != null && path.isNotEmpty) {
      candidate = path;
    }
    if (candidate == null || candidate.isEmpty) return '';
    return candidate.startsWith('http') ? candidate : '$apiPublicBase/$candidate';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsScreen(
              listingId: listing.id,
              title: listing.title,
              imageUrl: listing.imageUrl ?? '',
              rating: listing.rating ?? 0,
              soldCount: (listing.reviewCount ?? 0),
              price: listing.formattedPrice,
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: AppTheme.textGrey.withOpacity(0.2),
                    child: Builder(
                      builder: (context) {
                        final img = _buildImageUrl(listing.imageUrl, listing.images);
                        if (img.isEmpty) {
                          return Container(
                            color: AppTheme.textGrey.withOpacity(0.2),
                            child: const Icon(Icons.image, size: 50),
                          );
                        }
                        return Image.network(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.textGrey.withOpacity(0.2),
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTheme.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (listing.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      listing.description!,
                      style: AppTheme.cardSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (listing.rating != null) ...[
                    const SizedBox(height: 3),
                    // Rating Stars
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < (listing.rating!.round()) ? Icons.star : Icons.star_border,
                          color: AppTheme.starColor,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onBookNow ?? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PackageDetailsScreen(
                              listingId: listing.id,
                              title: listing.title,
                              imageUrl: listing.imageUrl ?? '',
                              rating: listing.rating ?? 0,
                              soldCount: (listing.reviewCount ?? 0),
                              price: listing.formattedPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Book Now',
                        style: AppTheme.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onAddToCart ?? () {
                        CartRepository().addItem(
                          listingId: listing.id,
                          title: listing.title,
                          subtitle: listing.description ?? '',
                          imageUrl: _buildImageUrl(listing.imageUrl, listing.images),
                          pricePerDay: listing.price ?? 0,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
