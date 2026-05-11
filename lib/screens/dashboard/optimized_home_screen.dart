import 'package:flutter/material.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/models/transaction.dart'; // Added for TransactionType
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/services/optimized_data_service.dart';
// import 'package:spendwise/widgets/common/account_card.dart';
// import 'package:spendwise/widgets/common/budget_card.dart';
import 'package:spendwise/widgets/common/transaction_card.dart';
import 'package:spendwise/widgets/common/empty_state_widget.dart';
// import 'package:spendwise/widgets/common/loading_indicator.dart';
import 'package:spendwise/widgets/common/filter_dropdown.dart';
import 'package:spendwise/widgets/common/search_bar.dart' as common_search_bar; // Aliased
// Unused demo imports removed
import 'package:spendwise/screens/shared/custom_drawer.dart';
// Unused core imports removed
import 'package:spendwise/core/performance_mixins.dart';
import 'package:intl/intl.dart';

class OptimizedHomeScreen extends StatefulWidget {
  const OptimizedHomeScreen({super.key, required this.transactionType});
  final TransactionType transactionType;

  @override
  State<OptimizedHomeScreen> createState() => _OptimizedHomeScreenState();
}

class _OptimizedHomeScreenState extends State<OptimizedHomeScreen>
    with
        ValueNotifierMixin,
        EfficientListMixin,
        ScrollPerformanceMixin,
        TickerProviderStateMixin {
  late final ValueNotifier<List<Transaction>> _transactionsNotifier;
  late final ValueNotifier<List<Transaction>> _filteredTransactionsNotifier;
  late final ValueNotifier<List<Account>> _accountsNotifier;
  late final ValueNotifier<List<Budget>> _budgetsNotifier;
  late final ValueNotifier<List<Category>> _categoriesNotifier;
  late final ValueNotifier<List<Group>> _groupsNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  late final ValueNotifier<Map<String, dynamic>> _summaryNotifier;

  TransactionType _transactionTypeFilter = TransactionType.all;
  String _categoryFilter = 'All';
  String _accountFilter = 'All';
  DateTime _startDateFilter = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDateFilter = DateTime.now();
  String _searchQuery = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _initializeNotifiers() {
    _transactionsNotifier = getNotifier('transactions', []);
    _filteredTransactionsNotifier = getNotifier('filteredTransactions', []);
    _accountsNotifier = getNotifier('accounts', []);
    _budgetsNotifier = getNotifier('budgets', []);
    _categoriesNotifier = getNotifier('categories', []);
    _groupsNotifier = getNotifier('groups', []);
    _isLoadingNotifier = getNotifier('isLoading', true);
    _summaryNotifier = getNotifier('summary', {});
  }

  Future<void> _loadData() async {
    _isLoadingNotifier.value = true;
    try {
      final transactions = await OptimizedDataService.getTransactions();
      final accounts = await OptimizedDataService.getAccounts();
      final budgets = await OptimizedDataService.getBudgets();
      final categories = await OptimizedDataService.getCategories();
      final groups = await OptimizedDataService.getGroups();
      final summary = await OptimizedDataService.getTransactionSummary();

      if (mounted) {
        setState(() {
          _transactionsNotifier.value = transactions;
          _accountsNotifier.value = accounts;
          _budgetsNotifier.value = budgets;
          _categoriesNotifier.value = categories;
          _groupsNotifier.value = groups;
          _summaryNotifier.value = summary;
          _isLoadingNotifier.value = false;
        });
        _filterTransactions();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNotifier.value = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _filterTransactions() {
    List<Transaction> filtered = _transactionsNotifier.value.where((transaction) {
      bool matchesType = (_transactionTypeFilter == TransactionType.all ||
          transaction.type == _transactionTypeFilter.value);
      bool matchesCategory = (_categoryFilter == 'All' ||
          transaction.category == _categoryFilter);
      bool matchesAccount = (_accountFilter == 'All' ||
          transaction.accountId == _accountFilter);
      bool matchesDate = (transaction.date.isAfter(_startDateFilter.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(_endDateFilter.add(const Duration(days: 1))));
      bool matchesSearch = (transaction.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) == true);

      return matchesType && matchesCategory && matchesAccount && matchesDate && matchesSearch;
    }).toList();

    _filteredTransactionsNotifier.value = filtered;
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _transactionTypeFilter = TransactionType.values[_tabController.index];
        _filterTransactions();
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDateFilter, end: _endDateFilter),
    );
    if (picked != null && (picked.start != _startDateFilter || picked.end != _endDateFilter)) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
        _filterTransactions();
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterTransactions();
    });
  }

  void _onCategoryFilterChanged(String? category) {
    setState(() {
      _categoryFilter = category ?? 'All';
      _filterTransactions();
    });
  }

  void _onAccountFilterChanged(String? accountId) {
    setState(() {
      _accountFilter = accountId ?? 'All';
      _filterTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoadingNotifier,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<List<Transaction>>(
            valueListenable: _filteredTransactionsNotifier,
            builder: (context, transactions, child) {
              if (transactions.isEmpty) {
                return EmptyStateWidget(
                  message: 'No transactions found.',
                  title: 'No Transactions',
                  onAction: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Adding a comment to force re-analysis
                        builder: (context) => const CalculatorTransactionScreen(
                          initialType: 'expense',
                        ),
                      ),
                    );
                    if (result != null && result is Transaction) {
                      await OptimizedDataService.addTransaction(result);
                      _loadData();
                    }
                  },
                  actionText: 'Add New Transaction',
                );
              }
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionCard(
                    transaction: transaction,
                    onTap: () {
                      // Handle tap
                    },
                    currencySymbol: currencyProvider.currencySymbol,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalculatorTransactionScreen(
                initialType: 'expense',
              ),
            ),
          );
          if (result != null && result is Transaction) {
            await OptimizedDataService.addTransaction(result);
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterDropdown(
                label: 'Category',
                value: _categoryFilter,
                items: ['All', ..._categoriesNotifier.value.map((c) => c.name)],
                onChanged: _onCategoryFilterChanged,
              ),
              const SizedBox(height: 16),
              FilterDropdown(
                label: 'Account',
                value: _accountFilter,
                items: ['All', ..._accountsNotifier.value.map((a) => a.name)],
                onChanged: _onAccountFilterChanged,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date Range'),
                subtitle: Text(
                  '${DateFormat.yMd().format(_startDateFilter)} - ${DateFormat.yMd().format(_endDateFilter)}',
                ),
                onTap: _selectDateRange,
              ),
              const SizedBox(height: 16),
              common_search_bar.SearchBar(
                onSearchChanged: _onSearchChanged,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
