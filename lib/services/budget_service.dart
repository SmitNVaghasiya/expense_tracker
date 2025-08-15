import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:intl/intl.dart';

class BudgetService {
  // Get budget spending analysis for a specific month
  static Future<Map<String, dynamic>> getBudgetAnalysis(DateTime month) async {
    final budgets = await DataService.getBudgets();
    final overallBudgets = await DataService.getOverallBudgets();
    final transactions = await DataService.getTransactions();

    // Filter budgets and transactions for the specified month
    final monthBudgets = budgets
        .where(
          (budget) =>
              budget.startDate.year == month.year &&
              budget.startDate.month == month.month,
        )
        .toList();

    final monthOverallBudgets = overallBudgets
        .where(
          (budget) =>
              budget.startDate.year == month.year &&
              budget.startDate.month == month.month &&
              budget.isActive,
        )
        .toList();

    final monthTransactions = transactions
        .where(
          (transaction) =>
              transaction.date.year == month.year &&
              transaction.date.month == month.month,
        )
        .toList();

    // Calculate spending by category (expenses only)
    final Map<String, double> categorySpending = {};
    final monthExpenses = monthTransactions
        .where((transaction) => transaction.type == 'expense')
        .toList();
    
    for (final transaction in monthExpenses) {
      categorySpending[transaction.category] =
          (categorySpending[transaction.category] ?? 0) + transaction.amount;
    }

    // Calculate income for the month
    final monthIncome = monthTransactions
        .where((transaction) => transaction.type == 'income')
        .toList();
    
    double totalIncome = 0.0;
    double salaryIncome = 0.0;
    
    for (final transaction in monthIncome) {
      totalIncome += transaction.amount;
      if (transaction.category.toLowerCase() == 'salary') {
        salaryIncome += transaction.amount;
      }
    }

    // Use salary income if available, otherwise use total income
    final effectiveIncome = salaryIncome > 0 ? salaryIncome : totalIncome;

    // Compare with budgets - only for categories that actually have budgets
    final List<Map<String, dynamic>> budgetAnalysis = [];
    for (final budget in monthBudgets) {
      // Only analyze budgets that have a limit > 0
      if (budget.limit > 0) {
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
    }

    // Calculate overall budget metrics
    final totalBudget = monthBudgets.fold(
      0.0,
      (sum, budget) => sum + budget.limit,
    );
    
    // Add overall budget if exists
    double overallBudgetLimit = 0.0;
    if (monthOverallBudgets.isNotEmpty) {
      overallBudgetLimit = monthOverallBudgets.first.limit;
    }
    
    final totalSpent = monthExpenses.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
    
    // Use overall budget if available, otherwise use sum of category budgets
    final effectiveTotalBudget = overallBudgetLimit > 0 ? overallBudgetLimit : totalBudget;
    final totalRemaining = effectiveTotalBudget - totalSpent;
    final overallPercentage = effectiveTotalBudget > 0
        ? (totalSpent / effectiveTotalBudget * 100).clamp(0, 100)
        : 0;

    return {
      'month': month,
      'totalBudget': totalBudget,
      'overallBudgetLimit': overallBudgetLimit,
      'effectiveTotalBudget': effectiveTotalBudget,
      'totalSpent': totalSpent,
      'totalRemaining': totalRemaining,
      'overallPercentage': overallPercentage,
      'isOverBudget': totalSpent > effectiveTotalBudget,
      'isNearLimit': overallPercentage >= 80 && overallPercentage < 100,
      'budgetAnalysis': budgetAnalysis,
      'categorySpending': categorySpending,
      'hasOverallBudget': overallBudgetLimit > 0,
      'totalIncome': totalIncome,
      'salaryIncome': salaryIncome,
      'effectiveIncome': effectiveIncome,
      'isOverIncome': totalSpent > effectiveIncome,
      'incomeDeficit': totalSpent - effectiveIncome,
    };
  }

  // Get budget alerts with priority system
  static Future<List<Map<String, dynamic>>> getBudgetAlerts() async {
    final now = DateTime.now();
    final analysis = await getBudgetAnalysis(now);

    final List<Map<String, dynamic>> alerts = [];

    // 1. HIGH PRIORITY: Category-specific alerts - only for categories that actually have budgets
    for (final budgetData in analysis['budgetAnalysis']) {
      // Only show alerts for categories that have budgets set (limit > 0)
      if (budgetData['budget'].limit > 0) {
        if (budgetData['isOverBudget']) {
          alerts.add({
            'type': 'category_over_budget',
            'priority': 'high',
            'title': '${budgetData['budget'].category} Budget Exceeded',
            'message': 'You have exceeded your budget for ${budgetData['budget'].category} by ${NumberFormat.currency(symbol: '₹').format(budgetData['spent'] - budgetData['budget'].limit)}.',
            'severity': 'high',
            'category': budgetData['budget'].category,
            'amount': budgetData['spent'] - budgetData['budget'].limit,
            'canHide': true,
            'resetMonthly': true,
          });
        } else if (budgetData['isNearLimit']) {
          alerts.add({
            'type': 'category_near_limit',
            'priority': 'high',
            'title': '${budgetData['budget'].category} Near Budget Limit',
            'message': 'You are approaching your budget limit for ${budgetData['budget'].category}. You have ${NumberFormat.currency(symbol: '₹').format(budgetData['budget'].limit - budgetData['spent'])} remaining.',
            'severity': 'medium',
            'category': budgetData['budget'].category,
            'percentage': budgetData['percentage'],
            'canHide': true,
            'resetMonthly': true,
          });
        }
      }
    }

    // 2. MEDIUM PRIORITY: Overall budget alerts - only show if there's actually an overall budget set
    if (analysis['hasOverallBudget']) {
      if (analysis['isOverBudget']) {
        alerts.add({
          'type': 'overall_budget_exceeded',
          'priority': 'medium',
          'title': 'Overall Budget Exceeded',
          'message': 'You have exceeded your overall budget by ${NumberFormat.currency(symbol: '₹').format(analysis['incomeDeficit'])}. Consider reviewing your spending patterns.',
          'severity': 'high',
          'amount': analysis['totalSpent'] - analysis['effectiveTotalBudget'],
          'canHide': true,
          'resetMonthly': true,
        });
      } else if (analysis['isNearLimit']) {
        alerts.add({
          'type': 'overall_budget_near_limit',
          'priority': 'medium',
          'title': 'Overall Budget Near Limit',
          'message': 'You are approaching your overall budget limit. You have ${NumberFormat.currency(symbol: '₹').format(analysis['totalRemaining'])} remaining.',
          'severity': 'medium',
          'percentage': analysis['overallPercentage'],
          'canHide': true,
          'resetMonthly': true,
        });
      }
    }

    // 3. LOW PRIORITY: Income-based warning - when expenses exceed income
    if (analysis['isOverIncome'] && analysis['effectiveIncome'] > 0) {
      final incomeSource = analysis['salaryIncome'] > 0 ? 'salary' : 'income';
      final deficit = analysis['incomeDeficit'];
      
      alerts.add({
        'type': 'income_limit_exceeded',
        'priority': 'low',
        'title': 'Expenses Exceed Income',
        'message': '⚠️ Your expenses (${NumberFormat.currency(symbol: '₹').format(analysis['totalSpent'])}) exceed your $incomeSource (${NumberFormat.currency(symbol: '₹').format(analysis['effectiveIncome'])}) by ${NumberFormat.currency(symbol: '₹').format(deficit)}. This might be due to forgetting to add income, not wanting to add it, or other reasons. You might be using your savings.',
        'severity': 'medium',
        'deficit': deficit,
        'canHide': true,
        'resetMonthly': true,
        'isIncomeWarning': true,
      });
    }

    // Sort alerts by priority (high, medium, low)
    alerts.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
    });

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
              'Consider creating a budget for ${entry.key} as you spend ${NumberFormat.currency(symbol: '₹').format(entry.value)} monthly.',
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

