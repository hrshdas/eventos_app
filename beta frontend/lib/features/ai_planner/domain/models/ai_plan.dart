/// AI-generated plan response model
class AiPlan {
  final String? theme;
  final String? venue;
  final String? eventDescription;
  final List<String>? decorSuggestions;
  final List<String>? rentalSuggestions;
  final List<String>? staffSuggestions;
  final List<String>? foodSuggestions;
  final List<String>? musicSuggestions;
  final BudgetBreakdown? budgetBreakdown;
  final List<String>? recommendedCategories;
  final Map<String, dynamic>? metadata;

  AiPlan({
    this.theme,
    this.venue,
    this.eventDescription,
    this.decorSuggestions,
    this.rentalSuggestions,
    this.staffSuggestions,
    this.foodSuggestions,
    this.musicSuggestions,
    this.budgetBreakdown,
    this.recommendedCategories,
    this.metadata,
  });

  /// Create AiPlan from JSON response
  factory AiPlan.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    Map<String, dynamic> data;
    if (json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else if (json['plan'] is Map<String, dynamic>) {
      data = json['plan'] as Map<String, dynamic>;
    } else {
      data = json;
    }

    return AiPlan(
      theme: data['theme']?.toString(),
      venue: data['venue']?.toString(),
      eventDescription: data['eventDescription']?.toString() ?? data['description']?.toString(),
      decorSuggestions: _parseList(data['decorSuggestions'] ?? data['decor']),
      rentalSuggestions: _parseList(data['rentalSuggestions'] ?? data['rentals']),
      staffSuggestions: _parseList(data['staffSuggestions'] ?? data['staff'] ?? data['talent']),
      foodSuggestions: _parseList(data['foodSuggestions'] ?? data['food']),
      musicSuggestions: _parseList(data['musicSuggestions'] ?? data['music']),
      budgetBreakdown: data['budgetBreakdown'] != null
          ? BudgetBreakdown.fromJson(data['budgetBreakdown'] as Map<String, dynamic>)
          : null,
      recommendedCategories: _parseList(data['recommendedCategories'] ?? data['categories']),
      metadata: data['metadata'] is Map<String, dynamic> ? data['metadata'] : null,
    );
  }

  static List<String>? _parseList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // Try to split by comma or newline
      return value.split(RegExp(r'[,;\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (theme != null) 'theme': theme,
      if (venue != null) 'venue': venue,
      if (eventDescription != null) 'eventDescription': eventDescription,
      if (decorSuggestions != null) 'decorSuggestions': decorSuggestions,
      if (rentalSuggestions != null) 'rentalSuggestions': rentalSuggestions,
      if (staffSuggestions != null) 'staffSuggestions': staffSuggestions,
      if (foodSuggestions != null) 'foodSuggestions': foodSuggestions,
      if (musicSuggestions != null) 'musicSuggestions': musicSuggestions,
      if (budgetBreakdown != null) 'budgetBreakdown': budgetBreakdown!.toJson(),
      if (recommendedCategories != null) 'recommendedCategories': recommendedCategories,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Budget breakdown model
class BudgetBreakdown {
  final double? totalBudget;
  final double? decorBudget;
  final double? rentalBudget;
  final double? foodBudget;
  final double? staffBudget;
  final double? venueBudget;
  final Map<String, dynamic>? other;

  BudgetBreakdown({
    this.totalBudget,
    this.decorBudget,
    this.rentalBudget,
    this.foodBudget,
    this.staffBudget,
    this.venueBudget,
    this.other,
  });

  factory BudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return BudgetBreakdown(
      totalBudget: json['totalBudget'] != null
          ? (json['totalBudget'] is num
              ? json['totalBudget'].toDouble()
              : double.tryParse(json['totalBudget'].toString()))
          : null,
      decorBudget: json['decorBudget'] != null
          ? (json['decorBudget'] is num
              ? json['decorBudget'].toDouble()
              : double.tryParse(json['decorBudget'].toString()))
          : null,
      rentalBudget: json['rentalBudget'] != null
          ? (json['rentalBudget'] is num
              ? json['rentalBudget'].toDouble()
              : double.tryParse(json['rentalBudget'].toString()))
          : null,
      foodBudget: json['foodBudget'] != null
          ? (json['foodBudget'] is num
              ? json['foodBudget'].toDouble()
              : double.tryParse(json['foodBudget'].toString()))
          : null,
      staffBudget: json['staffBudget'] != null
          ? (json['staffBudget'] is num
              ? json['staffBudget'].toDouble()
              : double.tryParse(json['staffBudget'].toString()))
          : null,
      venueBudget: json['venueBudget'] != null
          ? (json['venueBudget'] is num
              ? json['venueBudget'].toDouble()
              : double.tryParse(json['venueBudget'].toString()))
          : null,
      other: json['other'] is Map<String, dynamic> ? json['other'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (totalBudget != null) 'totalBudget': totalBudget,
      if (decorBudget != null) 'decorBudget': decorBudget,
      if (rentalBudget != null) 'rentalBudget': rentalBudget,
      if (foodBudget != null) 'foodBudget': foodBudget,
      if (staffBudget != null) 'staffBudget': staffBudget,
      if (venueBudget != null) 'venueBudget': venueBudget,
      if (other != null) 'other': other,
    };
  }
}

