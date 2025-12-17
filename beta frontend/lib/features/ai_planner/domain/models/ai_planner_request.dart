/// Request model for AI Planner API matching backend schema
class AiPlannerRequest {
  final String eventType;
  final String location;
  final String guests;
  final double budget;
  final String date;
  final String? description;

  AiPlannerRequest({
    required this.eventType,
    required this.location,
    required this.guests,
    required this.budget,
    required this.date,
    this.description,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'location': location,
      'guests': guests,
      'budget': budget,
      'date': date,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }
}
