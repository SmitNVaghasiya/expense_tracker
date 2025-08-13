class FinancialGoal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String goalType; // 'savings', 'debt_payoff', 'investment', 'emergency_fund'
  final String? accountId; // Associated account for tracking
  final bool isActive;
  final String? category; // For category-specific goals
  final String? color; // For UI customization

  FinancialGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    required this.goalType,
    this.accountId,
    this.isActive = true,
    this.category,
    this.color,
  });

  FinancialGoal.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      targetAmount = json['targetAmount'],
      currentAmount = json['currentAmount'] ?? 0.0,
      targetDate = DateTime.parse(json['targetDate']),
      createdAt = DateTime.parse(json['createdAt']),
      goalType = json['goalType'],
      accountId = json['accountId'],
      isActive = json['isActive'] == 1 || json['isActive'] == true,
      category = json['category'],
      color = json['color'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'goalType': goalType,
    'accountId': accountId,
    'isActive': isActive ? 1 : 0,
    'category': category,
    'color': color,
  };

  FinancialGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? goalType,
    String? accountId,
    bool? isActive,
    String? category,
    String? color,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      goalType: goalType ?? this.goalType,
      accountId: accountId ?? this.accountId,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  // Check if goal is completed
  bool get isCompleted {
    return currentAmount >= targetAmount;
  }

  // Check if goal is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(targetDate);
  }

  // Get remaining amount
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  // Get days until target date
  int get daysUntilTarget {
    final today = DateTime.now();
    final difference = targetDate.difference(today).inDays;
    return difference;
  }

  // Get status text
  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (daysUntilTarget <= 0) return 'Due Today';
    if (daysUntilTarget <= 7) return 'Due Soon';
    return 'In Progress';
  }

  // Get status color
  String get statusColor {
    if (isCompleted) return 'green';
    if (isOverdue) return 'red';
    if (daysUntilTarget <= 7) return 'orange';
    return 'blue';
  }

  // Get goal type display text
  String get goalTypeDisplayText {
    switch (goalType) {
      case 'savings':
        return 'Savings Goal';
      case 'debt_payoff':
        return 'Debt Payoff';
      case 'investment':
        return 'Investment Goal';
      case 'emergency_fund':
        return 'Emergency Fund';
      default:
        return 'Financial Goal';
    }
  }

  // Calculate monthly contribution needed to reach goal
  double get monthlyContributionNeeded {
    final today = DateTime.now();
    final monthsRemaining = (targetDate.difference(today).inDays / 30.44).ceil();
    if (monthsRemaining <= 0) return 0.0;
    return remainingAmount / monthsRemaining;
  }

  // Update current amount (for progress tracking)
  FinancialGoal updateProgress(double newAmount) {
    return copyWith(currentAmount: newAmount);
  }

  // Add amount to current progress
  FinancialGoal addProgress(double amount) {
    return copyWith(currentAmount: currentAmount + amount);
  }
} 