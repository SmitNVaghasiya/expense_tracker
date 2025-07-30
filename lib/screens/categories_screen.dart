import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:intl/intl.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Transaction> _transactions = [];
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;

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
    final transactions = await DataService.getTransactions();

    setState(() {
      _transactions = transactions;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);

    _totalExpenses = _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);

    _totalBalance = _totalIncome - _totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Summary Section
                _buildFinancialSummarySection(),
                const SizedBox(height: 24),

                // Income Categories Section
                _buildCategoriesSection(
                  'Income Categories',
                  _incomeCategories,
                  'income',
                ),
                const SizedBox(height: 24),

                // Expense Categories Section
                _buildCategoriesSection(
                  'Expense Categories',
                  _expenseCategories,
                  'expense',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFinancialSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '[ All Accounts ₹${NumberFormat('#,##0.00').format(_totalBalance)} ]',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPENSE SO FAR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(_totalExpenses)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'INCOME SO FAR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(_totalIncome)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    String title,
    List<Map<String, dynamic>> categories,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Column(
          children: categories
              .map((category) => _buildCategoryCard(category, type))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, String type) {
    final categoryName = category['name'] as String;
    final icon = category['icon'] as IconData;
    final color = category['color'] as Color;

    // Calculate total amount for this category
    final totalAmount = _transactions
        .where((t) => t.type == type && t.category == categoryName)
        .fold(0.0, (sum, item) => sum + item.amount);

    // Calculate transaction count
    final transactionCount = _transactions
        .where((t) => t.type == type && t.category == categoryName)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(categoryName),
        subtitle: Text(
          transactionCount > 0
              ? '$transactionCount transaction${transactionCount > 1 ? 's' : ''}'
              : 'No transactions',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${NumberFormat('#,##0.00').format(totalAmount)}',
              style: TextStyle(
                color: type == 'income' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleCategoryAction(value, categoryName),
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
                // Add the new category to the appropriate list
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

  void _handleCategoryAction(String action, String categoryName) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(categoryName);
        break;
      case 'delete':
        _showDeleteCategoryDialog(categoryName);
        break;
    }
  }

  void _showEditCategoryDialog(String categoryName) {
    final nameController = TextEditingController(text: categoryName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Update category name in both lists
                _updateCategoryName(categoryName, nameController.text);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateCategoryName(String oldName, String newName) {
    // Update in income categories
    for (int i = 0; i < _incomeCategories.length; i++) {
      if (_incomeCategories[i]['name'] == oldName) {
        _incomeCategories[i]['name'] = newName;
        break;
      }
    }

    // Update in expense categories
    for (int i = 0; i < _expenseCategories.length; i++) {
      if (_expenseCategories[i]['name'] == oldName) {
        _expenseCategories[i]['name'] = newName;
        break;
      }
    }
  }

  void _showDeleteCategoryDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCategory(categoryName);
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryName) {
    // Remove from income categories
    _incomeCategories.removeWhere(
      (category) => category['name'] == categoryName,
    );

    // Remove from expense categories
    _expenseCategories.removeWhere(
      (category) => category['name'] == categoryName,
    );
  }
}
