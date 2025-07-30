import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:expense_tracker/screens/calculator_transaction_screen.dart';
import 'package:intl/intl.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  List<Budget> _budgets = [];
  TimePeriod _selectedPeriod = TimePeriod.monthly;
  DateTime _selectedDate = DateTime.now();

  double _totalExpenses = 0;
  double _totalBudget = 0;
  Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DataService.getTransactions();
    final budgets = await DataService.getBudgets();

    setState(() {
      _allTransactions = transactions;
      _budgets = budgets;
      _filterTransactionsByPeriod();
      _calculateTotals();
      _calculateCategoryExpenses();
    });
  }

  void _filterTransactionsByPeriod() {
    final now = _selectedDate;
    DateTime startDate;
    DateTime endDate;

    switch (_selectedPeriod) {
      case TimePeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case TimePeriod.weekly:
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case TimePeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate);
    }).toList();
  }

  void _calculateTotals() {
    _totalExpenses = _filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);

    // Calculate budget for the selected period
    _totalBudget = _budgets
        .where((budget) => _isBudgetInPeriod(budget))
        .fold(0, (sum, budget) => sum + budget.limit);
  }

  bool _isBudgetInPeriod(Budget budget) {
    final now = _selectedDate;
    switch (_selectedPeriod) {
      case TimePeriod.monthly:
        return budget.startDate.year == now.year &&
            budget.startDate.month == now.month;
      case TimePeriod.yearly:
        return budget.startDate.year == now.year;
      default:
        return budget.startDate.isBefore(now.add(const Duration(days: 1))) &&
            budget.endDate.isAfter(now.subtract(const Duration(days: 1)));
    }
  }

  void _calculateCategoryExpenses() {
    _categoryExpenses.clear();
    for (final transaction in _filteredTransactions.where(
      (t) => t.type == 'expense',
    )) {
      _categoryExpenses[transaction.category] =
          (_categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getDateRangeText()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time period navigation
                _buildTimePeriodTabs(),
                const SizedBox(height: 20),

                // Budget vs Expense summary
                _buildBudgetSummary(),
                const SizedBox(height: 20),

                // Category breakdown
                _buildCategoryBreakdown(),
                const SizedBox(height: 20),

                // Recent transactions
                _buildRecentTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDateRangeText() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return DateFormat('MMM dd, yyyy').format(_selectedDate);
      case TimePeriod.weekly:
        final weekStart = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd').format(weekEnd)}';
      case TimePeriod.monthly:
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case TimePeriod.yearly:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterTransactionsByPeriod();
        _calculateTotals();
        _calculateCategoryExpenses();
      });
    }
  }

  void _navigateToAddTransaction(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorTransactionScreen(initialType: type),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Widget _buildTimePeriodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _filterTransactionsByPeriod();
                  _calculateTotals();
                  _calculateCategoryExpenses();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final budgetProgress = _totalBudget > 0
        ? _totalExpenses / _totalBudget
        : 0.0;
    final overSpend = _totalExpenses - _totalBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_totalBudget > 0)
                  Text(
                    '${(budgetProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: budgetProgress > 0.9
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_totalBudget > 0) ...[
              LinearProgressIndicator(
                value: budgetProgress.clamp(0.0, 1.0),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  budgetProgress > 0.9
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Budget',
                    _totalBudget,
                    Theme.of(context).colorScheme.primary,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Expenses',
                    _totalExpenses,
                    Theme.of(context).colorScheme.error,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),

            if (overSpend > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryCard(
                'Over Spend',
                overSpend,
                Theme.of(context).colorScheme.error,
                Icons.warning,
                isNegative: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon, {
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${isNegative ? '-' : ''}${NumberFormat.currency(symbol: '₹').format(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_categoryExpenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expenses in this period',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    final sortedCategories = _categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map(
              (entry) => _buildCategoryItem(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount) {
    final percentage = _totalExpenses > 0 ? (amount / _totalExpenses) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              NumberFormat.currency(symbol: '₹').format(amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactions');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _filteredTransactions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'No transactions in this period',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  )
                : Column(
                    children: _filteredTransactions
                        .take(5)
                        .map(
                          (transaction) => _buildTransactionItem(transaction),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isIncome
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            size: 16,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹').format(transaction.amount)}',
          style: TextStyle(
            color: isIncome
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