    // Overall budget recommendation if not set
    if (!analysis['hasOverallBudget']) {
      final averageSpending = trends['averageMonthlySpending'];
      if (averageSpending > 0) {
        recommendations.add({
          'type': 'set_overall_budget',
          'message': 'Consider setting an overall monthly budget to better control your spending.',
          'suggestedAmount': averageSpending * 0.9, // Suggest 90% of average spending
        });
      }
    }

    // Income management recommendation
    if (analysis['isOverIncome'] && analysis['effectiveIncome'] > 0) {
      recommendations.add({
        'type': 'income_management',
        'message': 'Your expenses exceed your income. Consider tracking all income sources or reviewing your spending habits.',
        'deficit': analysis['incomeDeficit'],
      });
    }

    return recommendations;
  }

  // Get overall budget for a specific month
  static Future<OverallBudget?> getOverallBudgetForMonth(DateTime month) async {
    final overallBudgets = await DataService.getOverallBudgets();
    
    for (final budget in overallBudgets) {
      if (budget.isActive &&
          budget.startDate.year == month.year &&
          budget.startDate.month == month.month) {
        return budget;
      }
    }
    
    return null;
  }

  // Set overall budget for a month
  static Future<void> setOverallBudget(DateTime month, double limit) async {
    final existingBudget = await getOverallBudgetForMonth(month);
    
    if (existingBudget != null) {
      // Update existing budget
      final updatedBudget = existingBudget.copyWith(limit: limit);
      await DataService.updateOverallBudget(updatedBudget);
    } else {
      // Create new budget
      final newBudget = OverallBudget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        limit: limit,
        startDate: DateTime(month.year, month.month, 1),
        endDate: DateTime(month.year, month.month + 1, 0),
        name: 'Overall Budget - ${month.month}/${month.year}',
      );
      await DataService.addOverallBudget(newBudget);
    }
  }

  // Calculate monthly income (prioritizing salary)
  static Future<double> getMonthlyIncome(DateTime month) async {
    final transactions = await DataService.getTransactions();
    
    final monthTransactions = transactions
        .where(
          (transaction) =>
              transaction.date.year == month.year &&
              transaction.date.month == month.month &&
              transaction.type == 'income',
        )
        .toList();
    
    double totalIncome = 0.0;
    double salaryIncome = 0.0;
    
    for (final transaction in monthTransactions) {
      totalIncome += transaction.amount;
      if (transaction.category.toLowerCase() == 'salary') {
        salaryIncome += transaction.amount;
      }
    }
    
    // Return salary income if available, otherwise total income
    return salaryIncome > 0 ? salaryIncome : totalIncome;
  }
}
