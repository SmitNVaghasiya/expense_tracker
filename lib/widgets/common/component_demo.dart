import 'package:flutter/material.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';

class ComponentDemoScreen extends StatefulWidget {
  const ComponentDemoScreen({super.key});

  @override
  State<ComponentDemoScreen> createState() => _ComponentDemoScreenState();
}

class _ComponentDemoScreenState extends State<ComponentDemoScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  // Sample data for demonstration
  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
  ];

  final Transaction _sampleTransaction = Transaction(
    id: '1',
    title: 'Grocery Shopping',
    amount: 45.67,
    type: 'expense',
    category: 'Food',
    date: DateTime.now(),
    accountId: 'acc1',
    notes: 'Weekly groceries',
  );

  final Account _sampleAccount = Account(
    id: 'acc1',
    name: 'Main Bank Account',
    type: 'checking',
    balance: 1250.50,
    createdAt: DateTime.now(),
  );

  final Budget _sampleBudget = Budget(
    id: 'budget1',
    name: 'Food Budget',
    limit: 500.0,
    category: 'Food',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable Components Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Section
            _buildSectionTitle('Search & Filter Components'),
            const SizedBox(height: 16),

            common_widgets.SearchBar(
              hintText: 'Search transactions...',
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 16),

            common_widgets.FilterDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'All';
                });
              },
              icon: Icons.category,
            ),

            const SizedBox(height: 16),

            common_widgets.DateRangePicker(
              label: 'Date Range',
              startDate: _startDate,
              endDate: _endDate,
              onStartDateChanged: (date) {
                setState(() {
                  _startDate = date;
                });
              },
              onEndDateChanged: (date) {
                setState(() {
                  _endDate = date;
                });
              },
            ),

            const SizedBox(height: 32),

            // Card Components Section
            _buildSectionTitle('Card Components'),
            const SizedBox(height: 16),

            common_widgets.TransactionCard(
              transaction: _sampleTransaction,
              accountName: _sampleAccount.name,
              onEdit: () => _showSnackBar('Edit transaction'),
              onDelete: () => _showSnackBar('Delete transaction'),
            ),

            const SizedBox(height: 16),

            common_widgets.AccountCard(
              account: _sampleAccount,
              onEdit: () => _showSnackBar('Edit account'),
              onDelete: () => _showSnackBar('Delete account'),
            ),

            const SizedBox(height: 16),

            common_widgets.BudgetCard(
              budget: _sampleBudget,
              spentAmount: 320.50,
              onEdit: () => _showSnackBar('Edit budget'),
              onDelete: () => _showSnackBar('Delete budget'),
            ),

            const SizedBox(height: 32),

            // Loading & Error Components Section
            _buildSectionTitle('Loading & Error Components'),
            const SizedBox(height: 16),

            common_widgets.LoadingIndicator(
              message: 'Loading data...',
              size: 30,
            ),

            const SizedBox(height: 16),

            common_widgets.CustomErrorWidget(
              title: 'Something went wrong',
              message: 'Unable to load data. Please try again.',
              onRetry: () => _showSnackBar('Retrying...'),
            ),

            const SizedBox(height: 16),

            common_widgets.EmptyStateWidget(
              title: 'No transactions found',
              message: 'Start by adding your first transaction to see it here.',
              onAction: () => _showSnackBar('Add transaction'),
              actionText: 'Add Transaction',
            ),

            const SizedBox(height: 32),

            // Action Components Section
            _buildSectionTitle('Action Components'),
            const SizedBox(height: 16),

            common_widgets.LoadingButton(
              text: 'Save Changes',
              onPressed: () => _showSnackBar('Saving...'),
              isLoading: false,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _showActionBottomSheet(),
              child: const Text('Show Action Bottom Sheet'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _showConfirmationBottomSheet(),
              child: const Text('Show Confirmation Bottom Sheet'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => common_widgets.ActionBottomSheet(
        title: 'Transaction Actions',
        actions: [
          common_widgets.ActionItem(
            title: 'Edit Transaction',
            subtitle: 'Modify transaction details',
            icon: Icons.edit,
            onTap: () => _showSnackBar('Edit tapped'),
          ),
          common_widgets.ActionItem(
            title: 'Duplicate Transaction',
            subtitle: 'Create a copy of this transaction',
            icon: Icons.copy,
            onTap: () => _showSnackBar('Duplicate tapped'),
          ),
          common_widgets.ActionItem(
            title: 'Delete Transaction',
            subtitle: 'Remove this transaction permanently',
            icon: Icons.delete,
            iconColor: Colors.red,
            onTap: () => _showSnackBar('Delete tapped'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => common_widgets.ConfirmationBottomSheet(
        title: 'Delete Transaction',
        message:
            'Are you sure you want to delete this transaction? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
        icon: Icons.warning,
        onConfirm: () => _showSnackBar('Transaction deleted'),
      ),
    );
  }
}
