import 'package:flutter/material.dart';
import '../features/listings/domain/models/listing.dart';
import '../features/listings/data/listings_repository.dart';
import '../core/api/app_api_exception.dart';
import '../theme/app_theme.dart';
import 'listing_card.dart';

/// Reusable widget that displays listings with loading and error states
class ListingsList extends StatefulWidget {
  final Map<String, dynamic>? filters;
  final int? itemLimit;
  final bool horizontal;
  final double? height;
  final ValueChanged<Listing>? onListingTap;
  final ValueChanged<Listing>? onBookNow;
  final ValueChanged<Listing>? onAddToCart;
  final GlobalKey<_ListingsListState>? refreshKey; // Key to trigger refresh from parent

  const ListingsList({
    super.key,
    this.filters,
    this.itemLimit,
    this.horizontal = false,
    this.height,
    this.onListingTap,
    this.onBookNow,
    this.onAddToCart,
    this.refreshKey,
  });

  @override
  State<ListingsList> createState() => _ListingsListState();
}

class _ListingsListState extends State<ListingsList> {
  final ListingsRepository _repo = ListingsRepository();
  List<Listing> _listings = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void didUpdateWidget(ListingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if filters changed
    if (widget.filters != oldWidget.filters || widget.itemLimit != oldWidget.itemLimit) {
      _loadListings();
    }
  }

  /// Public method to refresh listings (can be called via GlobalKey from parent)
  void refresh() {
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Create a mutable copy of filters to avoid "Cannot modify unmodifiable map" error
      final filters = Map<String, dynamic>.from(widget.filters ?? {});
      if (widget.itemLimit != null) {
        filters['limit'] = widget.itemLimit;
      }
      final listings = await _repo.getListings(filters: filters);
      setState(() {
        _listings = listings;
        _loading = false;
      });
    } on AppApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: widget.height ?? 260,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.height ?? 260,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.textGrey,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: AppTheme.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadListings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return SizedBox(
        height: widget.height ?? 260,
        child: const Center(
          child: Text(
            'No listings available',
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ),
      );
    }

    if (widget.horizontal) {
      return SizedBox(
        height: widget.height ?? 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _listings.length,
          itemBuilder: (context, index) {
            return ListingCard(
              listing: _listings[index],
              onTap: widget.onListingTap != null ? () => widget.onListingTap!(_listings[index]) : null,
              onBookNow: widget.onBookNow != null ? () => widget.onBookNow!(_listings[index]) : null,
              onAddToCart: widget.onAddToCart != null ? () => widget.onAddToCart!(_listings[index]) : null,
            );
          },
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        return ListingCard(
          listing: _listings[index],
          onTap: widget.onListingTap != null ? () => widget.onListingTap!(_listings[index]) : null,
          onBookNow: widget.onBookNow != null ? () => widget.onBookNow!(_listings[index]) : null,
          onAddToCart: widget.onAddToCart != null ? () => widget.onAddToCart!(_listings[index]) : null,
        );
      },
    );
  }
}

