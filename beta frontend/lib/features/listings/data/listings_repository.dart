import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../domain/models/listing.dart';

/// Repository for managing listings
class ListingsRepository {
  final ApiClient _apiClient;

  ListingsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all listings with optional filters
  /// 
  /// [filters] can include:
  /// - category: filter by category (e.g., 'venue', 'decoration', 'rental')
  /// - search: search query string
  /// - minPrice, maxPrice: price range
  /// - location: location filter
  /// - status: filter by status (e.g., 'APPROVED', 'PENDING') - backend should filter APPROVED by default for public listings
  /// - page, limit: pagination parameters
  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    try {
      // By default, only show APPROVED listings for public view
      // Backend should handle this, but we can also filter client-side if needed
      final queryParams = Map<String, dynamic>.from(filters ?? {});
      if (!queryParams.containsKey('status') && !queryParams.containsKey('includePending')) {
        // Backend should filter by APPROVED by default, but we don't set it here
        // to allow backend flexibility. Backend API should return only APPROVED listings
        // for GET /listings unless status filter is explicitly provided
      }
      
      final response = await _apiClient.get(
        '/listings',
        queryParameters: queryParams,
      );

      // Handle different response formats
      List<dynamic> listingsData;
      if (response['data'] is Map && (response['data'] as Map)['listings'] is List) {
        // Response format: { data: { listings: [...] } }
        listingsData = (response['data'] as Map)['listings'] as List<dynamic>;
      } else if (response['data'] is List) {
        listingsData = response['data'] as List<dynamic>;
      } else if (response['listings'] is List) {
        listingsData = response['listings'] as List<dynamic>;
      } else if (response is List<dynamic>) {
        listingsData = response as List<dynamic>;
      } else {
        listingsData = [];
      }

      return listingsData
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to fetch listings: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get a single listing by ID
  Future<Listing> getListingDetail(String id) async {
    try {
      final response = await _apiClient.get('/listings/$id');

      // Handle different response formats
      Map<String, dynamic> listingData;
      if (response['data'] is Map<String, dynamic>) {
        listingData = response['data'] as Map<String, dynamic>;
      } else {
        listingData = response;
      }

      return Listing.fromJson(listingData);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to fetch listing details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Create a new listing
  /// 
  /// [files] - List of image files to upload
  Future<Listing> createListing({
    required String title,
    required String description,
    required String category,
    required String city,
    required String pincode,
    required DateTime date,
    String? time,
    double? price,
    String? priceUnit,
    int? capacity,
    List<File>? files,
  }) async {
    try {
      // Validate required fields
      if (title.isEmpty) {
        throw AppApiException(
          message: 'Title is required',
          statusCode: 400,
        );
      }
      if (description.isEmpty) {
        throw AppApiException(
          message: 'Description is required',
          statusCode: 400,
        );
      }
      if (category.isEmpty) {
        throw AppApiException(
          message: 'Category is required',
          statusCode: 400,
        );
      }
      if (city.isEmpty) {
        throw AppApiException(
          message: 'City is required',
          statusCode: 400,
        );
      }
      if (pincode.isEmpty) {
        throw AppApiException(
          message: 'Pincode is required',
          statusCode: 400,
        );
      }
      if (price == null || price <= 0) {
        throw AppApiException(
          message: 'Price must be greater than 0',
          statusCode: 400,
        );
      }

      // Prepare form data - match backend API expectations
      // Backend expects: title, description, category, city, pincode, date, time (optional), price (optional), capacity (optional)
      // Note: When using FormData, Dio converts all values to strings
      final formData = <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'city': city,
        'pincode': pincode,
        'date': date.toIso8601String(),
        'price': price.toInt(), // Send as int - Dio FormData will convert to string automatically
      };

      // Add optional fields if provided
      if (time != null && time.isNotEmpty) {
        formData['time'] = time;
      }
      if (capacity != null && capacity > 0) {
        formData['capacity'] = capacity;
      }
      
      debugPrint('ListingsRepository.createListing: Sending formData: $formData');
      debugPrint('ListingsRepository.createListing: Files count: ${files?.length ?? 0}');

      final response = await _apiClient.postMultipart(
        '/listings',
        data: formData,
        files: files,
        fileFieldName: 'images',
      );

      // Handle response
      Map<String, dynamic> listingData;
      if (response['data'] is Map<String, dynamic>) {
        listingData = response['data'] as Map<String, dynamic>;
      } else {
        listingData = response;
      }

      return Listing.fromJson(listingData);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to create listing: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update an existing listing
  /// 
  /// [files] - New image files to add (existing images are preserved unless removed)
  Future<Listing> updateListing({
    required String id,
    String? title,
    String? description,
    String? category,
    String? city,
    String? pincode,
    DateTime? date,
    String? time,
    double? price,
    String? priceUnit,
    int? capacity,
    List<File>? files,
    List<String>? removeImageUrls, // URLs of images to remove
  }) async {
    try {
      // Prepare form data
      final formData = <String, dynamic>{};
      if (title != null) formData['title'] = title;
      if (description != null) formData['description'] = description;
      if (category != null) formData['category'] = category;
      if (city != null) formData['city'] = city;
      if (pincode != null) formData['pincode'] = pincode;
      if (date != null) formData['date'] = date.toIso8601String();
      if (time != null) formData['time'] = time;
      if (price != null) formData['price'] = price;
      if (priceUnit != null) formData['priceUnit'] = priceUnit;
      if (capacity != null) formData['capacity'] = capacity;
      if (removeImageUrls != null && removeImageUrls.isNotEmpty) {
        formData['removeImageUrls'] = removeImageUrls;
      }

      final response = await _apiClient.patchMultipart(
        '/listings/$id',
        data: formData,
        files: files,
        fileFieldName: 'images',
      );

      // Handle response
      Map<String, dynamic> listingData;
      if (response['data'] is Map<String, dynamic>) {
        listingData = response['data'] as Map<String, dynamic>;
      } else {
        listingData = response;
      }

      return Listing.fromJson(listingData);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to update listing: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a listing
  Future<void> deleteListing(String id) async {
    try {
      await _apiClient.delete('/listings/$id');
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to delete listing: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get all listings created by the current user
  /// Note: Backend needs ownerId to be passed. This method should be called with ownerId in filters.
  /// Alternatively, backend could implement GET /listings/my endpoint
  Future<List<Listing>> getMyListings({Map<String, dynamic>? filters, String? ownerId}) async {
    try {
      final queryParams = Map<String, dynamic>.from(filters ?? {});
      
      // Add ownerId to query if provided
      if (ownerId != null) {
        queryParams['ownerId'] = ownerId;
      }
      
      // Use the standard getListings method with ownerId filter
      return await getListings(filters: queryParams);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to fetch my listings: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

