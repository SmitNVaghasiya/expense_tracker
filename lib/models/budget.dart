class Budget {
  final String id;
  final String name;
  final double limit;
  final String category;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.category,
    required this.startDate,
    required this.endDate,
  });

  Budget.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        limit = json['limit'],
        category = json['category'],
        startDate = DateTime.parse(json['startDate']),
        endDate = DateTime.parse(json['endDate']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'limit': limit,
        'category': category,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}