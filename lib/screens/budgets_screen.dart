import 'package:flutter/material.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<Account> _accounts = [];
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  DateTime _selectedMonth = DateTime.now();
  double _totalBalance = 0;
  double _totalBudget = 0;
  double _totalSpent = 0;

  // Predefined categories
  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red[700]!,
    },
    {'name': 'Grants', 'icon': Icons.card_giftcard, 'color': Colors.teal},
    {'name': 'Recovery', 'icon': Icons.refresh, 'color': Colors.green},
    {'name': 'Other', 'icon': Icons.people, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.red},
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.pink},
    {
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': Colors.orange,
    },
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo},
    {'name': 'Utilities', 'icon': Icons.electric_bolt, 'color': Colors.amber},
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.green},
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.teal},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.orange},
    {
      'name': 'Mobile Recharge',
      'icon': Icons.phone_android,
      'color': Colors.green,
    },
    {'name': 'Snacks', 'icon': Icons.local_cafe, 'color': Colors.brown},
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.green},
    {'name': 'Sports', 'icon': Icons.sports_tennis, 'color': Colors.green},
    {
      'name': 'Auto Rickshaw',
      'icon': Icons.directions_bus,
      'color': Colors.blue,
    },
    {'name': 'Bike', 'icon': Icons.motorcycle, 'color': Colors.purple},
    {'name': 'Electricity Bills', 'icon': Icons.receipt, 'color': Colors.black},
    {'name': 'Hair Cut', 'icon': Icons.content_cut, 'color': Colors.pink},
    {'name': 'Other', 'icon': Icons.circle, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final accounts = await DataService.getAccounts();
    final budgets = await DataService.getBudgets();
    final transactions = await DataService.getTransactions();

    setState(() {
      _accounts = accounts;
      _budgets = budgets;
      _transactions = transactions;

      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalBalance = _accounts.fold(0, (sum, account) => sum + account.balance);

    // Calculate budget and spent for selected month
    final monthBudgets = _budgets
        .where(
          (budget) =>
              budget.startDate.year == _selectedMonth.year &&
              budget.startDate.month == _selectedMonth.month,
        )
        .toList();

    _totalBudget = monthBudgets.fold(0, (sum, budget) => sum + budget.limit);

    final monthTransactions = _transactions
        .where(
          (transaction) =>
              transaction.date.year == _selectedMonth.year &&
              transaction.date.month == _selectedMonth.month &&
              transaction.type == 'expense',
        )
        .toList();

    _totalSpent = monthTransactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Balance Section
                _buildAccountBalanceSection(),
                const SizedBox(height: 24),

                // Budget Overview Section
                _buildBudgetOverviewSection(),
                const SizedBox(height: 24),

                // Categories with Budgets Section
                _buildCategoriesWithBudgetsSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Account Balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddAccountDialog(),
              icon: const Icon(Icons.add),
              label: const Text('ADD NEW ACCOUNT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormat.currency(symbol: '₹').format(_totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Individual Account Cards
        if (_accounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'No accounts yet. Add your first account!',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Column(
            children: _accounts
                .map((account) => _buildAccountCard(account))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAccountColor(account.type),
          child: Icon(_getAccountIcon(account.type), color: Colors.white),
        ),
        title: Text(account.name),
        subtitle: Text(account.type.toUpperCase()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(symbol: '₹').format(account.balance),
              style: TextStyle(
                color: account.balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleAccountAction(value, account),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('Add Income'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/income');
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/expenses');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                    _calculateTotals();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MMMM, yyyy').format(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                    _calculateTotals();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildBudgetMetricCard(
                'TOTAL BUDGET',
                _totalBudget,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetMetricCard(
                'TOTAL SPENT',
                _totalSpent,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetMetricCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(symbol: '₹').format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesWithBudgetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories with Budgets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('ADD NEW CATEGORY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Income Categories
        const Text(
          'Income Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        ..._incomeCategories.map(
          (category) => _buildCategoryWithBudgetCard(category, 'income'),
        ),

        const SizedBox(height: 16),

        // Expense Categories
        const Text(
          'Expense Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        ..._expenseCategories.map(
          (category) => _buildCategoryWithBudgetCard(category, 'expense'),
        ),
      ],
    );
  }

  Widget _buildCategoryWithBudgetCard(
    Map<String, dynamic> category,
    String type,
  ) {
    final categoryName = category['name'] as String;
    final icon = category['icon'] as IconData;
    final color = category['color'] as Color;

    // Find budget for this category and month
    final budget = _budgets.firstWhere(
      (b) =>
          b.category == categoryName &&
          b.startDate.year == _selectedMonth.year &&
          b.startDate.month == _selectedMonth.month,
      orElse: () => Budget(
        id: '',
        name: '',
        category: categoryName,
        limit: 0,
        startDate: _selectedMonth,
        endDate: _selectedMonth,
      ),
    );

    // Calculate spent amount for this category
    final spent = _transactions
        .where(
          (t) =>
              t.type == type &&
              t.category == categoryName &&
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);

    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(categoryName),
        subtitle: budget.limit > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${NumberFormat.currency(symbol: '₹').format(spent)} / ${NumberFormat.currency(symbol: '₹').format(budget.limit)}',
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 90 ? Colors.red : color,
                    ),
                  ),
                ],
              )
            : const Text('No budget set'),
        trailing: budget.limit > 0
            ? Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percentage > 90 ? Colors.red : color,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextButton(
                onPressed: () => _showSetBudgetDialog(categoryName),
                child: const Text('SET BUDGET'),
              ),
        onTap: budget.limit > 0 ? () => _showEditBudgetDialog(budget) : null,
      ),
    );
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'cash';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., Cash, HDFC Bank',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Account Type'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                DropdownMenuItem(value: 'credit', child: Text('Credit Card')),
                DropdownMenuItem(value: 'savings', child: Text('Savings')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  balanceController.text.isNotEmpty) {
                final account = Account(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  balance: double.tryParse(balanceController.text) ?? 0,
                  type: selectedType,
                  createdAt: DateTime.now(),
                );
                DataService.addAccount(account);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = 'expense';
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Groceries, Travel',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Category Type'),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
            const SizedBox(height: 16),
            const Text('Select Icon and Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildIconOption(
                  Icons.restaurant,
                  Colors.red,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.directions_car,
                  Colors.blue,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.shopping_bag,
                  Colors.purple,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.movie,
                  Colors.pink,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.medical_services,
                  Colors.orange,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.school,
                  Colors.indigo,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.home,
                  Colors.green,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.devices,
                  Colors.teal,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
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
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newCategory = {
                  'name': nameController.text,
                  'icon': selectedIcon,
                  'color': selectedColor,
                };

                if (selectedType == 'income') {
                  _incomeCategories.add(newCategory);
                } else {
                  _expenseCategories.add(newCategory);
                }

                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOption(
    IconData icon,
    Color color,
    IconData selectedIcon,
    Color selectedColor,
    Function(IconData, Color) onTap,
  ) {
    final isSelected = selectedIcon == icon && selectedColor == color;

    return GestureDetector(
      onTap: () => onTap(icon, color),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _showSetBudgetDialog(String categoryName) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for $categoryName'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final budget = Budget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '$categoryName Budget',
                  category: categoryName,
                  limit: double.tryParse(amountController.text) ?? 0,
                  startDate: DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month,
                    1,
                  ),
                  endDate: DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                    0,
                  ),
                );
                DataService.addBudget(budget);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    final amountController = TextEditingController(
      text: budget.limit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Budget for ${budget.category}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final updatedBudget = budget.copyWith(
                  limit: double.tryParse(amountController.text) ?? 0,
                );
                DataService.updateBudget(updatedBudget);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleAccountAction(String action, Account account) {
    switch (action) {
      case 'edit':
        _showEditAccountDialog(account);
        break;
      case 'delete':
        _showDeleteAccountDialog(account);
        break;
    }
  }

  void _showEditAccountDialog(Account account) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(
      text: account.balance.toString(),
    );
    String selectedType = account.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Balance'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Account Type'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                DropdownMenuItem(value: 'credit', child: Text('Credit Card')),
                DropdownMenuItem(value: 'savings', child: Text('Savings')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  balanceController.text.isNotEmpty) {
                final updatedAccount = account.copyWith(
                  name: nameController.text,
                  balance: double.tryParse(balanceController.text) ?? 0,
                  type: selectedType,
                );
                DataService.updateAccount(updatedAccount);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              DataService.deleteAccount(account.id);
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getAccountColor(String type) {
    switch (type) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'credit':
        return Colors.orange;
      case 'savings':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.account_balance;
    }
  }
}
