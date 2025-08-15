import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CalculatorTransactionScreen extends StatefulWidget {
  final String initialType;
  final DateTime? initialDate;
  final Transaction? editingTransaction;

  const CalculatorTransactionScreen({
    super.key,
    required this.initialType,
    this.initialDate,
    this.editingTransaction,
  });

  @override
  State<CalculatorTransactionScreen> createState() =>
      _CalculatorTransactionScreenState();
}

class _CalculatorTransactionScreenState
    extends State<CalculatorTransactionScreen> {
  String _selectedType = 'expense';
  String _displayAmount = '0';
  String _calculationString = '';
  final List<String> _calculationHistory = [];
  String _runningTotal = '0';
  String _selectedCategory = '';
  String? _selectedAccountId;
  String? _selectedToAccountId; // For transfer functionality
  List<Account> _accounts = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _expenseCategories = [
    // Food & Dining - Multiple icon options
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.red},
    {
      'name': 'Restaurant',
      'icon': Icons.restaurant_menu,
      'color': Colors.red[600]!,
    },
    {'name': 'Fast Food', 'icon': Icons.fastfood, 'color': Colors.red[500]!},
    {'name': 'Coffee', 'icon': Icons.coffee, 'color': Colors.brown[600]!},
    {'name': 'Snacks', 'icon': Icons.local_cafe, 'color': Colors.brown},
    {
      'name': 'Groceries',
      'icon': Icons.shopping_cart,
      'color': Colors.orange[600]!,
    },
    {'name': 'Bakery', 'icon': Icons.cake, 'color': Colors.orange[500]!},
    {'name': 'Eating Out', 'icon': Icons.restaurant, 'color': Colors.red[400]!},

    // Transportation - Multiple icon options
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {'name': 'Car', 'icon': Icons.directions_car, 'color': Colors.blue[600]!},
    {'name': 'Bus', 'icon': Icons.directions_bus, 'color': Colors.blue[500]!},
    {
      'name': 'Bus Ticket',
      'icon': Icons.directions_bus,
      'color': Colors.blue[400]!,
    },
    {'name': 'Train', 'icon': Icons.train, 'color': Colors.blue[700]!},
    {'name': 'Metro', 'icon': Icons.subway, 'color': Colors.blue[800]!},
    {'name': 'Taxi', 'icon': Icons.local_taxi, 'color': Colors.yellow[700]!},
    {'name': 'Auto riksha', 'icon': Icons.directions_bus, 'color': Colors.blue},
    {'name': 'Bike', 'icon': Icons.motorcycle, 'color': Colors.purple},
    {'name': 'Bicycle', 'icon': Icons.pedal_bike, 'color': Colors.green[600]!},
    {
      'name': 'Walking',
      'icon': Icons.directions_walk,
      'color': Colors.green[500]!,
    },

    // Shopping & Retail - Multiple icon options
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': 'Clothes', 'icon': Icons.checkroom, 'color': Colors.orange},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.orange[600]!},
    {
      'name': 'Shoes',
      'icon': Icons.sports_soccer,
      'color': Colors.orange[500]!,
    },
    {'name': 'Accessories', 'icon': Icons.watch, 'color': Colors.orange[400]!},
    {'name': 'Jewelry', 'icon': Icons.diamond, 'color': Colors.amber[600]!},
    {'name': 'Cosmetics', 'icon': Icons.face, 'color': Colors.pink[400]!},
    {'name': 'Books', 'icon': Icons.book, 'color': Colors.indigo[600]!},
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.teal},
    {'name': 'Gadgets', 'icon': Icons.phone_iphone, 'color': Colors.teal[600]!},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.purple[600]!},

    // Entertainment & Leisure - Multiple icon options
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.pink},
    {'name': 'Movies', 'icon': Icons.movie, 'color': Colors.pink[500]!},
    {
      'name': 'Theater',
      'icon': Icons.theater_comedy,
      'color': Colors.pink[600]!,
    },
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.purple[400]!},
    {
      'name': 'Concerts',
      'icon': Icons.music_note,
      'color': Colors.purple[500]!,
    },
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
    {'name': 'Gym', 'icon': Icons.fitness_center, 'color': Colors.green[600]!},
    {'name': 'Swimming', 'icon': Icons.pool, 'color': Colors.blue[400]!},
    {'name': 'Hiking', 'icon': Icons.terrain, 'color': Colors.green[700]!},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.blue[600]!},
    {
      'name': 'Vacation',
      'icon': Icons.beach_access,
      'color': Colors.blue[500]!,
    },

    // Health & Wellness - Multiple icon options
    {
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': Colors.orange,
    },
    {
      'name': 'Medicine',
      'icon': Icons.medication,
      'color': Colors.orange[600]!,
    },
    {
      'name': 'Dental',
      'icon': Icons.medical_services,
      'color': Colors.orange[500]!,
    },
    {'name': 'Vision', 'icon': Icons.visibility, 'color': Colors.orange[400]!},
    {
      'name': 'Mental Health',
      'icon': Icons.psychology,
      'color': Colors.orange[700]!,
    },
    {
      'name': 'Fitness',
      'icon': Icons.fitness_center,
      'color': Colors.green[600]!,
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': Colors.green[500]!,
    },
    {'name': 'Spa', 'icon': Icons.spa, 'color': Colors.pink[300]!},

    // Education & Learning - Multiple icon options
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo},
    {
      'name': 'University',
      'icon': Icons.account_balance,
      'color': Colors.indigo[600]!,
    },
    {
      'name': 'Online Courses',
      'icon': Icons.computer,
      'color': Colors.indigo[500]!,
    },
    {'name': 'Workshops', 'icon': Icons.work, 'color': Colors.indigo[400]!},
    {
      'name': 'Certifications',
      'icon': Icons.verified,
      'color': Colors.indigo[700]!,
    },
    {'name': 'Tutoring', 'icon': Icons.person, 'color': Colors.indigo[800]!},

    // Home & Utilities - Multiple icon options
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.green},
    {'name': 'Rent', 'icon': Icons.home_work, 'color': Colors.green[600]!},
    {
      'name': 'Mortgage',
      'icon': Icons.account_balance,
      'color': Colors.green[700]!,
    },
    {'name': 'Utilities', 'icon': Icons.electric_bolt, 'color': Colors.amber},
    {
      'name': 'Electricity',
      'icon': Icons.electric_bolt,
      'color': Colors.amber[600]!,
    },
    {'name': 'Water', 'icon': Icons.water_drop, 'color': Colors.blue[400]!},
    {
      'name': 'Gas',
      'icon': Icons.local_fire_department,
      'color': Colors.orange[400]!,
    },
    {'name': 'Internet', 'icon': Icons.wifi, 'color': Colors.blue[500]!},
    {'name': 'Phone Bill', 'icon': Icons.phone, 'color': Colors.blue[600]!},
    {'name': 'Maintenance', 'icon': Icons.build, 'color': Colors.grey[600]!},
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.grey[500]!,
    },
    {'name': 'Furniture', 'icon': Icons.chair, 'color': Colors.brown[600]!},
    {'name': 'Decor', 'icon': Icons.image, 'color': Colors.brown[500]!},
    {
      'name': 'Living Expenses',
      'icon': Icons.home,
      'color': Colors.green[500]!,
    },

    // Personal Care - Multiple icon options
    {'name': 'Hair Cut', 'icon': Icons.content_cut, 'color': Colors.pink},
    {'name': 'Salon', 'icon': Icons.face, 'color': Colors.pink[400]!},
    {'name': 'Barber', 'icon': Icons.content_cut, 'color': Colors.pink[500]!},
    {'name': 'Nail Care', 'icon': Icons.brush, 'color': Colors.pink[300]!},
    {'name': 'Skincare', 'icon': Icons.face, 'color': Colors.pink[400]!},

    // Business & Professional - Multiple icon options
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.grey[700]!},
    {'name': 'Office Supplies', 'icon': Icons.work, 'color': Colors.grey[600]!},
    {
      'name': 'Professional Development',
      'icon': Icons.trending_up,
      'color': Colors.grey[800]!,
    },
    {'name': 'Networking', 'icon': Icons.people, 'color': Colors.grey[500]!},
    {'name': 'Conferences', 'icon': Icons.event, 'color': Colors.grey[600]!},

    // Financial Services - Multiple icon options
    {
      'name': 'Banking',
      'icon': Icons.account_balance,
      'color': Colors.green[700]!,
    },
    {'name': 'Insurance', 'icon': Icons.security, 'color': Colors.green[600]!},
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Colors.green[500]!,
    },
    {'name': 'Taxes', 'icon': Icons.receipt_long, 'color': Colors.red[600]!},
    {'name': 'Fees', 'icon': Icons.payment, 'color': Colors.red[500]!},

    // Social & Relationships - Multiple icon options
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.green},
    {'name': 'Dating', 'icon': Icons.favorite, 'color': Colors.red[400]!},
    {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Colors.pink[400]!},
    {
      'name': 'Charity',
      'icon': Icons.volunteer_activism,
      'color': Colors.green[500]!,
    },
    {
      'name': 'Donations',
      'icon': Icons.favorite_border,
      'color': Colors.green[400]!,
    },

    // Technology & Digital - Multiple icon options
    {'name': 'Software', 'icon': Icons.computer, 'color': Colors.blue[600]!},
    {'name': 'Apps', 'icon': Icons.phone_android, 'color': Colors.blue[500]!},
    {'name': 'Streaming', 'icon': Icons.play_circle, 'color': Colors.red[500]!},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.purple[600]!},
    {
      'name': 'Digital Services',
      'icon': Icons.cloud,
      'color': Colors.blue[400]!,
    },

    // Pet Care - Multiple icon options
    {'name': 'Pet Food', 'icon': Icons.pets, 'color': Colors.brown[500]!},
    {
      'name': 'Veterinary',
      'icon': Icons.medical_services,
      'color': Colors.orange[600]!,
    },
    {'name': 'Pet Supplies', 'icon': Icons.pets, 'color': Colors.brown[600]!},
    {
      'name': 'Pet Grooming',
      'icon': Icons.content_cut,
      'color': Colors.brown[400]!,
    },

    // Miscellaneous
    {'name': 'Other', 'icon': Icons.circle, 'color': Colors.blue},
    {'name': 'Emergency', 'icon': Icons.emergency, 'color': Colors.red[800]!},
    {'name': 'Legal', 'icon': Icons.gavel, 'color': Colors.grey[800]!},
    {'name': 'Repairs', 'icon': Icons.handyman, 'color': Colors.grey[600]!},
    {'name': 'Storage', 'icon': Icons.inventory, 'color': Colors.grey[500]!},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red[700]!,
    },
    {'name': 'Freelance', 'icon': Icons.work, 'color': Colors.blue[600]!},
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Colors.green[500]!,
    },
    {'name': 'Gift', 'icon': Icons.card_giftcard, 'color': Colors.pink[400]!},
    {
      'name': 'Other Income',
      'icon': Icons.attach_money,
      'color': Colors.green[600]!,
    },
  ];

  final List<Map<String, dynamic>> _transferCategories = [
    {'name': 'Transfer', 'icon': Icons.swap_horiz, 'color': Colors.blue},
    {
      'name': 'Internal Transfer',
      'icon': Icons.swap_horiz,
      'color': Colors.blue[600]!,
    },
    {
      'name': 'Account Transfer',
      'icon': Icons.swap_horiz,
      'color': Colors.blue[500]!,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = _selectedType == 'expense'
        ? _expenseCategories.first['name']!
        : _incomeCategories.first['name']!;
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadAccounts();

    // If editing a transaction, populate the fields
    if (widget.editingTransaction != null) {
      final transaction = widget.editingTransaction!;
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _displayAmount = transaction.amount.toString();
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
      _selectedAccountId = transaction.accountId;
      _selectedToAccountId = transaction.toAccountId;
      _notesController.text = transaction.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accounts = await DataService.getAccounts();

    // Create default account if none exist
    if (accounts.isEmpty) {
      final defaultAccount = Account(
        id: const Uuid().v4(),
        name: 'Cash',
        balance: 0.0,
        type: 'cash',
        icon: 'wallet',
        createdAt: DateTime.now(),
      );
      await DataService.addAccount(defaultAccount);

      setState(() {
        _accounts = [defaultAccount];
        _selectedAccountId = defaultAccount.id;
      });
    } else {
      // Sort accounts by priority and balance for smart default selection
      final sortedAccounts = List<Account>.from(accounts);
      sortedAccounts.sort((a, b) {
        // First priority: positive balance over negative
        if (a.balance >= 0 && b.balance < 0) return -1;
        if (a.balance < 0 && b.balance >= 0) return 1;

        // Second priority: account type priority
        final aPriority = _getAccountPriority(a.type);
        final bPriority = _getAccountPriority(b.type);
        if (aPriority != bPriority) return bPriority.compareTo(aPriority);

        // Third priority: higher balance first
        return b.balance.compareTo(a.balance);
      });

      setState(() {
        _accounts = sortedAccounts;
        // Select the best default account (first in sorted list)
        _selectedAccountId = sortedAccounts.first.id;

        // For transfer, set the second account if available
        if (_selectedType == 'transfer' && sortedAccounts.length > 1) {
          _selectedToAccountId = sortedAccounts[1].id;
        }
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_displayAmount == '0') {
        _displayAmount = number;
      } else {
        _displayAmount += number;
      }
      _calculationString += number;

      // Update running total if we have a complete expression
      if (_calculationString.isNotEmpty &&
          !_isOperator(_calculationString[_calculationString.length - 1])) {
        _updateRunningTotal();
      }
    });
  }

  void _onOperatorPressed(String operator) {
    if (_calculationString.isNotEmpty &&
        !_isOperator(_calculationString[_calculationString.length - 1])) {
      setState(() {
        _calculationString += operator;
        _displayAmount = '0';
      });
    }
  }

  void _updateRunningTotal() {
    try {
      if (_calculationString.isNotEmpty) {
        final result = _evaluateExpression(_calculationString);
        _runningTotal = result.toStringAsFixed(2);
      }
    } catch (e) {
      _runningTotal = 'Error';
    }
  }

  void _onEqualsPressed() {
    try {
      final result = _evaluateExpression(_calculationString);
      setState(() {
        _displayAmount = result.toStringAsFixed(2);
        _calculationString = _displayAmount;
        _runningTotal = _displayAmount;

        // Add to calculation history
        if (_calculationString.isNotEmpty) {
          _calculationHistory.add(_calculationString);
          if (_calculationHistory.length > 10) {
            _calculationHistory.removeAt(0);
          }
        }
      });
    } catch (e) {
      setState(() {
        _displayAmount = 'Error';
        _calculationString = '';
        _runningTotal = 'Error';
      });
    }
  }

  void _onBackspacePressed() {
    setState(() {
      if (_calculationString.isNotEmpty) {
        _calculationString = _calculationString.substring(
          0,
          _calculationString.length - 1,
        );
        if (_calculationString.isEmpty) {
          _displayAmount = '0';
          _runningTotal = '0';
        } else {
          // Update display to show current number being entered
          final parts = _calculationString.split(RegExp(r'[+\-×÷]'));
          _displayAmount = parts.last.isEmpty ? '0' : parts.last;
          _updateRunningTotal();
        }
      }
    });
  }

  void _onDecimalPressed() {
    if (!_displayAmount.contains('.')) {
      setState(() {
        _displayAmount += '.';
        _calculationString += '.';
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _displayAmount = '0';
      _calculationString = '';
      _runningTotal = '0';
      _calculationHistory.clear();
    });
  }

  bool _isOperator(String char) {
    return ['+', '-', '×', '÷'].contains(char);
  }

  double _evaluateExpression(String expression) {
    try {
      // Replace display operators with standard operators
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

      // Simple expression evaluator using a stack-based approach
      return _evaluateSimpleExpression(expression);
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  double _evaluateSimpleExpression(String expression) {
    // Remove all spaces
    expression = expression.replaceAll(' ', '');

    // Handle negative numbers at the beginning
    if (expression.startsWith('-')) {
      expression = '0$expression';
    }

    // Split by operators while preserving them
    final List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      if (char == '+' || char == '-' || char == '*' || char == '/') {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      } else {
        currentNumber += char;
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    // Handle negative numbers after operators
    for (int i = 0; i < tokens.length - 1; i++) {
      if (tokens[i] == '-' &&
          (i == 0 ||
              tokens[i - 1] == '+' ||
              tokens[i - 1] == '-' ||
              tokens[i - 1] == '*' ||
              tokens[i - 1] == '/')) {
        if (i + 1 < tokens.length) {
          tokens[i + 1] = '-${tokens[i + 1]}';
          tokens.removeAt(i);
        }
      }
    }

    // First pass: handle multiplication and division
    for (int i = 1; i < tokens.length - 1; i += 2) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(tokens[i - 1]);
        final right = double.parse(tokens[i + 1]);
        double result;

        if (tokens[i] == '*') {
          result = left * right;
        } else {
          if (right == 0) throw Exception('Division by zero');
          result = left / right;
        }

        tokens[i - 1] = result.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i -= 2;
      }
    }

    // Second pass: handle addition and subtraction
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      if (i + 1 < tokens.length) {
        final right = double.parse(tokens[i + 1]);
        if (tokens[i] == '+') {
          result += right;
        } else if (tokens[i] == '-') {
          result -= right;
        }
      }
    }

    return result;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1800),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final amount = double.tryParse(_displayAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Check if this transaction will result in negative balance
    if (_selectedType == 'expense' && _selectedAccountId != null) {
      final selectedAccount = _accounts.firstWhere(
        (account) => account.id == _selectedAccountId,
      );

      if (selectedAccount.balance < amount) {
        final shouldProceed = await _showNegativeBalanceWarning(
          selectedAccount.name,
          selectedAccount.balance,
          amount,
        );

        if (!shouldProceed) {
          return; // User cancelled
        }
      }
    }

    final transaction = Transaction(
      id: widget.editingTransaction?.id ?? const Uuid().v4(),
      title: _selectedCategory,
      amount: amount,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      category: _selectedCategory,
      type: _selectedType,
      accountId: _selectedAccountId,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      transferId: _selectedType == 'transfer' ? const Uuid().v4() : null,
      toAccountId: _selectedType == 'transfer' ? _selectedToAccountId : null,
    );

    try {
      if (widget.editingTransaction != null) {
        await DataService.updateTransaction(transaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction updated successfully')),
          );
        }
      } else {
        await DataService.addTransaction(transaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    }
  }

  Future<bool> _showNegativeBalanceWarning(
    String accountName,
    double currentBalance,
    double expenseAmount,
  ) async {
    final newBalance = currentBalance - expenseAmount;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Text('Low Balance Warning'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This transaction will result in a negative balance for "$accountName".',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Current Balance: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '₹${NumberFormat.currency(symbol: '').format(currentBalance)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: currentBalance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Expense Amount: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '₹${NumberFormat.currency(symbol: '').format(expenseAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'New Balance: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '₹${NumberFormat.currency(symbol: '').format(newBalance)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Do you want to proceed with this transaction?',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          widget.editingTransaction != null
              ? 'Edit Transaction'
              : 'Add Transaction',
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Transaction type selector
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'income';
                        _selectedCategory = _incomeCategories.first['name']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedType == 'income'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'INCOME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'income'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'expense';
                        _selectedCategory = _expenseCategories.first['name']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedType == 'expense'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'EXPENSE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'expense'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'transfer';
                        _selectedCategory = _transferCategories.first['name']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedType == 'transfer'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TRANSFER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'transfer'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Account and Category selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectionButton(
                    _selectedType == 'transfer' ? 'From Account' : 'Account',
                    _selectedAccountId != null
                        ? _accounts
                                  .where((a) => a.id == _selectedAccountId)
                                  .firstOrNull
                                  ?.name ??
                              'Select Account'
                        : 'Select Account',
                    Icons.account_balance_wallet,
                    () => _showAccountSelector(),
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedType == 'transfer')
                  Expanded(
                    child: _buildSelectionButton(
                      'To Account',
                      _selectedToAccountId != null
                          ? _accounts
                                    .where((a) => a.id == _selectedToAccountId)
                                    .firstOrNull
                                    ?.name ??
                                'Select Account'
                          : 'Select Account',
                      Icons.account_balance_wallet,
                      () => _showToAccountSelector(),
                    ),
                  )
                else
                  Expanded(
                    child: _buildSelectionButton(
                      'Category',
                      _selectedCategory,
                      _getCategoryIcon(_selectedCategory),
                      () => _showCategorySelector(),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notes field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
              minLines: 1,
            ),
          ),

          const SizedBox(height: 8),

          // Calculator Display with History
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calculation History
                if (_calculationHistory.isNotEmpty) ...[
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _calculationHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem =
                            _calculationHistory[_calculationHistory.length -
                                1 -
                                index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            historyItem,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Current Expression and Result
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_calculationString.isNotEmpty) ...[
                            Text(
                              _calculationString,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '₹$_displayAmount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: _onClearPressed,
                          icon: const Icon(Icons.clear),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          tooltip: 'Clear',
                        ),
                        IconButton(
                          onPressed: _onBackspacePressed,
                          icon: const Icon(Icons.backspace_outlined),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          tooltip: 'Backspace',
                        ),
                      ],
                    ),
                  ],
                ),

                // Running Total
                if (_calculationString.isNotEmpty &&
                    _runningTotal != '0' &&
                    _runningTotal != 'Error') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '= ₹$_runningTotal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Calculator
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              child: _buildCalculator(),
            ),
          ),

          // Date and Time
          Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('|', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: common_widgets.SimpleTimeInput(
                    initialTime: _selectedTime,
                    onTimeChanged: (time) {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    label: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    final categoryColor = _getCategoryColor(value);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: label == 'Category'
                ? categoryColor.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: label == 'Category'
                  ? categoryColor.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: label == 'Category'
                        ? categoryColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: label == 'Category'
                            ? categoryColor
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (value != 'Select Account' && value != 'Select Category')
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    for (var category in _expenseCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as Color;
      }
    }
    for (var category in _incomeCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as Color;
      }
    }
    for (var category in _transferCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as Color;
      }
    }
    return Colors.grey; // Fallback color
  }

  Widget _buildCalculator() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
        _buildCalculatorButton(
          'C',
          color: Colors.orange,
          onPressed: _onClearPressed,
        ),
        _buildCalculatorButton('7', onPressed: () => _onNumberPressed('7')),
        _buildCalculatorButton('8', onPressed: () => _onNumberPressed('8')),
        _buildCalculatorButton('9', onPressed: () => _onNumberPressed('9')),

        _buildCalculatorButton(
          '+',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('+'),
        ),
        _buildCalculatorButton('4', onPressed: () => _onNumberPressed('4')),
        _buildCalculatorButton('5', onPressed: () => _onNumberPressed('5')),
        _buildCalculatorButton('6', onPressed: () => _onNumberPressed('6')),

        _buildCalculatorButton(
          '-',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('-'),
        ),
        _buildCalculatorButton('1', onPressed: () => _onNumberPressed('1')),
        _buildCalculatorButton('2', onPressed: () => _onNumberPressed('2')),
        _buildCalculatorButton('3', onPressed: () => _onNumberPressed('3')),

        _buildCalculatorButton(
          '×',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('×'),
        ),

        _buildCalculatorButton(
          '=',
          color: Theme.of(context).colorScheme.primary,
          onPressed: _onEqualsPressed,
        ),
        _buildCalculatorButton('0', onPressed: () => _onNumberPressed('0')),
        _buildCalculatorButton('.', onPressed: _onDecimalPressed),
        _buildCalculatorButton(
          '÷',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('÷'),
        ),
      ],
    );
  }

  Widget _buildCalculatorButton(
    String text, {
    Color? color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).cardColor,
        foregroundColor: color != null
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.all(5),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAccountSelector() {
    // Sort accounts: positive balance first, then by most used
    final sortedAccounts = List<Account>.from(_accounts);
    sortedAccounts.sort((a, b) {
      // First priority: positive balance over negative
      if (a.balance >= 0 && b.balance < 0) return -1;
      if (a.balance < 0 && b.balance >= 0) return 1;

      // Second priority: most used accounts (you can implement usage tracking later)
      // For now, prioritize cash and bank accounts
      final aPriority = _getAccountPriority(a.type);
      final bPriority = _getAccountPriority(b.type);
      if (aPriority != bPriority) return bPriority.compareTo(aPriority);

      // Third priority: balance amount (higher positive first)
      return b.balance.compareTo(a.balance);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedType == 'transfer'
                  ? 'Select From Account'
                  : 'Select Account',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: sortedAccounts
                    .map((account) => _buildAccountSelectionTile(account))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelectionTile(
    Account account, {
    bool isToAccount = false,
  }) {
    final isNegativeBalance = account.balance < 0;
    final isSelected = isToAccount
        ? _selectedToAccountId == account.id
        : _selectedAccountId == account.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isNegativeBalance
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : (isNegativeBalance ? Colors.red.withValues(alpha: 0.05) : null),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isNegativeBalance
                ? Colors.red.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getAccountIcon(account.type),
            color: isNegativeBalance
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                account.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isNegativeBalance ? Colors.red[700] : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isNegativeBalance
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    account.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isNegativeBalance ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isNegativeBalance)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'Low Balance',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Balance: ₹${NumberFormat.currency(symbol: '').format(account.balance)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isNegativeBalance ? Colors.red : Colors.grey[600],
              ),
            ),
            if (isNegativeBalance &&
                _selectedType == 'expense' &&
                !isToAccount) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adding expense will increase negative balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isToAccount && _selectedType == 'transfer') ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Money will be transferred to this account',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
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
        onTap: () {
          setState(() {
            if (isToAccount) {
              _selectedToAccountId = account.id;
            } else {
              _selectedAccountId = account.id;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank':
      case 'savings':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  int _getAccountPriority(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return 5; // Highest priority
      case 'bank':
        return 4;
      case 'savings':
        return 3;
      case 'credit':
        return 2;
      case 'investment':
        return 1;
      default:
        return 0;
    }
  }

  void _showToAccountSelector() {
    // Filter out the currently selected "from" account and sort remaining accounts
    final availableAccounts = _accounts
        .where((account) => account.id != _selectedAccountId)
        .toList();

    // Sort accounts: positive balance first, then by priority
    availableAccounts.sort((a, b) {
      if (a.balance >= 0 && b.balance < 0) return -1;
      if (a.balance < 0 && b.balance >= 0) return 1;

      final aPriority = _getAccountPriority(a.type);
      final bPriority = _getAccountPriority(b.type);
      if (aPriority != bPriority) return bPriority.compareTo(aPriority);

      return b.balance.compareTo(a.balance);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select To Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: availableAccounts
                    .map(
                      (account) => _buildAccountSelectionTile(
                        account,
                        isToAccount: true,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector() {
    final categories = _selectedType == 'expense'
        ? _expenseCategories
        : _selectedType == 'income'
        ? _incomeCategories
        : _transferCategories;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: categories
                    .map(
                      (category) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category['icon'],
                            color: category['color'],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          category['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: _selectedCategory == category['name']
                            ? Icon(Icons.check, color: category['color'])
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['name']!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    for (var category in _expenseCategories) {
      if (category['name'] == categoryName) {
        return category['icon'] as IconData;
      }
    }
    for (var category in _incomeCategories) {
      if (category['name'] == categoryName) {
        return category['icon'] as IconData;
      }
    }
    for (var category in _transferCategories) {
      if (category['name'] == categoryName) {
        return category['icon'] as IconData;
      }
    }
    return Icons.category; // Fallback icon
  }
}
