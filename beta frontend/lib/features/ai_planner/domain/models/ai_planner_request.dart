/// Request model for AI Planner API
class AiPlannerRequest {
  final String eventType;
  final String? date;
  final String? time;
  final String location;
  final String? guests; // Can be a range like "50-80 guests"
  final String? budget; // Can be a range like "₹50,000 – ₹1,00,000"
  final String? theme;

  AiPlannerRequest({
    required this.eventType,
    this.date,
    this.time,
    required this.location,
    this.guests,
    this.budget,
    this.theme,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      if (date != null && date!.isNotEmpty) 'date': date,
      if (time != null && time!.isNotEmpty) 'time': time,
      'location': location,
      if (guests != null && guests!.isNotEmpty) 'guests': guests,
      if (budget != null && budget!.isNotEmpty) 'budget': budget,
      if (theme != null && theme!.isNotEmpty) 'theme': theme,
    };
  }
}

