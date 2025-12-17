import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../domain/models/ai_planner_request.dart';
import '../domain/models/ai_plan.dart';

/// Repository for AI Planner functionality
class AiPlannerRepository {
  final ApiClient _apiClient;

  AiPlannerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Generate an AI plan based on the request
  Future<AiPlanResponse> generatePlan(AiPlannerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/ai/plan',
        data: request.toJson(),
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw TimeoutException('AI request timed out. Please try again.');
        },
      );

      // Handle the response structure
      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          return AiPlanResponse.fromJson(response['data'] as Map<String, dynamic>);
        } else if (response['success'] == false) {
          throw AppApiException(
            message: response['error']?.toString() ?? 'Failed to generate plan',
            statusCode: response['code'] == 'AI_RATE_LIMIT_EXCEEDED' ? 429 : 400,
          );
        }
      }

      // Fallback: try to parse directly
      return AiPlanResponse.fromJson(response as Map<String, dynamic>);
    } on TimeoutException catch (e) {
      throw AppApiException(
        message: 'Request timed out. Please try again.',
        originalError: e,
      );
    } on AppApiException {
      rethrow;
    } catch (e) {
      throw AppApiException(
        message: 'Failed to generate AI plan: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Custom exception for AI-specific errors
class AIException implements Exception {
  final String message;
  AIException(this.message);

  @override
  String toString() => message;
}
