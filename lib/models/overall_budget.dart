class OverallBudget {
  final String id;
  final double limit;
  final DateTime startDate;
  final DateTime endDate;
  final String name;
  final bool isActive;

  OverallBudget({
    required this.id,
    required this.limit,
    required this.startDate,
    required this.endDate,
    this.name = 'Overall Budget',
    this.isActive = true,
  });

  OverallBudget.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        limit = json['limit']?.toDouble() ?? 0.0,
        startDate = DateTime.parse(json['startDate']),
        endDate = DateTime.parse(json['endDate']),
        name = json['name'] ?? 'Overall Budget',
        isActive = json['isActive'] ?? true;

  Map<String, dynamic> toJson() => {
        'id': id,
        'limit': limit,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'name': name,
        'isActive': isActive,
      };

  OverallBudget copyWith({
    String? id,
    double? limit,
    DateTime? startDate,
    DateTime? endDate,
    String? name,
    bool? isActive,
  }) {
    return OverallBudget(
      id: id ?? this.id,
      limit: limit ?? this.limit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
