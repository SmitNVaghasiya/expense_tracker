class Category {
  final String id;
  final String name;
  final String type; // 'income', 'expense', 'transfer'
  final String icon; // Icon identifier
  final String color; // Color hex string
  final DateTime createdAt;
  final bool isDefault; // Whether it's a system default category

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] == 1,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
