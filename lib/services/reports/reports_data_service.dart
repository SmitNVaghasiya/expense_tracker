import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:intl/intl.dart';

class ReportsDataService {
  // Data storage
  double totalIncome = 0;
  double totalExpenses = 0;
  double balance = 0;
  final Map<String, double> expenseCategories = {};
  final Map<String, double> incomeCategories = {};
  final List<Map<String, dynamic>> monthlyData = [];
  final Map<String, dynamic> analytics = {};
  List<Map<String, dynamic>> topExpenses = [];
  final List<Map<String, dynamic>> spendingInsights = [];
  final Map<String, dynamic> budgetAdherence = {};
  final List<Map<String, dynamic>> monthlyBudgetAdherence = [];
  final List<Map<String, dynamic>> yearlyBudgetAdherence = [];

  // Date filtering
  DateTimeRange? selectedDateRange;
  String selectedDateRangeOption = 'All Time';
  List<Transaction> filteredTransactions = [];

  // Budget adherence period
  String budgetAdherencePeriod = 'Monthly';

  // Date range options
  static const List<String> dateRangeOptions = [
    'All Time',
    'This Month',
    'Last Month',
    'This Year',
    'Last Year',
    'Last 30 Days',
    'Last 90 Days',
    'Custom Range',
  ];

  // Load and process all data
  Future<void> loadData() async {
    final transactions = await DataService.getTransactions();
    filteredTransactions = _filterTransactionsByDateRange(transactions);

    _calculateTotals();
    _calculateCategoryBreakdowns();
    _calculateMonthlyData();
    _calculateAnalytics();
    _calculateTopExpenses();
    _calculateSpendingInsights();
    await _calculateBudgetAdherence();
  }

  // Filter transactions by date range
  List<Transaction> _filterTransactionsByDateRange(
    List<Transaction> transactions,
  ) {
    if (selectedDateRangeOption == 'All Time') {
      return transactions;
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedDateRangeOption) {
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      case 'Last Year':
        startDate = DateTime(now.year - 1, 1, 1);
        endDate = DateTime(now.year - 1, 12, 31);
        break;
      case 'Last 30 Days':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case 'Last 90 Days':
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
      case 'Custom Range':
        if (selectedDateRange != null) {
          startDate = selectedDateRange!.start;
          endDate = selectedDateRange!.end;
        } else {
          return transactions;
        }
        break;
      default:
        return transactions;
    }

    return transactions.where((transaction) {
      return transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Calculate totals
  void _calculateTotals() {
    totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);

    totalExpenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);

    balance = totalIncome - totalExpenses;
  }

  // Calculate category breakdowns
  void _calculateCategoryBreakdowns() {
    expenseCategories.clear();
    incomeCategories.clear();

    for (final transaction in filteredTransactions) {
      if (transaction.type == 'expense') {
        expenseCategories[transaction.category] =
            (expenseCategories[transaction.category] ?? 0) + transaction.amount;
      } else if (transaction.type == 'income') {
        incomeCategories[transaction.category] =
            (incomeCategories[transaction.category] ?? 0) + transaction.amount;
      }
    }
  }

  // Calculate monthly data
  void _calculateMonthlyData() {
    monthlyData.clear();
    final Map<String, double> monthlyExpenses = {};
    final Map<String, double> monthlyIncome = {};

    for (final transaction in filteredTransactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);

      if (transaction.type == 'expense') {
        monthlyExpenses[monthKey] =
            (monthlyExpenses[monthKey] ?? 0) + transaction.amount;
      } else if (transaction.type == 'income') {
        monthlyIncome[monthKey] =
            (monthlyIncome[monthKey] ?? 0) + transaction.amount;
      }
    }

    // Combine all months
    final allMonths = <String>{};
    allMonths.addAll(monthlyExpenses.keys);
    allMonths.addAll(monthlyIncome.keys);

    final sortedMonths = allMonths.toList()
      ..sort(
        (a, b) => DateFormat(
          'MMM yyyy',
        ).parse(a).compareTo(DateFormat('MMM yyyy').parse(b)),
      );

    for (final month in sortedMonths) {
      monthlyData.add({
        'month': month,
        'expenses': monthlyExpenses[month] ?? 0,
        'income': monthlyIncome[month] ?? 0,
      });
    }
  }

