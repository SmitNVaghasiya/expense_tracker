class Group {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        createdAt = DateTime.parse(json['createdAt']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };
}