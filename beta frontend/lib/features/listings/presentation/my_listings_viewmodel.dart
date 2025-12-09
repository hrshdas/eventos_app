import 'package:flutter/foundation.dart';
import '../data/listings_repository.dart';
import '../domain/models/listing.dart';
import '../../../core/api/app_api_exception.dart';

/// ViewModel for managing My Listings screen state
class MyListingsViewModel extends ChangeNotifier {
  final ListingsRepository _repository;

  MyListingsViewModel({ListingsRepository? repository})
      : _repository = repository ?? ListingsRepository();

  List<Listing> _myListings = [];
  bool _isLoading = false;
  String? _error;

  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => !_isLoading && _error == null && _myListings.isEmpty;

  /// Load listings for the current user
  Future<void> loadMyListings(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listings = await _repository.getMyListings(ownerId: ownerId);
      _myListings = listings;
      _error = null;
    } on AppApiException catch (e) {
      _error = e.message;
      _myListings = [];
    } catch (e) {
      _error = 'Failed to load listings: ${e.toString()}';
      _myListings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a listing
  Future<bool> deleteListing(String id) async {
    try {
      await _repository.deleteListing(id);
      // Remove from local list
      _myListings.removeWhere((listing) => listing.id == id);
      notifyListeners();
      return true;
    } on AppApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete listing: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

