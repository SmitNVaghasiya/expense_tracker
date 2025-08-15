import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';

import 'package:spendwise/services/app_state.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/core/performance_mixins.dart';

import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:spendwise/widgets/common/display_options_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

abstract class BaseTransactionScreen extends StatefulWidget {
  final String transactionType; // 'expense' or 'income'

  const BaseTransactionScreen({super.key, required this.transactionType});

  @override
  State<BaseTransactionScreen> createState() => _BaseTransactionScreenState();
}

class _BaseTransactionScreenState extends State<BaseTransactionScreen>
    with
        ValueNotifierMixin,
        DebouncedSearchMixin,
        EfficientListMixin,
        ScrollPerformanceMixin {
  // ValueNotifiers for efficient state management
  late final ValueNotifier<List<Transaction>> _transactionsNotifier;
  late final ValueNotifier<List<Transaction>> _filteredTransactionsNotifier;
  late final ValueNotifier<String> _searchQueryNotifier;
  late final ValueNotifier<String> _selectedCategoryNotifier;
  late final ValueNotifier<DateTime?> _startDateNotifier;
  late final ValueNotifier<DateTime?> _endDateNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
  }

  void _initializeNotifiers() {
    _transactionsNotifier = getNotifier('transactions', []);
    _filteredTransactionsNotifier = getNotifier('filteredTransactions', []);
    _searchQueryNotifier = getNotifier('searchQuery', '');
    _selectedCategoryNotifier = getNotifier('selectedCategory', 'All');
    _startDateNotifier = getNotifier('startDate', null);
    _endDateNotifier = getNotifier('endDate', null);
    _isLoadingNotifier = getNotifier('isLoading', false);
  }

  Future<void> _loadData() async {
    _isLoadingNotifier.value = true;

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // Load data from AppState if available, otherwise load from DataService
      List<Transaction> transactions;
      List<Account> accounts;

      if (appState.transactions.isNotEmpty) {
        transactions = appState.transactions;
        accounts = appState.accounts;
      } else {
        await appState.loadAllData();
        transactions = appState.transactions;
        accounts = appState.accounts;
      }

      if (mounted) {
        setState(() {
          _transactionsNotifier.value = transactions
              .where((t) => t.type == widget.transactionType)
              .toList();

          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint('Error loading ${widget.transactionType}s: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ${widget.transactionType}s: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _applyFilters() {
    var filtered = _transactionsNotifier.value;

    // Category filter
    if (_selectedCategoryNotifier.value != 'All') {
      filtered = filtered
          .where((t) => t.category == _selectedCategoryNotifier.value)
          .toList();
    }

    // Date range filter
    if (_startDateNotifier.value != null) {
      filtered = filtered
          .where((t) => t.date.isAfter(_startDateNotifier.value!))
          .toList();
    }
    if (_endDateNotifier.value != null) {
      filtered = filtered
          .where((t) => t.date.isBefore(_endDateNotifier.value!))
          .toList();
    }

    // Search filter
    if (_searchQueryNotifier.value.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(
                  _searchQueryNotifier.value.toLowerCase(),
                ) ||
                t.category.toLowerCase().contains(
                  _searchQueryNotifier.value.toLowerCase(),
                ),
          )
          .toList();
    }

    _filteredTransactionsNotifier.value = filtered;
  }

  void _onSearchChanged(String query) {
    _searchQueryNotifier.value = query;
    _applyFilters();
  }

  void _onCategoryChanged(String category) {
    _selectedCategoryNotifier.value = category;
    _applyFilters();
  }

  void _clearFilters() {
    _searchQueryNotifier.value = '';
    _selectedCategoryNotifier.value = 'All';
    _startDateNotifier.value = null;
    _endDateNotifier.value = null;
    _applyFilters();
  }

  List<String> get _categories {
    final categories = _transactionsNotifier.value
        .map((t) => t.category)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  double get _totalAmount {
    return _filteredTransactionsNotifier.value.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.transactionType.capitalize()}s'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDisplayOptions,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder<List<Transaction>>(
              valueListenable: _filteredTransactionsNotifier,
              builder: (context, filteredTransactions, child) {
                if (filteredTransactions.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    // Summary Card
                    _buildSummaryCard(),

                    // Transaction List
                    Expanded(
                      child: _buildTransactionList(filteredTransactions),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(),
        backgroundColor: widget.transactionType == 'expense'
            ? Colors.red
            : Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.transactionType == 'expense'
              ? [Colors.red[400]!, Colors.red[600]!]
              : [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (widget.transactionType == 'expense'
                        ? Colors.red
                        : Colors.green)
                    .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total ${widget.transactionType.capitalize()}s',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '₹').format(_totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredTransactionsNotifier.value.length} transaction${_filteredTransactionsNotifier.value.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return common_widgets.TransactionCard(
          transaction: transaction,
          onTap: () => _showTransactionDetails(transaction),
          onEdit: () => _editTransaction(transaction),
          onDelete: () => _deleteTransaction(transaction),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return common_widgets.EmptyStateWidget(
      icon: widget.transactionType == 'expense' ? Icons.money_off : Icons.money,
      title: 'No ${widget.transactionType}s yet',
      message: 'Add your first ${widget.transactionType} to start tracking',
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search ${widget.transactionType.capitalize()}s'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            common_widgets.SearchBar(
              hintText: 'Search by description or category',
              initialQuery: _searchQueryNotifier.value,
              onSearchChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: common_widgets.FilterDropdown(
                    label: 'Category',
                    value: _selectedCategoryNotifier.value,
                    items: _categories,
                    onChanged: (value) => _onCategoryChanged(value ?? 'All'),
                    showLabel: false,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDisplayOptions() async {
    await showDisplayOptionsDialog(
      context,
      selectedViewMode: 'DAILY', // Default for transaction screens
      showTotal: true, // Default for transaction screens
      carryOver: false, // Not applicable for transaction screens
      onViewModeChanged: (mode) {
        // Handle view mode changes if needed
        // For now, we'll just show a snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('View mode changed to: $mode')));
      },
      onShowTotalChanged: (value) {
        // Handle show total changes if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Show total: ${value ? 'YES' : 'NO'}')),
        );
      },
      onCarryOverChanged: (value) {
        // Handle carry over changes if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Carry over: ${value ? 'ON' : 'OFF'}')),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter ${widget.transactionType.capitalize()}s'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Filter
            DropdownButtonFormField<String>(
              value: _selectedCategoryNotifier.value,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _onCategoryChanged(value ?? 'All'),
            ),
            const SizedBox(height: 16),

            // Date Range Filter
            common_widgets.DateRangePicker(
              label: 'Date Range',
              startDate: _startDateNotifier.value,
              endDate: _endDateNotifier.value,
              onStartDateChanged: (date) {
                _startDateNotifier.value = date;
                _applyFilters();
              },
              onEndDateChanged: (date) {
                _endDateNotifier.value = date;
                _applyFilters();
              },
              firstDate: DateTime(1800),
              lastDate: DateTime.now().add(const Duration(days: 36500)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CalculatorTransactionScreen(initialType: widget.transactionType),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    // Implementation for showing transaction details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${NumberFormat.currency(symbol: '₹').format(transaction.amount)}',
            ),
            Text('Category: ${transaction.category}'),
            Text('Title: ${transaction.title}'),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text('Notes: ${transaction.notes}'),
            if (transaction.accountId != null)
              Text('Account ID: ${transaction.accountId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    // Implementation for editing transaction
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorTransactionScreen(
          initialType: widget.transactionType,
          editingTransaction: transaction,
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    // Show confirmation dialog
    bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return common_widgets.ConfirmationBottomSheet(
          title: 'Confirm Delete',
          message:
              'Are you sure you want to delete this ${widget.transactionType}? This action cannot be undone.',
          confirmText: 'Delete',
          cancelText: 'Cancel',
          confirmColor: Colors.red,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
          icon: Icons.delete_forever,
        );
      },
    );

    if (confirm == true) {
      try {
        final appState = Provider.of<AppState>(context, listen: false);
        final success = await appState.deleteTransaction(transaction.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.transactionType.capitalize()} deleted successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Update local state to reflect the deletion
          final updatedTransactions = _transactionsNotifier.value
              .where((t) => t.id != transaction.id)
              .toList();
          _transactionsNotifier.value = updatedTransactions;
          _applyFilters();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${widget.transactionType}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting ${widget.transactionType}: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