  // Calculate analytics
  void _calculateAnalytics() {
    analytics.clear();

    // Calculate average daily spending
    final expenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .toList();
    if (expenses.isNotEmpty) {
      final firstDate = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final lastDate = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final daysDiff = lastDate.difference(firstDate).inDays + 1;
      analytics['averageDailySpending'] = totalExpenses / daysDiff;
    }

    // Calculate spending trend
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final lastYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    final currentMonthExpenses = expenses
        .where(
          (e) => e.date.month == currentMonth && e.date.year == currentYear,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
    final lastMonthExpenses = expenses
        .where((e) => e.date.month == lastMonth && e.date.year == lastYear)
        .fold(0.0, (sum, e) => sum + e.amount);

    if (lastMonthExpenses > 0) {
      analytics['spendingTrend'] =
          ((currentMonthExpenses - lastMonthExpenses) / lastMonthExpenses) *
          100;
    }

    // Calculate savings rate
    if (totalIncome > 0) {
      analytics['savingsRate'] =
          ((totalIncome - totalExpenses) / totalIncome) * 100;
    }

    // Calculate most expensive day
    final dailyExpenses = <DateTime, double>{};
    for (final expense in expenses) {
      final day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + expense.amount;
    }

    if (dailyExpenses.isNotEmpty) {
      final mostExpensiveDay = dailyExpenses.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      analytics['mostExpensiveDay'] = {
        'date': mostExpensiveDay.key,
        'amount': mostExpensiveDay.value,
      };
    }
  }

  // Calculate top expenses
  void _calculateTopExpenses() {
    topExpenses.clear();

    final expenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .toList();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));

