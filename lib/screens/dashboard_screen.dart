import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/loan.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:expense_tracker/services/loan_service.dart';
import 'package:expense_tracker/screens/calculator_transaction_screen.dart';
import 'package:expense_tracker/screens/custom_drawer.dart';
import 'package:expense_tracker/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum TimePeriod { daily, weekly, monthly, threeMonths, sixMonths, yearly }

enum TransactionFilter { all, income, expense }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  List<Loan> _loans = [];
  List<Account> _accounts = [];
  TimePeriod _selectedPeriod = TimePeriod.daily;
  DateTime _selectedDate = DateTime.now();
  TransactionFilter _transactionFilter = TransactionFilter.all;

  bool _showTotal = true;
  bool _carryOver = true;
  String _searchQuery = '';
  bool _isSearchActive = false;

  double _totalExpenses = 0;
  double _totalIncome = 0;
  double _balance = 0;
  final Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DataService.getTransactions();
    final loans = await LoanService.getLoans();
    final accounts = await DataService.getAccounts();

    setState(() {
      _allTransactions = transactions;
      _loans = loans;
      _accounts = accounts;
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
      case TimePeriod.threeMonths:
        startDate = DateTime(now.year, now.month - 2, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case TimePeriod.sixMonths:
        startDate = DateTime(now.year, now.month - 5, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case TimePeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      final isInPeriod =
          transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate);

      if (!isInPeriod) return false;

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = transaction.title.toLowerCase();
        final category = transaction.category.toLowerCase();
        final notes = transaction.notes?.toLowerCase() ?? '';

        if (!title.contains(query) &&
            !category.contains(query) &&
            !notes.contains(query)) {
          return false;
        }
      }

      switch (_transactionFilter) {
        case TransactionFilter.income:
          return transaction.type == 'income';
        case TransactionFilter.expense:
          return transaction.type == 'expense';
        case TransactionFilter.all:
          return true;
      }
    }).toList();

    // Sort by date (newest first)
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  void _calculateTotals() {
    _totalExpenses = _allTransactions
        .where((t) => t.type == 'expense' && _isTransactionInPeriod(t))
        .fold(0, (sum, item) => sum + item.amount);

    _totalIncome = _allTransactions
        .where((t) => t.type == 'income' && _isTransactionInPeriod(t))
        .fold(0, (sum, item) => sum + item.amount);

    // Calculate balance including loan impact
    _balance = _totalIncome - _totalExpenses;

    // Add loan impact to balance
    final loanImpact = _calculateLoanImpact();
    _balance += loanImpact;
  }

  double _calculateLoanImpact() {
    double impact = 0;

    for (final loan in _loans) {
      if (loan.status == 'pending') {
        if (loan.type == 'lent') {
          // Money lent reduces available balance
          impact -= loan.remainingAmount;
        } else {
          // Money borrowed increases available balance
          impact += loan.remainingAmount;
        }
      }
    }

    return impact;
  }

  bool _isTransactionInPeriod(Transaction transaction) {
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
      case TimePeriod.threeMonths:
        startDate = DateTime(now.year, now.month - 2, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case TimePeriod.sixMonths:
        startDate = DateTime(now.year, now.month - 5, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      case TimePeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;
    }

    return transaction.date.isAfter(
          startDate.subtract(const Duration(days: 1)),
        ) &&
        transaction.date.isBefore(endDate);
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

  String _getAccountName(String? accountId) {
    if (accountId == null) return 'Unknown';
    final account = _accounts.firstWhere(
      (account) => account.id == accountId,
      orElse: () => Account(
        id: accountId,
        name: accountId,
        balance: 0,
        type: 'unknown',
        createdAt: DateTime.now(),
      ),
    );
    return account.name;
  }

  Widget _buildLoanSummarySection() {
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    // Calculate loan statistics
    final pendingLoans = _loans
        .where((loan) => loan.status == 'pending')
        .toList();
    final overdueLoans = _loans.where((loan) => loan.isOverdue).toList();
    final nextPaymentDue = _loans
        .where((loan) => loan.isNextPaymentDue)
        .toList();

    double totalLent = 0;
    double totalBorrowed = 0;
    double totalRemainingLent = 0;
    double totalRemainingBorrowed = 0;

    for (final loan in _loans) {
      if (loan.type == 'lent') {
        totalLent += loan.amount;
        if (loan.status == 'pending') {
          totalRemainingLent += loan.remainingAmount;
        }
      } else {
        totalBorrowed += loan.amount;
        if (loan.status == 'pending') {
          totalRemainingBorrowed += loan.remainingAmount;
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Loan Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (overdueLoans.isNotEmpty || nextPaymentDue.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${overdueLoans.length + nextPaymentDue.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Loan amounts
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lent',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '${currencyProvider.currencySymbol}${totalLent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (totalRemainingLent > 0)
                        Text(
                          'Remaining: ${currencyProvider.currencySymbol}${totalRemainingLent.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Borrowed',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '${currencyProvider.currencySymbol}${totalBorrowed.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      if (totalRemainingBorrowed > 0)
                        Text(
                          'Remaining: ${currencyProvider.currencySymbol}${totalRemainingBorrowed.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (overdueLoans.isNotEmpty || nextPaymentDue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        overdueLoans.isNotEmpty
                            ? '${overdueLoans.length} overdue loan${overdueLoans.length > 1 ? 's' : ''}'
                            : '${nextPaymentDue.length} payment${nextPaymentDue.length > 1 ? 's' : ''} due',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Search Transactions',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search by title, category, or notes...',
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterTransactionsByPeriod();
                _calculateTotals();
                _calculateCategoryExpenses();
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterTransactionsByPeriod();
                  _calculateTotals();
                  _calculateCategoryExpenses();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Clean Header
                _buildCleanHeader(),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loan Summary Section
                      if (_loans.isNotEmpty) ...[
                        _buildLoanSummarySection(),
                        const SizedBox(height: 16),
                      ],

                      // Transaction filter pills
                      _buildTransactionFilterPills(),

                      const SizedBox(height: 16),

                      // Transaction List
                      _buildTransactionList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction('expense'),
        child: const Icon(Icons.add),
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
      case TimePeriod.threeMonths:
        final startMonth = DateTime(
          _selectedDate.year,
          _selectedDate.month - 2,
          1,
        );
        return '${DateFormat('MMM').format(startMonth)} - ${DateFormat('MMM yyyy').format(_selectedDate)}';
      case TimePeriod.sixMonths:
        final startMonth = DateTime(
          _selectedDate.year,
          _selectedDate.month - 5,
          1,
        );
        return '${DateFormat('MMM').format(startMonth)} - ${DateFormat('MMM yyyy').format(_selectedDate)}';
      case TimePeriod.yearly:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  void _navigateToAddTransaction(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorTransactionScreen(
          initialType: type,
          initialDate: _selectedDate,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToPreviousPeriod() {
    setState(() {
      switch (_selectedPeriod) {
        case TimePeriod.daily:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case TimePeriod.weekly:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case TimePeriod.monthly:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            _selectedDate.day,
          );
          break;
        case TimePeriod.threeMonths:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 3,
            _selectedDate.day,
          );
          break;
        case TimePeriod.sixMonths:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 6,
            _selectedDate.day,
          );
          break;
        case TimePeriod.yearly:
          _selectedDate = DateTime(
            _selectedDate.year - 1,
            _selectedDate.month,
            _selectedDate.day,
          );
          break;
      }
      _filterTransactionsByPeriod();
      _calculateTotals();
      _calculateCategoryExpenses();
    });
  }

  void _navigateToNextPeriod() {
    setState(() {
      switch (_selectedPeriod) {
        case TimePeriod.daily:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case TimePeriod.weekly:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case TimePeriod.monthly:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 1,
            _selectedDate.day,
          );
          break;
        case TimePeriod.threeMonths:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 3,
            _selectedDate.day,
          );
          break;
        case TimePeriod.sixMonths:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 6,
            _selectedDate.day,
          );
          break;
        case TimePeriod.yearly:
          _selectedDate = DateTime(
            _selectedDate.year + 1,
            _selectedDate.month,
            _selectedDate.day,
          );
          break;
      }
      _filterTransactionsByPeriod();
      _calculateTotals();
      _calculateCategoryExpenses();
    });
  }

  void _showDisplayOptions() {
    showDialog(
      context: context,
      builder: (context) => _buildDisplayOptionsModal(),
    );
  }

  Future<void> _showDatePicker() async {
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

  Widget _buildCleanHeader() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row with hamburger menu, title, and search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              Text(
                'MyMoney',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cursive',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: _showSearchDialog,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: _showDisplayOptions,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.green),
                onPressed: _navigateToPreviousPeriod,
              ),
              GestureDetector(
                onTap: _showDatePicker,
                child: Text(
                  _getDateRangeText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.green),
                onPressed: _navigateToNextPeriod,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Expense/Income/Balance summary
          if (_showTotal) _buildSummaryRow(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'EXPENSE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyProvider.currencySymbol}${_totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'INCOME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyProvider.currencySymbol}${_totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'BALANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyProvider.currencySymbol}${_balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionFilterPills() {
    return Row(
      children: [
        _buildFilterPill('All', TransactionFilter.all, Icons.check),
        const SizedBox(width: 8),
        _buildFilterPill(
          'Income',
          TransactionFilter.income,
          Icons.arrow_downward,
        ),
        const SizedBox(width: 8),
        _buildFilterPill(
          'Expense',
          TransactionFilter.expense,
          Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildFilterPill(
    String label,
    TransactionFilter filter,
    IconData icon,
  ) {
    final isSelected = _transactionFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionFilter = filter;
          _filterTransactionsByPeriod();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No transactions in this period',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in _filteredTransactions) {
      final dateKey = DateFormat('MMM dd, EEEE').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return Column(
      children: groupedTransactions.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Transactions for this date
            ...entry.value.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green[100]
                  : _getCategoryColor(transaction.category),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: isIncome ? Colors.green[700] : Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      transaction.accountId == 'cash'
                          ? Icons.account_balance_wallet
                          : Icons.credit_card,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getAccountName(transaction.accountId),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isIncome ? '+' : '-'}${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayOptionsModal() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Display options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 24),

            // View mode section
            const Text(
              'View mode:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            ...TimePeriod.values.map(
              (period) => _buildOptionItem(
                _getPeriodDisplayName(period),
                _selectedPeriod == period,
                isPremium:
                    period == TimePeriod.threeMonths ||
                    period == TimePeriod.sixMonths ||
                    period == TimePeriod.yearly,
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                    _filterTransactionsByPeriod();
                    _calculateTotals();
                    _calculateCategoryExpenses();
                  });
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Show total section
            const Text(
              'Show total:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _buildOptionItem(
              'YES',
              _showTotal,
              onTap: () {
                setState(() {
                  _showTotal = true;
                });
                Navigator.pop(context);
              },
            ),

            _buildOptionItem(
              'NO',
              !_showTotal,
              onTap: () {
                setState(() {
                  _showTotal = false;
                });
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 24),

            // Carry over section
            const Text(
              'Carry over:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _buildOptionItem(
              'ON',
              _carryOver,
              onTap: () {
                setState(() {
                  _carryOver = true;
                });
                Navigator.pop(context);
              },
            ),

            _buildOptionItem(
              'OFF',
              !_carryOver,
              onTap: () {
                setState(() {
                  _carryOver = false;
                });
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'With Carry over enabled, monthly surplus will be added to the next month.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    String title,
    bool isSelected, {
    bool isPremium = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.green : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isPremium) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  String _getPeriodDisplayName(TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return 'DAILY';
      case TimePeriod.weekly:
        return 'WEEKLY';
      case TimePeriod.monthly:
        return 'MONTHLY';
      case TimePeriod.threeMonths:
        return '3 MONTHS';
      case TimePeriod.sixMonths:
        return '6 MONTHS';
      case TimePeriod.yearly:
        return 'YEARLY';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return Colors.red;
      case 'auto rickshaw':
      case 'transport':
        return Colors.blue;
      case 'snacks':
        return Colors.blue;
      case 'mobile recharge':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return Icons.restaurant;
      case 'auto rickshaw':
      case 'transport':
        return Icons.directions_bus;
      case 'snacks':
        return Icons.local_grocery_store;
      case 'mobile recharge':
        return Icons.phone;
      case 'salary':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
