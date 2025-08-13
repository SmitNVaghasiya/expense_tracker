import 'package:uuid/uuid.dart';
import 'package:spendwise/models/financial_goal.dart';
import 'database_service.dart';
import 'data_service.dart';

class FinancialGoalService {
  static const _uuid = Uuid();

  // Get all financial goals
  static Future<List<FinancialGoal>> getFinancialGoals() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('financial_goals');
    return List.generate(maps.length, (i) => FinancialGoal.fromJson(maps[i]));
  }

  // Add a new financial goal
  static Future<void> addFinancialGoal(FinancialGoal financialGoal) async {
    final db = await DatabaseService.database;
    await db.insert('financial_goals', financialGoal.toJson());
  }

  // Update a financial goal
  static Future<void> updateFinancialGoal(FinancialGoal financialGoal) async {
    final db = await DatabaseService.database;
    await db.update(
      'financial_goals',
      financialGoal.toJson(),
      where: 'id = ?',
      whereArgs: [financialGoal.id],
    );
  }

  // Delete a financial goal
  static Future<void> deleteFinancialGoal(String id) async {
    final db = await DatabaseService.database;
    await db.delete('financial_goals', where: 'id = ?', whereArgs: [id]);
  }

  // Get financial goal by ID
  static Future<FinancialGoal?> getFinancialGoalById(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FinancialGoal.fromJson(maps.first);
    }
    return null;
  }

  // Update goal progress based on transactions
  static Future<void> updateGoalProgressFromTransactions(String goalId) async {
    final goal = await getFinancialGoalById(goalId);
    if (goal == null) return;

    final transactions = await DataService.getTransactions();
    double progressAmount = 0.0;

    // Calculate progress based on goal type
    switch (goal.goalType) {
      case 'savings':
        // For savings goals, count income transactions
        for (final transaction in transactions) {
          if (transaction.type == 'income' &&
              (goal.accountId == null ||
                  transaction.accountId == goal.accountId)) {
            progressAmount += transaction.amount;
          }
        }
        break;

      case 'debt_payoff':
        // For debt payoff goals, count expense transactions in debt categories
        for (final transaction in transactions) {
          if (transaction.type == 'expense' &&
              (goal.category == null ||
                  transaction.category == goal.category) &&
              (goal.accountId == null ||
                  transaction.accountId == goal.accountId)) {
            progressAmount += transaction.amount;
          }
        }
        break;

      case 'investment':
        // For investment goals, count income transactions
        for (final transaction in transactions) {
          if (transaction.type == 'income' &&
              (goal.accountId == null ||
                  transaction.accountId == goal.accountId)) {
            progressAmount += transaction.amount;
          }
        }
        break;

      case 'emergency_fund':
        // For emergency fund goals, count income transactions
        for (final transaction in transactions) {
          if (transaction.type == 'income' &&
              (goal.accountId == null ||
                  transaction.accountId == goal.accountId)) {
            progressAmount += transaction.amount;
          }
        }
        break;
    }

    // Update the goal with new progress
    final updatedGoal = goal.copyWith(currentAmount: progressAmount);
    await updateFinancialGoal(updatedGoal);
  }

  // Update all goals progress
  static Future<void> updateAllGoalsProgress() async {
    final goals = await getFinancialGoals();
    for (final goal in goals) {
      await updateGoalProgressFromTransactions(goal.id);
    }
  }

  // Get active goals
  static Future<List<FinancialGoal>> getActiveGoals() async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) => goal.isActive).toList();
  }

  // Get completed goals
  static Future<List<FinancialGoal>> getCompletedGoals() async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) => goal.isCompleted).toList();
  }

  // Get overdue goals
  static Future<List<FinancialGoal>> getOverdueGoals() async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) => goal.isOverdue).toList();
  }

  // Get goals due soon (within 30 days)
  static Future<List<FinancialGoal>> getGoalsDueSoon({int days = 30}) async {
    final allGoals = await getFinancialGoals();
    final today = DateTime.now();
    final endDate = today.add(Duration(days: days));

    return allGoals.where((goal) {
      return goal.isActive &&
          !goal.isCompleted &&
          goal.targetDate.isAfter(today) &&
          goal.targetDate.isBefore(endDate);
    }).toList();
  }

  // Get goals by type
  static Future<List<FinancialGoal>> getGoalsByType(String goalType) async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) => goal.goalType == goalType).toList();
  }

  // Get goals by category
  static Future<List<FinancialGoal>> getGoalsByCategory(String category) async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) => goal.category == category).toList();
  }

  // Add progress to a goal manually
  static Future<void> addProgressToGoal(String goalId, double amount) async {
    final goal = await getFinancialGoalById(goalId);
    if (goal != null) {
      final updatedGoal = goal.addProgress(amount);
      await updateFinancialGoal(updatedGoal);
    }
  }

  // Get financial goals summary
  static Future<Map<String, dynamic>> getFinancialGoalsSummary() async {
    final allGoals = await getFinancialGoals();
    final activeGoals = allGoals.where((g) => g.isActive).toList();
    final completedGoals = allGoals.where((g) => g.isCompleted).toList();
    final overdueGoals = allGoals.where((g) => g.isOverdue).toList();

    double totalTargetAmount = 0.0;
    double totalCurrentAmount = 0.0;
    double totalRemainingAmount = 0.0;

    for (final goal in activeGoals) {
      totalTargetAmount += goal.targetAmount;
      totalCurrentAmount += goal.currentAmount;
      totalRemainingAmount += goal.remainingAmount;
    }

    return {
      'totalGoals': allGoals.length,
      'activeGoals': activeGoals.length,
      'completedGoals': completedGoals.length,
      'overdueGoals': overdueGoals.length,
      'totalTargetAmount': totalTargetAmount,
      'totalCurrentAmount': totalCurrentAmount,
      'totalRemainingAmount': totalRemainingAmount,
      'overallProgress': totalTargetAmount > 0
          ? (totalCurrentAmount / totalTargetAmount * 100)
          : 0.0,
    };
  }

  // Get goals progress by type
  static Future<Map<String, Map<String, dynamic>>>
  getGoalsProgressByType() async {
    final allGoals = await getFinancialGoals();
    final Map<String, Map<String, dynamic>> progressByType = {};

    for (final goal in allGoals) {
      if (!progressByType.containsKey(goal.goalType)) {
        progressByType[goal.goalType] = {
          'count': 0,
          'targetAmount': 0.0,
          'currentAmount': 0.0,
          'completedCount': 0,
        };
      }

      final typeData = progressByType[goal.goalType]!;
      typeData['count'] = (typeData['count'] as int) + 1;
      typeData['targetAmount'] =
          (typeData['targetAmount'] as double) + goal.targetAmount;
      typeData['currentAmount'] =
          (typeData['currentAmount'] as double) + goal.currentAmount;

      if (goal.isCompleted) {
        typeData['completedCount'] = (typeData['completedCount'] as int) + 1;
      }
    }

    return progressByType;
  }

  // Create a new financial goal with default values
  static FinancialGoal createNewGoal({
    required String title,
    required String description,
    required double targetAmount,
    required DateTime targetDate,
    required String goalType,
    String? accountId,
    String? category,
    String? color,
  }) {
    return FinancialGoal(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      goalType: goalType,
      accountId: accountId,
      isActive: true,
      category: category,
      color: color,
    );
  }

  // Pause a financial goal
  static Future<void> pauseFinancialGoal(String id) async {
    final goal = await getFinancialGoalById(id);
    if (goal != null) {
      final updated = goal.copyWith(isActive: false);
      await updateFinancialGoal(updated);
    }
  }

  // Resume a financial goal
  static Future<void> resumeFinancialGoal(String id) async {
    final goal = await getFinancialGoalById(id);
    if (goal != null) {
      final updated = goal.copyWith(isActive: true);
      await updateFinancialGoal(updated);
    }
  }

  // Get goals that need attention (overdue or due soon)
  static Future<List<FinancialGoal>> getGoalsNeedingAttention() async {
    final allGoals = await getFinancialGoals();
    return allGoals.where((goal) {
      return goal.isActive &&
          !goal.isCompleted &&
          (goal.isOverdue || goal.daysUntilTarget <= 7);
    }).toList();
  }
}
