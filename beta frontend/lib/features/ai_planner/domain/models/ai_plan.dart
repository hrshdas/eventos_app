/// AI-generated plan response model matching backend API
class AiPlanResponse {
  final AiPlan plan;
  final Map<String, int> matchingCounts;
  final String generatedBy;
  final DateTime timestamp;

  AiPlanResponse({
    required this.plan,
    required this.matchingCounts,
    required this.generatedBy,
    required this.timestamp,
  });

  factory AiPlanResponse.fromJson(Map<String, dynamic> json) {
    return AiPlanResponse(
      plan: AiPlan.fromJson(json['plan'] as Map<String, dynamic>),
      matchingCounts: Map<String, int>.from(json['matchingCounts'] as Map),
      generatedBy: json['generatedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.toJson(),
      'matchingCounts': matchingCounts,
      'generatedBy': generatedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isAIGenerated => generatedBy == 'ai';
  int get totalMatches => matchingCounts['total'] ?? 0;
}

/// AI Plan model
class AiPlan {
  final String theme;
  final List<String> decor;
  final List<String> food;
  final List<String> music;
  final List<String> recommendedCategories;

  AiPlan({
    required this.theme,
    required this.decor,
    required this.food,
    required this.music,
    required this.recommendedCategories,
  });

  factory AiPlan.fromJson(Map<String, dynamic> json) {
    return AiPlan(
      theme: json['theme'] as String,
      decor: List<String>.from(json['decor'] as List),
      food: List<String>.from(json['food'] as List),
      music: List<String>.from(json['music'] as List),
      recommendedCategories: List<String>.from(json['recommendedCategories'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'decor': decor,
      'food': food,
      'music': music,
      'recommendedCategories': recommendedCategories,
    };
  }
}
