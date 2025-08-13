class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'expense', 'income', or 'transfer'
  final String? accountId; // Reference to the account
  final String? notes; // Optional notes
  final String? transferId; // For transfer transactions - links the two transactions
  final String? toAccountId; // For transfer transactions - destination account

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.accountId,
    this.notes,
    this.transferId,
    this.toAccountId,
  });

  Transaction.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      amount = json['amount'],
      date = DateTime.parse(json['date']),
      category = json['category'],
      type = json['type'],
      accountId = json['accountId'],
      notes = json['notes'],
      transferId = json['transferId'],
      toAccountId = json['toAccountId'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'type': type,
    'accountId': accountId,
    'notes': notes,
    'transferId': transferId,
    'toAccountId': toAccountId,
  };

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? accountId,
    String? notes,
    String? transferId,
    String? toAccountId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      transferId: transferId ?? this.transferId,
      toAccountId: toAccountId ?? this.toAccountId,
    );
  }
}
