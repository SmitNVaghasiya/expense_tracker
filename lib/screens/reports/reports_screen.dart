import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _balance = 0;
  final Map<String, double> _expenseCategories = {};
  final Map<String, double> _incomeCategories = {};
  final List<Map<String, dynamic>> _monthlyData = [];
  final Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _topExpenses = [];
  final List<Map<String, dynamic>> _spendingInsights = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DataService.getTransactions();

    setState(() {
      // Calculate totals
      _totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0, (sum, item) => sum + item.amount);

      _totalExpenses = transactions
          .where((t) => t.type == 'expense')
          .fold(0, (sum, item) => sum + item.amount);

      _balance = _totalIncome - _totalExpenses;

      // Calculate category breakdowns
      _calculateCategoryBreakdowns(transactions);
      _calculateMonthlyData(transactions);
      _calculateAnalytics(transactions);
      _calculateTopExpenses(transactions);
      _calculateSpendingInsights(transactions);
    });
  }

  void _calculateCategoryBreakdowns(List<Transaction> transactions) {
    _expenseCategories.clear();
    _incomeCategories.clear();

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        _expenseCategories[transaction.category] =
            (_expenseCategories[transaction.category] ?? 0) +
            transaction.amount;
      } else if (transaction.type == 'income') {
        _incomeCategories[transaction.category] =
            (_incomeCategories[transaction.category] ?? 0) + transaction.amount;
      }
    }
  }

  void _calculateAnalytics(List<Transaction> transactions) {
    _analytics.clear();

    // Calculate average daily spending
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    if (expenses.isNotEmpty) {
      final firstDate = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final lastDate = expenses
          .map((e) => e.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final daysDiff = lastDate.difference(firstDate).inDays + 1;
      _analytics['averageDailySpending'] = _totalExpenses / daysDiff;
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
      _analytics['spendingTrend'] =
          ((currentMonthExpenses - lastMonthExpenses) / lastMonthExpenses) *
          100;
    }

    // Calculate savings rate
    if (_totalIncome > 0) {
      _analytics['savingsRate'] =
          ((_totalIncome - _totalExpenses) / _totalIncome) * 100;
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
      _analytics['mostExpensiveDay'] = {
        'date': mostExpensiveDay.key,
        'amount': mostExpensiveDay.value,
      };
    }
  }

  void _calculateTopExpenses(List<Transaction> transactions) {
    _topExpenses.clear();

    final expenses = transactions.where((t) => t.type == 'expense').toList();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));

    _topExpenses = expenses
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

  void _calculateSpendingInsights(List<Transaction> transactions) {
    _spendingInsights.clear();

    final expenses = transactions.where((t) => t.type == 'expense').toList();

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
      _spendingInsights.add({
        'type': 'top_category',
        'title': 'Highest Spending Category',
        'value': topCategory.key,
        'amount': topCategory.value,
        'percentage': (topCategory.value / _totalExpenses) * 100,
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
      _spendingInsights.add({
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
    final totalDays = DateTime.now().difference(DateTime(2020)).inDays + 1;
    final spendingFrequency = (daysWithExpenses / totalDays) * 100;

    _spendingInsights.add({
      'type': 'frequency',
      'title': 'Spending Frequency',
      'value': '${spendingFrequency.toStringAsFixed(1)}% of days',
      'amount': spendingFrequency,
    });
  }

  Color _getCategoryColor(String category) {
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

  void _calculateMonthlyData(List<Transaction> transactions) {
    _monthlyData.clear();
    final Map<String, double> monthlyExpenses = {};
    final Map<String, double> monthlyIncome = {};

    for (final transaction in transactions) {
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
      _monthlyData.add({
        'month': month,
        'expenses': monthlyExpenses[month] ?? 0,
        'income': monthlyIncome[month] ?? 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(symbol: '₹').format(_balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Income',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  symbol: '₹',
                                ).format(_totalIncome),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Expenses',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  symbol: '₹',
                                ).format(_totalExpenses),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category Breakdown
                if (_expenseCategories.isNotEmpty ||
                    _incomeCategories.isNotEmpty) ...[
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Expense Categories Pie Chart
                  if (_expenseCategories.isNotEmpty) ...[
                    const Text(
                      'Expense Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _expenseCategories.entries.map((entry) {
                            final percentage = (_totalExpenses > 0)
                                ? (entry.value / _totalExpenses * 100)
                                : 0;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(1)}%',
                              radius: 60,
                              color: _getCategoryColor(entry.key),
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Legend
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _expenseCategories.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              entry.key,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.key}: ${NumberFormat.currency(symbol: '₹').format(entry.value)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(entry.key),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Income Categories Pie Chart
                  if (_incomeCategories.isNotEmpty) ...[
                    const Text(
                      'Income Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _incomeCategories.entries.map((entry) {
                            final percentage = (_totalIncome > 0)
                                ? (entry.value / _totalIncome * 100)
                                : 0;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(1)}%',
                              radius: 60,
                              color: _getCategoryColor(entry.key),
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Legend
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _incomeCategories.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              entry.key,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.key}: ${NumberFormat.currency(symbol: '₹').format(entry.value)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(entry.key),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],

                // Monthly Trends
                if (_monthlyData.isNotEmpty) ...[
                  const Text(
                    'Monthly Trends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            _monthlyData.fold(
                              0.0,
                              (max, data) =>
                                  (data['expenses'] + data['income']) > max
                                  ? (data['expenses'] + data['income'])
                                  : max,
                            ) *
                            1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < _monthlyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _monthlyData[value.toInt()]['month'],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  NumberFormat.compact().format(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _monthlyData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data['expenses'],
                                color: Theme.of(context).colorScheme.error,
                                width: 8,
                              ),
                              BarChartRodData(
                                toY: data['income'],
                                color: Theme.of(context).colorScheme.primary,
                                width: 8,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      const Text('Expenses', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text('Income', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],

                // Analytics Section
                if (_analytics.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Analytics & Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Analytics Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      if (_analytics['averageDailySpending'] != null)
                        _buildAnalyticsCard(
                          'Average Daily Spending',
                          NumberFormat.currency(
                            symbol: '₹',
                          ).format(_analytics['averageDailySpending']),
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      if (_analytics['savingsRate'] != null)
                        _buildAnalyticsCard(
                          'Savings Rate',
                          '${_analytics['savingsRate'].toStringAsFixed(1)}%',
                          Icons.savings,
                          Colors.green,
                        ),
                      if (_analytics['spendingTrend'] != null)
                        _buildAnalyticsCard(
                          'Spending Trend',
                          '${_analytics['spendingTrend'] > 0 ? '+' : ''}${_analytics['spendingTrend'].toStringAsFixed(1)}%',
                          _analytics['spendingTrend'] > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          _analytics['spendingTrend'] > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      if (_analytics['mostExpensiveDay'] != null)
                        _buildAnalyticsCard(
                          'Most Expensive Day',
                          NumberFormat.currency(
                            symbol: '₹',
                          ).format(_analytics['mostExpensiveDay']['amount']),
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                    ],
                  ),
                ],

                // Top Expenses Section
                if (_topExpenses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Top 5 Expenses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _topExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _topExpenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(
                              expense['category'],
                            ),
                            child: Text(
                              expense['category'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(expense['title']),
                          subtitle: Text(expense['category']),
                          trailing: Text(
                            NumberFormat.currency(
                              symbol: '₹',
                            ).format(expense['amount']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Spending Insights Section
                if (_spendingInsights.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Spending Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _spendingInsights.length,
                    itemBuilder: (context, index) {
                      final insight = _spendingInsights[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            insight['type'] == 'top_category'
                                ? Icons.category
                                : insight['type'] == 'weekly_pattern'
                                ? Icons.calendar_view_week
                                : Icons.analytics,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(insight['title']),
                          subtitle: Text(insight['value']),
                          trailing: insight['amount'] != null
                              ? Text(
                                  NumberFormat.currency(
                                    symbol: '₹',
                                  ).format(insight['amount']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CalculatorTransactionScreen(initialType: 'expense'),
      ),
    );

    if (result == true) {
      // The transaction was added successfully
      // The home screen will handle navigation to dashboard
      // We just need to refresh the data
      _loadData();
    }
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
