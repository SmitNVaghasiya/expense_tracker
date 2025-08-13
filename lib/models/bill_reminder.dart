class BillReminder {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime dueDate;
  final String? accountId;
  final String? notes;
  final bool isPaid;
  final DateTime? paidDate;
  final int reminderDays; // Days before due date to send reminder
  final bool isActive;
  final String? recurringPattern; // For recurring bills (monthly, yearly, etc.)
  final DateTime? nextDueDate; // For recurring bills

  BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.accountId,
    this.notes,
    this.isPaid = false,
    this.paidDate,
    this.reminderDays = 3,
    this.isActive = true,
    this.recurringPattern,
    this.nextDueDate,
  });

  BillReminder.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      amount = json['amount'],
      category = json['category'],
      dueDate = DateTime.parse(json['dueDate']),
      accountId = json['accountId'],
      notes = json['notes'],
      isPaid = json['isPaid'] == 1 || json['isPaid'] == true,
      paidDate = json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      reminderDays = json['reminderDays'] ?? 3,
      isActive = json['isActive'] == 1 || json['isActive'] == true,
      recurringPattern = json['recurringPattern'],
      nextDueDate = json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'accountId': accountId,
    'notes': notes,
    'isPaid': isPaid ? 1 : 0,
    'paidDate': paidDate?.toIso8601String(),
    'reminderDays': reminderDays,
    'isActive': isActive ? 1 : 0,
    'recurringPattern': recurringPattern,
    'nextDueDate': nextDueDate?.toIso8601String(),
  };

  BillReminder copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? dueDate,
    String? accountId,
    String? notes,
    bool? isPaid,
    DateTime? paidDate,
    int? reminderDays,
    bool? isActive,
    String? recurringPattern,
    DateTime? nextDueDate,
  }) {
    return BillReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      reminderDays: reminderDays ?? this.reminderDays,
      isActive: isActive ?? this.isActive,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  // Check if the bill is overdue
  bool get isOverdue {
    return !isPaid && DateTime.now().isAfter(dueDate);
  }

  // Check if reminder should be sent today
  bool shouldSendReminderToday() {
    if (!isActive || isPaid) return false;

    final today = DateTime.now();
    final reminderDate = dueDate.subtract(Duration(days: reminderDays));
    final todayStart = DateTime(today.year, today.month, today.day);
    final reminderStart = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );

    return todayStart.isAtSameMomentAs(reminderStart);
  }

  // Check if due today
  bool get isDueToday {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final dueStart = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return todayStart.isAtSameMomentAs(dueStart);
  }

  // Get days until due
  int get daysUntilDue {
    final today = DateTime.now();
    final difference = dueDate.difference(today).inDays;
    return difference;
  }

  // Get status text
  String get statusText {
    if (isPaid) return 'Paid';
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Due Today';
    if (daysUntilDue <= reminderDays) return 'Due Soon';
    return 'Upcoming';
  }

  // Get status color (for UI)
  String get statusColor {
    if (isPaid) return 'green';
    if (isOverdue) return 'red';
    if (isDueToday) return 'orange';
    if (daysUntilDue <= reminderDays) return 'yellow';
    return 'blue';
  }

  // Calculate next due date for recurring bills
  DateTime? calculateNextDueDate() {
    if (recurringPattern == null) return null;

    switch (recurringPattern) {
      case 'monthly':
        return DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      case 'yearly':
        return DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
      case 'weekly':
        return dueDate.add(Duration(days: 7));
      default:
        return null;
    }
  }
}
