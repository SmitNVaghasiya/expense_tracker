import 'package:uuid/uuid.dart';

class Loan {
  final String id;
  final String type; // 'lent' or 'borrowed'
  final String person;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final String status; // 'pending', 'repaid', 'overdue'
  final String? notes;

  // New fields for enhanced loan management
  final String? accountId; // Account from which money is lent/borrowed
  final String?
  paymentFrequency; // 'monthly', 'weekly', 'biweekly', 'quarterly', 'yearly', 'one-time'
  final int? paymentDay; // Day of month for payment (1-31)
  final double? monthlyPayment; // Monthly payment amount
  final double paidAmount; // Total amount paid so far
  final List<LoanPayment> paymentHistory; // History of payments made
  final bool autoDeduct; // Whether to automatically deduct from account
  final DateTime? nextPaymentDate; // Next scheduled payment date

  Loan({
    String? id,
    required this.type,
    required this.person,
    required this.amount,
    required this.date,
    this.dueDate,
    this.status = 'pending',
    this.notes,
    this.accountId,
    this.paymentFrequency,
    this.paymentDay,
    this.monthlyPayment,
    this.paidAmount = 0.0,
    this.paymentHistory = const [],
    this.autoDeduct = false,
    this.nextPaymentDate,
  }) : id = id ?? const Uuid().v4();

  // Get remaining amount to be paid
  double get remainingAmount => amount - paidAmount;

  // Get next payment amount
  double get nextPaymentAmount {
    if (monthlyPayment != null) {
      return monthlyPayment!;
    }
    return remainingAmount;
  }

  // Check if loan is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && status == 'pending';
  }

  // Check if next payment is due
  bool get isNextPaymentDue {
    if (nextPaymentDate == null) return false;
    return nextPaymentDate!.isBefore(DateTime.now()) && status == 'pending';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'person': person,
      'amount': amount,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'accountId': accountId,
      'paymentFrequency': paymentFrequency,
      'paymentDay': paymentDay,
      'monthlyPayment': monthlyPayment,
      'paidAmount': paidAmount,
      'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
      'autoDeduct': autoDeduct,
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
    };
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      type: json['type'],
      person: json['person'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: json['status'],
      notes: json['notes'],
      accountId: json['accountId'],
      paymentFrequency: json['paymentFrequency'],
      paymentDay: json['paymentDay'],
      monthlyPayment: json['monthlyPayment'],
      paidAmount: json['paidAmount'] ?? 0.0,
      paymentHistory:
          (json['paymentHistory'] as List?)
              ?.map((p) => LoanPayment.fromJson(p))
              .toList() ??
          [],
      autoDeduct: json['autoDeduct'] ?? false,
      nextPaymentDate: json['nextPaymentDate'] != null
          ? DateTime.parse(json['nextPaymentDate'])
          : null,
    );
  }

  Loan copyWith({
    String? id,
    String? type,
    String? person,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    String? status,
    String? notes,
    String? accountId,
    String? paymentFrequency,
    int? paymentDay,
    double? monthlyPayment,
    double? paidAmount,
    List<LoanPayment>? paymentHistory,
    bool? autoDeduct,
    DateTime? nextPaymentDate,
  }) {
    return Loan(
      id: id ?? this.id,
      type: type ?? this.type,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      paymentDay: paymentDay ?? this.paymentDay,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      autoDeduct: autoDeduct ?? this.autoDeduct,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
    );
  }
}

// New class to track loan payments
class LoanPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? accountId; // Account from which payment was made

  LoanPayment({
    String? id,
    required this.amount,
    required this.date,
    this.notes,
    this.accountId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'accountId': accountId,
    };
  }

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      accountId: json['accountId'],
    );
  }
}