    topExpenses = expenses
        .take(5)
        .map(
          (expense) => {
            'id': expense.id,
            'title': expense.title,
            'amount': expense.amount,
            'category': expense.category,
            'date': expense.date,
            'account': expense.accountId,
          },
        )
        .toList();
  }

  // Calculate spending insights
  void _calculateSpendingInsights() {
    spendingInsights.clear();

    final expenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .toList();

    // Category spending analysis
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    if (categoryTotals.isNotEmpty) {
      final topCategory = categoryTotals.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      spendingInsights.add({
        'type': 'top_category',
        'title': 'Highest Spending Category',
        'value': topCategory.key,
        'amount': topCategory.value,
        'percentage': (topCategory.value / totalExpenses) * 100,
      });
    }

    // Weekly spending pattern
    final weeklySpending = <int, double>{};
    for (final expense in expenses) {
      final weekday = expense.date.weekday;
      weeklySpending[weekday] = (weeklySpending[weekday] ?? 0) + expense.amount;
    }

    if (weeklySpending.isNotEmpty) {
      final mostExpensiveDay = weeklySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      spendingInsights.add({
        'type': 'weekly_pattern',
        'title': 'Most Expensive Day of Week',
        'value': dayNames[mostExpensiveDay.key - 1],
        'amount': mostExpensiveDay.value,
      });
    }

    // Spending frequency
    final daysWithExpenses = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;

    // Calculate total days based on actual data range instead of hardcoded 2020
    final allDates = filteredTransactions.map((t) => t.date).toList();
    if (allDates.isNotEmpty) {
      final earliestDate = allDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final latestDate = allDates.reduce((a, b) => a.isAfter(b) ? a : b);
      final totalDays = latestDate.difference(earliestDate).inDays + 1;
      final spendingFrequency = (daysWithExpenses / totalDays) * 100;

      spendingInsights.add({
        'type': 'frequency',
        'title': 'Spending Frequency',
        'value': '${spendingFrequency.toStringAsFixed(1)}% of days',
        'amount': spendingFrequency,
      });
    } else {
      // Fallback if no transactions
      spendingInsights.add({
        'type': 'frequency',
        'title': 'Spending Frequency',
        'value': '0% of days',
        'amount': 0.0,
      });
    }
  }

  // Calculate budget adherence
  Future<void> _calculateBudgetAdherence() async {
    final budgets = await DataService.getBudgets();
    final overallBudgets = await DataService.getOverallBudgets();

    if (budgetAdherencePeriod == 'Monthly') {
      await _calculateMonthlyBudgetAdherence(budgets, overallBudgets);
    } else {
      await _calculateYearlyBudgetAdherence(budgets, overallBudgets);
    }
  }

  Future<void> _calculateMonthlyBudgetAdherence(
    List<Budget> budgets,
    List<OverallBudget> overallBudgets,
  ) async {
    monthlyBudgetAdherence.clear();

    // Get last 12 months
    final now = DateTime.now();
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      // Get month transactions
      final monthTransactions = filteredTransactions
          .where(
            (t) =>
                t.date.isAfter(month.subtract(const Duration(days: 1))) &&
                t.date.isBefore(monthEnd.add(const Duration(days: 1))),
          )
          .toList();

      // Calculate month expenses
      final monthExpenses = monthTransactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);

      // Get month budgets
      final monthBudgets = budgets
          .where(
            (b) =>
                b.startDate.year == month.year &&
                b.startDate.month == month.month,
          )
          .toList();

      final monthOverallBudgets = overallBudgets
          .where(
            (b) =>
                b.startDate.year == month.year &&
                b.startDate.month == month.month &&
                b.isActive == true,
          )
          .toList();

      // Calculate budget adherence
      int categoriesWithBudgets = 0;
      int categoriesUnderBudget = 0;
      int categoriesOverBudget = 0;
      double totalBudgetLimit = 0;
      double totalSpent = 0;

      for (final budget in monthBudgets) {
        if (budget.limit > 0) {
          categoriesWithBudgets++;
          totalBudgetLimit += budget.limit;

          final categorySpent = monthTransactions
              .where(
                (t) => t.type == 'expense' && t.category == budget.category,
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          totalSpent += categorySpent;

          if (categorySpent <= budget.limit) {
            categoriesUnderBudget++;
          } else {
            categoriesOverBudget++;
          }
        }
      }

      // Overall budget adherence
      double overallBudgetLimit = 0;
      if (monthOverallBudgets.isNotEmpty) {
        final overallBudget = monthOverallBudgets.first;
        overallBudgetLimit = overallBudget.limit;
      }

      final overallBudgetAdherence = overallBudgetLimit > 0
          ? (monthExpenses <= overallBudgetLimit
                ? 100.0
                : ((overallBudgetLimit / monthExpenses) * 100).clamp(0, 100))
          : 0.0;

      final categoryBudgetAdherence = categoriesWithBudgets > 0
          ? (categoriesUnderBudget / categoriesWithBudgets * 100)
          : 0.0;

      monthlyBudgetAdherence.add({
        'month': month,
        'monthName': DateFormat('MMM yyyy').format(month),
        'categoriesWithBudgets': categoriesWithBudgets,
        'categoriesUnderBudget': categoriesUnderBudget,
        'categoriesOverBudget': categoriesOverBudget,
        'categoryBudgetAdherence': categoryBudgetAdherence,
        'overallBudgetAdherence': overallBudgetAdherence,
        'totalBudgetLimit': totalBudgetLimit,
        'overallBudgetLimit': overallBudgetLimit,
        'totalSpent': monthExpenses,
        'budgetUtilization': totalBudgetLimit > 0
            ? (monthExpenses / totalBudgetLimit * 100).clamp(0, 100)
            : 0.0,
      });
    }
  }

  Future<void> _calculateYearlyBudgetAdherence(
    List<Budget> budgets,
    List<OverallBudget> overallBudgets,
  ) async {
    yearlyBudgetAdherence.clear();

    // Get last 5 years
    final now = DateTime.now();
    for (int i = 4; i >= 0; i--) {
      final year = now.year - i;
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31);

      // Get year transactions
      final yearTransactions = filteredTransactions
          .where(
            (t) =>
                t.date.isAfter(yearStart.subtract(const Duration(days: 1))) &&
                t.date.isBefore(yearEnd.add(const Duration(days: 1))),
          )
          .toList();

      // Calculate year expenses
      final yearExpenses = yearTransactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);

      // Get year budgets (aggregate monthly budgets)
      final yearBudgets = budgets
          .where((b) => b.startDate.year == year)
          .toList();
      final yearOverallBudgets = overallBudgets
          .where((b) => b.startDate.year == year && b.isActive == true)
          .toList();

      // Calculate yearly budget adherence
      int categoriesWithBudgets = 0;
      int categoriesUnderBudget = 0;
      int categoriesOverBudget = 0;
      double totalBudgetLimit = 0;
      double totalSpent = 0;

      // Group budgets by category and sum limits
      final Map<String, double> categoryBudgets = {};
      for (final budget in yearBudgets) {
        if (budget.limit > 0) {
          categoryBudgets[budget.category] =
              (categoryBudgets[budget.category] ?? 0) + budget.limit;
        }
      }

      for (final entry in categoryBudgets.entries) {
        categoriesWithBudgets++;
        totalBudgetLimit += entry.value;

        final categorySpent = yearTransactions
            .where((t) => t.type == 'expense' && t.category == entry.key)
            .fold(0.0, (sum, t) => sum + t.amount);

        totalSpent += categorySpent;

        if (categorySpent <= entry.value) {
          categoriesUnderBudget++;
        } else {
          categoriesOverBudget++;
        }
      }

      // Overall yearly budget adherence
      double overallBudgetLimit = 0;
      if (yearOverallBudgets.isNotEmpty) {
        overallBudgetLimit = yearOverallBudgets
            .map((b) => b.limit)
            .reduce((a, b) => a + b);
      }

      final overallBudgetAdherence = overallBudgetLimit > 0
          ? (yearExpenses <= overallBudgetLimit
                ? 100.0
                : ((overallBudgetLimit / yearExpenses) * 100).clamp(0, 100))
          : 0.0;

      final categoryBudgetAdherence = categoriesWithBudgets > 0
          ? (categoriesUnderBudget / categoriesWithBudgets * 100)
          : 0.0;

      yearlyBudgetAdherence.add({
        'year': year,
        'categoriesWithBudgets': categoriesWithBudgets,
        'categoriesUnderBudget': categoriesUnderBudget,
        'categoriesOverBudget': categoriesOverBudget,
        'categoryBudgetAdherence': categoryBudgetAdherence,
        'overallBudgetAdherence': overallBudgetAdherence,
        'totalBudgetLimit': totalBudgetLimit,
        'overallBudgetLimit': overallBudgetLimit,
        'totalSpent': yearExpenses,
        'budgetUtilization': totalBudgetLimit > 0
            ? (yearExpenses / totalBudgetLimit * 100).clamp(0, 100)
            : 0.0,
      });
    }
  }

  // Get category color
  static Color getCategoryColor(String category) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
      Colors.grey,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];

    final index = category.hashCode % colors.length;
    return colors[index];
  }

  // Get spending patterns data
  Map<String, dynamic> getSpendingPatterns() {
    final expenses = filteredTransactions
        .where((t) => t.type == 'expense')
        .toList();

    // Day of week spending
    final dayOfWeekSpending = <int, double>{};
    for (final expense in expenses) {
      final weekday = expense.date.weekday;
      dayOfWeekSpending[weekday] =
          (dayOfWeekSpending[weekday] ?? 0) + expense.amount;
    }

    // Time of day spending
    final timeOfDaySpending = <int, double>{};
    for (final expense in expenses) {
      final hour = expense.date.hour;
      final timeSlot = (hour / 6).floor(); // 0-3: 0-5, 6-11, 12-17, 18-23
      timeOfDaySpending[timeSlot] =
          (timeOfDaySpending[timeSlot] ?? 0) + expense.amount;
    }

    return {'dayOfWeek': dayOfWeekSpending, 'timeOfDay': timeOfDaySpending};
  }
}
