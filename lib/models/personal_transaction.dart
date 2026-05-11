import 'package:uuid/uuid.dart';

class PersonalTransaction {
  final String id;
  final String type; // 'lent' or 'borrowed'
  final String personName;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? accountId;
  final DateTime createdAt;
  
  // Interest-related fields (optional)
  final double? interestRate;
  final String? interestCalculation; // 'monthly', 'yearly'
  final int? durationMonths; // How long the money is given/taken
  
  // Payment tracking
  final double paidAmount;
  final List<PersonalPayment> paymentHistory;

  PersonalTransaction({
    String? id,
    required this.type,
    required this.personName,
    required this.amount,
    required this.date,
    this.notes,
    this.accountId,
    this.interestRate,
    this.interestCalculation,
    this.durationMonths,
    this.paidAmount = 0.0,
    this.paymentHistory = const [],
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Get remaining amount
  double get remainingAmount => amount - paidAmount;
  
  // Get total amount with interest (if applicable)
  double get totalAmount {
    if (interestRate == null || durationMonths == null) {
      return amount;
    }
    
    if (interestCalculation == 'monthly') {
      return amount + (amount * interestRate! * durationMonths! / 100);
    } else if (interestCalculation == 'yearly') {
      return amount + (amount * interestRate! * durationMonths! / 12 / 100);
    }
    
    return amount;
  }
  
  // Get interest amount
  double get interestAmount => totalAmount - amount;
  
  // Check if transaction is fully paid
  bool get isFullyPaid => remainingAmount <= 0;
  
  // Get status
  String get status => isFullyPaid ? 'repaid' : 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'personName': personName,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'accountId': accountId,
      'interestRate': interestRate,
      'interestCalculation': interestCalculation,
      'durationMonths': durationMonths,
      'paidAmount': paidAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PersonalTransaction.fromJson(Map<String, dynamic> json) {
    return PersonalTransaction(
      id: json['id'],
      type: json['type'],
      personName: json['personName'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      accountId: json['accountId'],
      interestRate: json['interestRate'],
      interestCalculation: json['interestCalculation'],
      durationMonths: json['durationMonths'],
      paidAmount: json['paidAmount'] ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  PersonalTransaction copyWith({
    String? id,
    String? type,
    String? personName,
    double? amount,
    DateTime? date,
    String? notes,
    String? accountId,
    double? interestRate,
    String? interestCalculation,
    int? durationMonths,
    double? paidAmount,
    List<PersonalPayment>? paymentHistory,
    DateTime? createdAt,
  }) {
    return PersonalTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      interestRate: interestRate ?? this.interestRate,
      interestCalculation: interestCalculation ?? this.interestCalculation,
      durationMonths: durationMonths ?? this.durationMonths,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PersonalPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? accountId;

  PersonalPayment({
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

  factory PersonalPayment.fromJson(Map<String, dynamic> json) {
    return PersonalPayment(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      accountId: json['accountId'],
    );
  }
}
