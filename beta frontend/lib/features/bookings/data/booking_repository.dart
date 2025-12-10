import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../domain/models/booking.dart';

/// Repository for managing bookings
class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Create a new booking
  /// 
  /// [listingId] - ID of the listing to book
  /// [startDate] - Start date/time of the booking
  /// [endDate] - End date/time of the booking (optional for single-day bookings)
  /// [numberOfGuests] - Number of guests (optional)
  /// [additionalData] - Any additional booking data
  Future<Booking> createBooking({
    required String listingId,
    required DateTime startDate,
    DateTime? endDate,
    int? numberOfGuests,
    double? totalPrice,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final startUtc = DateTime.utc(startDate.year, startDate.month, startDate.day);
      final endBase = endDate ?? startDate.add(const Duration(days: 1));
      final endUtc = DateTime.utc(endBase.year, endBase.month, endBase.day);

      final bookingData = {
        'listingId': listingId,
        'startDate': startUtc.toIso8601String(),
        'endDate': endUtc.toIso8601String(),
        if (numberOfGuests != null) 'numberOfGuests': numberOfGuests,
        if (totalPrice != null) 'totalPrice': totalPrice,
        if (additionalData != null) ...additionalData,
      };

      final response = await _apiClient.post(
        '/bookings',
        data: bookingData,
      );

      // Handle different response formats
      Map<String, dynamic> bookingJson;
      if (response['data'] is Map<String, dynamic>) {
        bookingJson = response['data'] as Map<String, dynamic>;
      } else {
        bookingJson = response;
      }

      return Booking.fromJson(bookingJson);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to create booking: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get all bookings for the current user
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiClient.get('/bookings/my');

      // Handle different response formats
      List<dynamic> bookingsData;
      if (response['data'] is List) {
        bookingsData = response['data'] as List<dynamic>;
      } else if (response['bookings'] is List) {
        bookingsData = response['bookings'] as List<dynamic>;
      } else if (response is List<dynamic>) {
        bookingsData = response as List<dynamic>;
      } else {
        bookingsData = [];
      }

      return bookingsData
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to fetch bookings: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get bookings for listings owned by the current owner (OWNER or ADMIN)
  Future<List<Booking>> getOwnerBookings() async {
    try {
      final response = await _apiClient.get('/bookings/owner');

      List<dynamic> bookingsData;
      if (response['data'] is List) {
        bookingsData = response['data'] as List<dynamic>;
      } else if (response['bookings'] is List) {
        bookingsData = response['bookings'] as List<dynamic>;
      } else if (response is List<dynamic>) {
        bookingsData = response as List<dynamic>;
      } else {
        bookingsData = [];
      }

      return bookingsData
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to fetch owner bookings: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update booking status (OWNER/ADMIN only): CONFIRMED or CANCELLED
  Future<Booking> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/bookings/$bookingId/status',
        data: {'status': status},
      );

      Map<String, dynamic> bookingJson;
      if (response['data'] is Map<String, dynamic>) {
        bookingJson = response['data'] as Map<String, dynamic>;
      } else {
        bookingJson = response;
      }

      return Booking.fromJson(bookingJson);
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to update booking status: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
