import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:spendwise/services/app_state.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:spendwise/screens/shared/custom_drawer.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/widgets/common/search_bar.dart';
import 'package:spendwise/widgets/common/display_options_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum TimePeriod { daily, weekly, monthly, threeMonths, sixMonths, yearly }

enum TransactionFilter { all, income, expense }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
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
  bool _isRefreshing = false;

  double _totalExpenses = 0;
  double _totalIncome = 0;
  double _balance = 0;
  final Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen to AppState changes to refresh dashboard when transactions are updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addListener(_onAppStateChanged);
    });

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh dashboard when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    // Remove listener when disposing
    final appState = Provider.of<AppState>(context, listen: false);
    appState.removeListener(_onAppStateChanged);

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _onAppStateChanged() {
    // Refresh dashboard when AppState changes
    if (mounted) {
      // Only refresh if we have new transactions to avoid unnecessary refreshes
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.transactions.length != _allTransactions.length ||
          _hasNewTransactions(appState.transactions)) {
        _loadData();
      }
    }
  }

  bool _hasNewTransactions(List<Transaction> newTransactions) {
    if (newTransactions.length != _allTransactions.length) return true;

    // Check if any transaction IDs are different
    final currentIds = _allTransactions.map((t) => t.id).toSet();
    final newIds = newTransactions.map((t) => t.id).toSet();

    return !currentIds.containsAll(newIds) || !newIds.containsAll(currentIds);
  }

  Future<void> _loadData() async {
    try {
      // Set refreshing state for smooth UI update
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }

      final appState = Provider.of<AppState>(context, listen: false);
      final loans = await LoanService.getLoans();

      // Get latest data from AppState
      List<Transaction> transactions;
      List<Account> accounts;

      // Ensure AppState has the latest data
      if (appState.transactions.isEmpty) {
        await appState.loadAllData();
      }

      transactions = appState.transactions;
      accounts = appState.accounts;

      if (mounted) {
        // Only update state if data has actually changed
        final hasDataChanged = _hasDataChanged(transactions, accounts, loans);

        if (hasDataChanged) {
          // Smooth state update with fade transition
          setState(() {
            _allTransactions = transactions;
            _loans = loans;
            _accounts = accounts;
            _filterTransactionsByPeriod();
            _calculateTotals();
            _calculateCategoryExpenses();
          });
        }
      }

      // Clear refreshing state
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Clear refreshing state on error
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  bool _hasDataChanged(
    List<Transaction> newTransactions,
    List<Account> newAccounts,
    List<Loan> newLoans,
  ) {
    // Check if transactions have changed
    if (newTransactions.length != _allTransactions.length) return true;

    // Check if any transaction has been modified
    for (int i = 0; i < newTransactions.length; i++) {
      if (i >= _allTransactions.length ||
          newTransactions[i].id != _allTransactions[i].id ||
          newTransactions[i].amount != _allTransactions[i].amount ||
          newTransactions[i].type != _allTransactions[i].type ||
          newTransactions[i].date != _allTransactions[i].date) {
        return true;
      }
    }

    // Check if accounts have changed
    if (newAccounts.length != _accounts.length) return true;

    // Check if loans have changed
    if (newLoans.length != _loans.length) return true;

    return false;
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
          return transaction.type == 'income' ||
              transaction.type.toLowerCase() == 'income';
        case TransactionFilter.expense:
          return transaction.type == 'expense' ||
              transaction.type.toLowerCase() == 'expense';
        case TransactionFilter.all:
          return true;
      }
    }).toList();

    // Sort by date (newest first)
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  void _calculateTotals() {
    _totalExpenses = _allTransactions
        .where(
          (t) =>
              (t.type == 'expense' || t.type.toLowerCase() == 'expense') &&
              _isTransactionInPeriod(t),
        )
        .fold(0, (sum, item) => sum + item.amount);

    _totalIncome = _allTransactions
        .where(
          (t) =>
              (t.type == 'income' || t.type.toLowerCase() == 'income') &&
              _isTransactionInPeriod(t),
        )
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
                  color: Colors.red.withValues(alpha: 0.1),
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
    // The AppState listener will automatically refresh the dashboard
    // when the user returns, so no need to manually call _loadData()
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

  void _showDisplayOptions() async {
    await showDisplayOptionsDialog(
      context,
      selectedViewMode: _getPeriodDisplayName(_selectedPeriod),
      showTotal: _showTotal,
      carryOver: _carryOver,
      onViewModeChanged: (mode) {
        setState(() {
          // Convert the mode string back to TimePeriod enum
          switch (mode) {
            case 'DAILY':
              _selectedPeriod = TimePeriod.daily;
              break;
            case 'WEEKLY':
              _selectedPeriod = TimePeriod.weekly;
              break;
            case 'MONTHLY':
              _selectedPeriod = TimePeriod.monthly;
              break;
            case '3 MONTHS ★':
              _selectedPeriod = TimePeriod.threeMonths;
              break;
            case '6 MONTHS ★':
              _selectedPeriod = TimePeriod.sixMonths;
              break;
            case 'YEARLY ★':
              _selectedPeriod = TimePeriod.yearly;
              break;
          }
          _filterTransactionsByPeriod();
          _calculateTotals();
          _calculateCategoryExpenses();
        });
      },
      onShowTotalChanged: (value) {
        setState(() {
          _showTotal = value;
        });
      },
      onCarryOverChanged: (value) {
        setState(() {
          _carryOver = value;
        });
      },
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
                'SpendWise',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cursive',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  InlineSearchBar(
                    hintText: 'Search by title, category, or notes...',
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterTransactionsByPeriod();
                        _calculateTotals();
                        _calculateCategoryExpenses();
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                        _filterTransactionsByPeriod();
                        _calculateTotals();
                        _calculateCategoryExpenses();
                      });
                    },
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

          // Expense/Income/Balance summary with smooth animation
          if (_showTotal)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _buildSummaryRow(),
            ),

          // Subtle loading indicator with fade animation
          AnimatedOpacity(
            opacity: _isRefreshing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _isRefreshing
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Updating...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
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
    final isTransfer = transaction.type == 'transfer';
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    return GestureDetector(
      onTap: () => _showTransactionOptions(transaction),
      onLongPress: () => _showTransactionOptions(transaction),
      child: Container(
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
              isTransfer
                  ? '${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}'
                  : '${isIncome ? '+' : '-'}${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTransfer
                    ? Colors.blue
                    : (isIncome ? Colors.green : Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(
                  'Edit ${_getTransactionTypeName(transaction.type)}',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _editTransaction(transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete ${_getTransactionTypeName(transaction.type)}',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteTransaction(transaction);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalculatorTransactionScreen(
          initialType: transaction.type,
          initialDate: transaction.date,
          editingTransaction: transaction,
        ),
      ),
    );
    // The AppState listener will automatically refresh the dashboard
    // when the user returns, so no need to manually call _loadData()
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this ${_getTransactionTypeName(transaction.type)}? This action cannot be undone.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DataService.deleteTransaction(transaction.id);
      // The AppState listener will automatically refresh the dashboard
      // when the transaction is deleted, so no need to manually call _loadData()
    }
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

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      case 'transfer':
        return 'Transfer';
      default:
        return 'Transaction';
    }
  }
}
