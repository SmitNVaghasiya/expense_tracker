class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'expense', 'income', or 'transfer'
  final String? accountId;
  final String? notes;
  final String? toAccountId;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime? endDate; // null means no end date
  final DateTime nextDueDate;
  final bool isActive;
  final String? transferId;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    this.accountId,
    this.notes,
    this.toAccountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isActive = true,
    this.transferId,
  });

  RecurringTransaction.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      amount = json['amount'],
      category = json['category'],
      type = json['type'],
      accountId = json['accountId'],
      notes = json['notes'],
      toAccountId = json['toAccountId'],
      frequency = json['frequency'],
      startDate = DateTime.parse(json['startDate']),
      endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      nextDueDate = DateTime.parse(json['nextDueDate']),
      isActive = json['isActive'] == 1 || json['isActive'] == true,
      transferId = json['transferId'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'type': type,
    'accountId': accountId,
    'notes': notes,
    'toAccountId': toAccountId,
    'frequency': frequency,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'nextDueDate': nextDueDate.toIso8601String(),
    'isActive': isActive ? 1 : 0,
    'transferId': transferId,
  };

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    String? accountId,
    String? notes,
    String? toAccountId,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isActive,
    String? transferId,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      toAccountId: toAccountId ?? this.toAccountId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      transferId: transferId ?? this.transferId,
    );
  }

  // Calculate the next due date based on frequency
  DateTime calculateNextDueDate() {
    switch (frequency) {
      case 'daily':
        return nextDueDate.add(Duration(days: 1));
      case 'weekly':
        return nextDueDate.add(Duration(days: 7));
      case 'monthly':
        return DateTime(nextDueDate.year, nextDueDate.month + 1, nextDueDate.day);
      case 'yearly':
        return DateTime(nextDueDate.year + 1, nextDueDate.month, nextDueDate.day);
      default:
        return nextDueDate.add(Duration(days: 1));
    }
  }

  // Check if the recurring transaction should create a new transaction today
  bool shouldCreateTransactionToday() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final nextDueStart = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    
    return isActive && 
           todayStart.isAtSameMomentAs(nextDueStart) &&
           (endDate == null || today.isBefore(endDate!));
  }

  // Get the frequency display text
  String get frequencyDisplayText {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Unknown';
    }
  }
} 