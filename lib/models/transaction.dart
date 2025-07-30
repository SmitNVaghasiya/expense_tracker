class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'expense' or 'income'
  final String? accountId; // Reference to the account
  final String? notes; // Optional notes

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.accountId,
    this.notes,
  });

  Transaction.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      amount = json['amount'],
      date = DateTime.parse(json['date']),
      category = json['category'],
      type = json['type'],
      accountId = json['accountId'],
      notes = json['notes'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'type': type,
    'accountId': accountId,
    'notes': notes,
  };
}
