class Account {
  final String id;
  final String name;
  final double balance;
  final String type; // 'cash', 'bank', 'credit', etc.
  final String? icon; // Optional icon identifier
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      balance: json['balance'].toDouble(),
      type: json['type'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Account copyWith({
    String? id,
    String? name,
    double? balance,
    String? type,
    String? icon,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 