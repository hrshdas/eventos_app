import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    required this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
    );
  }
}

class NotificationsRepository {
  final ApiClient _api;
  NotificationsRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<List<NotificationItem>> getNotifications({String? cursor, int limit = 20}) async {
    try {
      final resp = await _api.get('/notifications', queryParameters: {
        if (cursor != null) 'cursor': cursor,
        // Intentionally omit 'limit' to avoid backend receiving it as a string and passing it to Prisma
      });
      final list = (resp['data'] as List<dynamic>? ?? [])
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(message: 'Failed to load notifications: $e');
    }
  }

  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.patch('/notifications/read-all');
  }
}
