import '../../../core/api/api_client.dart';
import '../../../core/api/app_api_exception.dart';
import '../domain/models/ai_planner_request.dart';
import '../domain/models/ai_plan.dart';

/// Repository for AI Planner functionality
class AiPlannerRepository {
  final ApiClient _apiClient;

  AiPlannerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Generate an AI plan based on the request
  Future<AiPlan> generatePlan(AiPlannerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/ai-planner/suggest',
        data: request.toJson(),
      );

      return AiPlan.fromJson(response);
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

