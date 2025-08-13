import 'package:spendwise/services/data_service.dart';

class BudgetService {
  // Get budget spending analysis for a specific month
  static Future<Map<String, dynamic>> getBudgetAnalysis(DateTime month) async {
    final budgets = await DataService.getBudgets();
    final transactions = await DataService.getTransactions();

    // Filter budgets and transactions for the specified month
    final monthBudgets = budgets
        .where(
          (budget) =>
              budget.startDate.year == month.year &&
              budget.startDate.month == month.month,
        )
        .toList();

    final monthTransactions = transactions
        .where(
          (transaction) =>
              transaction.date.year == month.year &&
              transaction.date.month == month.month &&
              transaction.type == 'expense',
        )
        .toList();

    // Calculate spending by category
    final Map<String, double> categorySpending = {};
    for (final transaction in monthTransactions) {
      categorySpending[transaction.category] =
          (categorySpending[transaction.category] ?? 0) + transaction.amount;
    }

    // Compare with budgets
    final List<Map<String, dynamic>> budgetAnalysis = [];
    for (final budget in monthBudgets) {
      final spent = categorySpending[budget.category] ?? 0;
      final remaining = budget.limit - spent;
      final percentage = (spent / budget.limit * 100).clamp(0, 100);

      budgetAnalysis.add({
        'budget': budget,
        'spent': spent,
        'remaining': remaining,
        'percentage': percentage,
        'isOverBudget': spent > budget.limit,
        'isNearLimit': percentage >= 80 && percentage < 100,
      });
    }

    // Calculate overall budget metrics
    final totalBudget = monthBudgets.fold(
      0.0,
      (sum, budget) => sum + budget.limit,
    );
    final totalSpent = monthTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
    final totalRemaining = totalBudget - totalSpent;
    final overallPercentage = totalBudget > 0
        ? (totalSpent / totalBudget * 100).clamp(0, 100)
        : 0;

    return {
      'month': month,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'totalRemaining': totalRemaining,
      'overallPercentage': overallPercentage,
      'isOverBudget': totalSpent > totalBudget,
      'isNearLimit': overallPercentage >= 80 && overallPercentage < 100,
      'budgetAnalysis': budgetAnalysis,
      'categorySpending': categorySpending,
    };
  }

  // Get budget alerts
  static Future<List<Map<String, dynamic>>> getBudgetAlerts() async {
    final now = DateTime.now();
    final analysis = await getBudgetAnalysis(now);

    final List<Map<String, dynamic>> alerts = [];

    // Overall budget alerts
    if (analysis['isOverBudget']) {
      alerts.add({
        'type': 'over_budget',
        'title': 'Over Budget',
        'message': 'You have exceeded your total budget for this month.',
        'severity': 'high',
        'amount': analysis['totalSpent'] - analysis['totalBudget'],
      });
    } else if (analysis['isNearLimit']) {
      alerts.add({
        'type': 'near_limit',
        'title': 'Near Budget Limit',
        'message': 'You are approaching your budget limit for this month.',
        'severity': 'medium',
        'percentage': analysis['overallPercentage'],
      });
    }

    // Category-specific alerts
    for (final budgetData in analysis['budgetAnalysis']) {
      if (budgetData['isOverBudget']) {
        alerts.add({
          'type': 'category_over_budget',
          'title': '${budgetData['budget'].category} Over Budget',
          'message':
              'You have exceeded your budget for ${budgetData['budget'].category}.',
          'severity': 'high',
          'category': budgetData['budget'].category,
          'amount': budgetData['spent'] - budgetData['budget'].limit,
        });
      } else if (budgetData['isNearLimit']) {
        alerts.add({
          'type': 'category_near_limit',
          'title': '${budgetData['budget'].category} Near Limit',
          'message':
              'You are approaching your budget limit for ${budgetData['budget'].category}.',
          'severity': 'medium',
          'category': budgetData['budget'].category,
          'percentage': budgetData['percentage'],
        });
      }
    }

    return alerts;
  }

  // Get spending trends
  static Future<Map<String, dynamic>> getSpendingTrends() async {
    final transactions = await DataService.getTransactions();
    final now = DateTime.now();

    // Get last 6 months of data
    final List<Map<String, dynamic>> monthlyData = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthTransactions = transactions
          .where(
            (transaction) =>
                transaction.date.year == month.year &&
                transaction.date.month == month.month &&
                transaction.type == 'expense',
          )
          .toList();

      final totalSpent = monthTransactions.fold(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );

      // Calculate category spending for this month
      final Map<String, double> categorySpending = {};
      for (final transaction in monthTransactions) {
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0) + transaction.amount;
      }

      monthlyData.add({
        'month': month,
        'totalSpent': totalSpent,
        'categorySpending': categorySpending,
      });
    }

    // Calculate trends
    double totalTrend = 0;
    if (monthlyData.length >= 2) {
      final currentMonth = monthlyData.last['totalSpent'];
      final previousMonth = monthlyData[monthlyData.length - 2]['totalSpent'];
      totalTrend = previousMonth > 0
          ? ((currentMonth - previousMonth) / previousMonth * 100)
          : 0;
    }

    return {
      'monthlyData': monthlyData,
      'totalTrend': totalTrend,
      'averageMonthlySpending':
          monthlyData.fold(0.0, (sum, data) => sum + data['totalSpent']) /
          monthlyData.length,
    };
  }

  // Get budget recommendations
  static Future<List<Map<String, dynamic>>> getBudgetRecommendations() async {
    final trends = await getSpendingTrends();
    final analysis = await getBudgetAnalysis(DateTime.now());
    final List<Map<String, dynamic>> recommendations = [];

    // Analyze spending patterns
    final categorySpending =
        analysis['categorySpending'] as Map<String, double>;
    final budgets = analysis['budgetAnalysis'] as List<Map<String, dynamic>>;

    // Find categories with high spending but no budget
    for (final entry in categorySpending.entries) {
      final hasBudget = budgets.any(
        (budget) => budget['budget'].category == entry.key,
      );
      if (!hasBudget && entry.value > 1000) {
        // High spending threshold
        recommendations.add({
          'type': 'create_budget',
          'category': entry.key,
          'message':
              'Consider creating a budget for ${entry.key} as you spend ₹${entry.value.toStringAsFixed(0)} monthly.',
          'suggestedAmount':
              entry.value * 0.8, // Suggest 80% of current spending
        });
      }
    }

    // Find categories where budget is too low
    for (final budgetData in budgets) {
      if (budgetData['isOverBudget']) {
        recommendations.add({
          'type': 'increase_budget',
          'category': budgetData['budget'].category,
          'message':
              'Consider increasing your budget for ${budgetData['budget'].category}.',
          'currentBudget': budgetData['budget'].limit,
          'suggestedAmount':
              budgetData['spent'] * 1.1, // Suggest 110% of actual spending
        });
      }
    }

    // Overall spending trend recommendation
    if (trends['totalTrend'] > 20) {
      recommendations.add({
        'type': 'spending_increase',
        'message':
            'Your spending has increased by ${trends['totalTrend'].toStringAsFixed(1)}% this month. Consider reviewing your expenses.',
      });
    }

    return recommendations;
  }
}
