import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import '../widgets/eventos_logo_svg.dart';

class PackageDetailsScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final double rating;
  final int soldCount;
  final String price;

  const PackageDetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.soldCount,
    required this.price,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  int _currentIndex = 0;
  int _quantity = 1;
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              const _HeroImage(
                imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
              ),
              const _DetailsCard(),
              const SizedBox(height: 24),
              const _RecommendedSection(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // Navigate back to MainNavigationScreen with the selected index
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(initialIndex: index),
          ),
          (route) => false,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textGrey,
      backgroundColor: AppTheme.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bolt),
          label: 'AI Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'My Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Header with Pink Background
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4F6D),
            Color(0xFFFF6B5A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Welcome and Location
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hi, Welcome 👋',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Mumbai, India',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: App Logo
          const EventosLogoSvg(height: 36, color: AppTheme.white),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Hero Image
class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          height: 350,
          width: double.infinity,
          color: AppTheme.textGrey.withOpacity(0.2),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.textGrey.withOpacity(0.2),
                child: const Icon(Icons.image, size: 100),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Details Card
class _DetailsCard extends StatefulWidget {
  const _DetailsCard();

  @override
  State<_DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<_DetailsCard> {
  int _quantity = 1;
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'CLASSIC GOLD AND WHITE DECOR',
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Rating Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _RatingRow(
              rating: 4.9,
              soldCount: 1200,
              quantity: _quantity,
              onQuantityChanged: (newQuantity) {
                setState(() {
                  _quantity = newQuantity;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Description Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _DescriptionSection(
              showFull: _showFullDescription,
              onToggle: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ActionButtonsRow(),
          ),
          const SizedBox(height: 16),
          // Divider
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E5E5),
          ),
        ],
      ),
      ),
    );
  }
}

// Rating Row with Quantity Selector
class _RatingRow extends StatelessWidget {
  final double rating;
  final int soldCount;
  final int quantity;
  final Function(int) onQuantityChanged;

  const _RatingRow({
    required this.rating,
    required this.soldCount,
    required this.quantity,
    required this.onQuantityChanged,
  });

  String _formatSoldCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rating
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.textGrey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_formatSoldCount(soldCount)} sold',
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        // Quantity Selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
                icon: const Icon(Icons.remove, size: 18),
                color: AppTheme.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onQuantityChanged(quantity + 1),
                icon: const Icon(Icons.add, size: 18),
                color: AppTheme.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Description Section
class _DescriptionSection extends StatelessWidget {
  final bool showFull;
  final VoidCallback onToggle;

  const _DescriptionSection({
    required this.showFull,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const fullDescription =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';
    
    const shortDescription =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud ex...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showFull ? fullDescription : shortDescription,
          style: const TextStyle(
            color: Color(0xFF6F6F6F),
            fontSize: 14,
            height: 1.5,
          ),
          maxLines: showFull ? null : 3,
          overflow: showFull ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            showFull ? 'See less' : 'See more',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Action Buttons Row
class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Add to Cart Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppTheme.textGrey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppTheme.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppTheme.textDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add to cart',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Order Now Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Order Now',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Recommended Section
class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    final recommendedItems = [
      {
        'title': 'Premium BBQ Grill Set',
        'rating': 4.5,
        'reviews': 128,
        'price': '₹2,500/day',
        'imageUrl': 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400',
      },
      {
        'title': 'Professional DJ Equipment',
        'rating': 4.8,
        'reviews': 256,
        'price': '₹8,000/event',
        'imageUrl': 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended for your event',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'VIEW ALL',
                      style: AppTheme.viewAllText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _RecommendedCard(
                  title: recommendedItems[0]['title'] as String,
                  rating: recommendedItems[0]['rating'] as double,
                  reviews: recommendedItems[0]['reviews'] as int,
                  price: recommendedItems[0]['price'] as String,
                  imageUrl: recommendedItems[0]['imageUrl'] as String,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RecommendedCard(
                  title: recommendedItems[1]['title'] as String,
                  rating: recommendedItems[1]['rating'] as double,
                  reviews: recommendedItems[1]['reviews'] as int,
                  price: recommendedItems[1]['price'] as String,
                  imageUrl: recommendedItems[1]['imageUrl'] as String,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Recommended Card
class _RecommendedCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviews;
  final String price;
  final String imageUrl;

  const _RecommendedCard({
    required this.title,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsScreen(
              title: title,
              imageUrl: imageUrl,
              rating: rating,
              soldCount: reviews * 10,
              price: price,
            ),
          ),
        );
      },
      child: Container(
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
                  height: 110,
                  width: double.infinity,
                  color: AppTheme.textGrey.withOpacity(0.2),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.textGrey.withOpacity(0.2),
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                // Available Tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                SizedBox(
                  height: 32,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '$rating ($reviews)',
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Price
                Text(
                  price,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkNavy,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 11,
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
