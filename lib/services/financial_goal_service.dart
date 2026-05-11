import 'package:flutter/foundation.dart';
import 'package:spendwise/models/financial_goal.dart';

class FinancialGoalService {
  // Get all financial goals
  static Future<List<FinancialGoal>> getFinancialGoals() async {
    try {
      if (kIsWeb) {
        // For web, return empty list for now
        // You can implement web storage for financial goals if needed
        return [];
      } else {
        // For mobile, implement mobile storage
        // This is a simplified version - you may need to implement proper financial goal storage
        return [];
      }
    } catch (e) {
      debugPrint('Error getting financial goals: $e');
      return [];
    }
  }

  // Add a new financial goal
  static Future<void> addFinancialGoal(FinancialGoal financialGoal) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
        debugPrint('Financial goals not yet implemented for web');
      } else {
        // For mobile, implement mobile storage
        debugPrint('Financial goals not yet implemented for mobile');
      }
    } catch (e) {
      debugPrint('Error adding financial goal: $e');
      rethrow;
    }
  }

  // Update a financial goal
  static Future<void> updateFinancialGoal(FinancialGoal financialGoal) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
        debugPrint('Financial goals not yet implemented for web');
      } else {
        // For mobile, implement mobile storage
        debugPrint('Financial goals not yet implemented for mobile');
      }
    } catch (e) {
      debugPrint('Error updating financial goal: $e');
      rethrow;
    }
  }

  // Delete a financial goal
  static Future<void> deleteFinancialGoal(String id) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
        debugPrint('Financial goals not yet implemented for web');
      } else {
        // For mobile, implement mobile storage
        debugPrint('Financial goals not yet implemented for mobile');
      }
    } catch (e) {
      debugPrint('Error deleting financial goal: $e');
      rethrow;
    }
  }

  // Get financial goal by ID
  static Future<FinancialGoal?> getFinancialGoalById(String id) async {
    try {
      final financialGoals = await getFinancialGoals();
      return financialGoals.firstWhere(
        (fg) => fg.id == id,
        orElse: () => throw Exception('Financial goal not found'),
      );
    } catch (e) {
      debugPrint('Error getting financial goal by ID: $e');
      return null;
    }
  }

  // Update goal progress based on transactions
  static Future<void> updateGoalProgressFromTransactions(String goalId) async {
    try {
      final goal = await getFinancialGoalById(goalId);
      if (goal == null) return;

      // Placeholder implementation - implement actual transaction logic when needed
      debugPrint('Goal progress update not yet implemented');
    } catch (e) {
      debugPrint('Error updating goal progress from transactions: $e');
    }
  }

  // Get financial goals by account
  static Future<List<FinancialGoal>> getFinancialGoalsByAccount(
    String accountId,
  ) async {
    try {
      final financialGoals = await getFinancialGoals();
      return financialGoals.where((fg) => fg.accountId == accountId).toList();
    } catch (e) {
      debugPrint('Error getting financial goals by account: $e');
      return [];
    }
  }

  // Get financial goals by type
  static Future<List<FinancialGoal>> getFinancialGoalsByType(
    String goalType,
  ) async {
    try {
      final financialGoals = await getFinancialGoals();
      return financialGoals.where((fg) => fg.goalType == goalType).toList();
    } catch (e) {
      debugPrint('Error getting financial goals by type: $e');
      return [];
    }
  }

  // Get active financial goals
  static Future<List<FinancialGoal>> getActiveFinancialGoals() async {
    try {
      final financialGoals = await getFinancialGoals();
      return financialGoals.where((fg) => fg.isActive).toList();
    } catch (e) {
      debugPrint('Error getting active financial goals: $e');
      return [];
    }
  }

  // Get completed financial goals
  static Future<List<FinancialGoal>> getCompletedFinancialGoals() async {
    try {
      final financialGoals = await getFinancialGoals();
      return financialGoals.where((fg) => fg.isCompleted).toList();
    } catch (e) {
      debugPrint('Error getting completed financial goals: $e');
      return [];
    }
  }

  // Get financial goals that need attention
  static Future<List<FinancialGoal>> getFinancialGoalsNeedingAttention() async {
    try {
      final financialGoals = await getFinancialGoals();
      final now = DateTime.now();

      return financialGoals.where((fg) {
        if (!fg.isActive || fg.isCompleted) return false;

        // Check if goal is overdue
        if (fg.targetDate.isBefore(now)) {
          return true;
        }

        // Check if goal is near deadline (within 30 days)
        final daysUntilDeadline = fg.targetDate.difference(now).inDays;
        if (daysUntilDeadline <= 30) {
          return true;
        }

        return false;
      }).toList();
    } catch (e) {
      debugPrint('Error getting financial goals needing attention: $e');
      return [];
    }
  }

  // Calculate goal completion percentage
  static double calculateGoalCompletionPercentage(FinancialGoal goal) {
    if (goal.targetAmount <= 0) return 0.0;

    final percentage = (goal.currentAmount / goal.targetAmount) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  // Check if goal is completed
  static bool isGoalCompleted(FinancialGoal goal) {
    return goal.currentAmount >= goal.targetAmount;
  }

  // Get total monthly goal contribution (placeholder)
  static Future<double> getTotalMonthlyGoalContribution() async {
    try {
      final financialGoals = await getFinancialGoals();
      double total = 0.0;

      for (final goal in financialGoals) {
        if (goal.isActive && !goal.isCompleted) {
          // Placeholder: you can implement monthly contribution logic here
          total += 0.0;
        }
      }

      return total;
    } catch (e) {
      debugPrint('Error getting total monthly goal contribution: $e');
      return 0.0;
    }
  }

  // Get financial goals summary
  static Future<Map<String, dynamic>> getFinancialGoalsSummary() async {
    try {
      final financialGoals = await getFinancialGoals();
      final activeGoals = financialGoals.where((fg) => fg.isActive).toList();
      final completedGoals = financialGoals
          .where((fg) => fg.isCompleted)
          .toList();

      double totalTargetAmount = 0.0;
      double totalCurrentAmount = 0.0;
      double totalMonthlyContribution = 0.0;

      for (final goal in activeGoals) {
        totalTargetAmount += goal.targetAmount;
        totalCurrentAmount += goal.currentAmount;
        // Placeholder: you can implement monthly contribution logic here
        totalMonthlyContribution += 0.0;
      }

      return {
        'totalGoals': financialGoals.length,
        'activeGoals': activeGoals.length,
        'completedGoals': completedGoals.length,
        'totalTargetAmount': totalTargetAmount,
        'totalCurrentAmount': totalCurrentAmount,
        'totalMonthlyContribution': totalMonthlyContribution,
        'overallProgress': totalTargetAmount > 0
            ? (totalCurrentAmount / totalTargetAmount * 100).clamp(0.0, 100.0)
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting financial goals summary: $e');
      return {};
    }
  }
}
