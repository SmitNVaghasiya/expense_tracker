import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CalculatorTransactionScreen extends StatefulWidget {
  final String initialType;
  final DateTime? initialDate;

  const CalculatorTransactionScreen({
    super.key, 
    required this.initialType,
    this.initialDate,
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
  String _selectedCategory = '';
  String? _selectedAccountId;
  String? _selectedToAccountId; // For transfer functionality
  List<Account> _accounts = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Utilities',
    'Travel',
    'Living Expenses',
    'Eating Out',
    'Bus Ticket',
    'Auto riksha',
    'Snacks',
    'Clothes',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other Income',
  ];

  final List<String> _transferCategories = [
    'Transfer',
    'Internal Transfer',
    'Account Transfer',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = _selectedType == 'expense'
        ? _expenseCategories.first
        : _incomeCategories.first;
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadAccounts();
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
      setState(() {
        _accounts = accounts;
        _selectedAccountId = accounts.first.id;
        // For transfer, set the second account if available
        if (accounts.length > 1) {
          _selectedToAccountId = accounts[1].id;
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

  void _onEqualsPressed() {
    try {
      final result = _evaluateExpression(_calculationString);
      setState(() {
        _displayAmount = result.toStringAsFixed(2);
        _calculationString = _displayAmount;
      });
    } catch (e) {
      setState(() {
        _displayAmount = 'Error';
        _calculationString = '';
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
        } else {
          // Update display to show current number being entered
          final parts = _calculationString.split(RegExp(r'[+\-×÷]'));
          _displayAmount = parts.last.isEmpty ? '0' : parts.last;
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

  bool _isOperator(String char) {
    return ['+', '-', '×', '÷'].contains(char);
  }

  double _evaluateExpression(String expression) {
    // Simple calculator evaluation
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    // Basic evaluation (for demo purposes)
    final parts = expression.split(RegExp(r'([+\-*/])'));
    if (parts.length == 1) {
      return double.parse(parts[0]);
    }

    double result = double.parse(parts[0]);
    for (int i = 1; i < parts.length; i += 2) {
      final operator = expression[expression.indexOf(parts[i]) - 1];
      final operand = double.parse(parts[i + 1]);

      switch (operator) {
        case '+':
          result += operand;
          break;
        case '-':
          result -= operand;
          break;
        case '*':
          result *= operand;
          break;
        case '/':
          result /= operand;
          break;
      }
    }

    return result;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (double.tryParse(_displayAmount) == null ||
        double.parse(_displayAmount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    // For transfer, validate that we have two different accounts
    if (_selectedType == 'transfer') {
      if (_selectedToAccountId == null ||
          _selectedToAccountId == _selectedAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select two different accounts for transfer'),
          ),
        );
        return;
      }
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      title: _selectedCategory,
      amount: double.parse(_displayAmount),
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
    );

    await DataService.addTransaction(transaction);

    // Update account balance
    if (_selectedAccountId != null) {
      await DataService.updateAccountBalance(
        _selectedAccountId!,
        double.parse(_displayAmount),
        _selectedType,
      );
    }

    // For transfer, create a second transaction for the destination account
    if (_selectedType == 'transfer' && _selectedToAccountId != null) {
      final transferTransaction = Transaction(
        id: const Uuid().v4(),
        title:
            'Transfer to ${_accounts.firstWhere((a) => a.id == _selectedToAccountId).name}',
        amount: double.parse(_displayAmount),
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        category: 'Transfer',
        type: 'income', // This will add money to the destination account
        accountId: _selectedToAccountId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await DataService.addTransaction(transferTransaction);
      await DataService.updateAccountBalance(
        _selectedToAccountId!,
        double.parse(_displayAmount),
        'income',
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Add Transaction'),
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
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'income';
                        _selectedCategory = _incomeCategories.first;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'income'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'INCOME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'income'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
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
                        _selectedCategory = _expenseCategories.first;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'expense'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'EXPENSE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'expense'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
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
                        _selectedCategory = _transferCategories.first;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'transfer'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TRANSFER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'transfer'
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectionButton(
                    _selectedType == 'transfer' ? 'From Account' : 'Account',
                    _selectedAccountId != null
                        ? _accounts
                              .firstWhere((a) => a.id == _selectedAccountId)
                              .name
                        : 'Select Account',
                    Icons.account_balance_wallet,
                    () => _showAccountSelector(),
                  ),
                ),
                const SizedBox(width: 12),
                if (_selectedType == 'transfer')
                  Expanded(
                    child: _buildSelectionButton(
                      'To Account',
                      _selectedToAccountId != null
                          ? _accounts
                                .firstWhere((a) => a.id == _selectedToAccountId)
                                .name
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
                      Icons.local_offer,
                      () => _showCategorySelector(),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notes field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes',
                border: InputBorder.none,
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),

          const SizedBox(height: 16),

          // Amount display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹$_displayAmount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _onBackspacePressed,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Calculator
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: _buildCalculator(),
            ),
          ),

          // Date and Time
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const Text('|'),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
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
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildCalculatorButton(
          '+',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('+'),
        ),
        _buildCalculatorButton('7', onPressed: () => _onNumberPressed('7')),
        _buildCalculatorButton('8', onPressed: () => _onNumberPressed('8')),
        _buildCalculatorButton('9', onPressed: () => _onNumberPressed('9')),

        _buildCalculatorButton(
          '-',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('-'),
        ),
        _buildCalculatorButton('4', onPressed: () => _onNumberPressed('4')),
        _buildCalculatorButton('5', onPressed: () => _onNumberPressed('5')),
        _buildCalculatorButton('6', onPressed: () => _onNumberPressed('6')),

        _buildCalculatorButton(
          '×',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('×'),
        ),
        _buildCalculatorButton('1', onPressed: () => _onNumberPressed('1')),
        _buildCalculatorButton('2', onPressed: () => _onNumberPressed('2')),
        _buildCalculatorButton('3', onPressed: () => _onNumberPressed('3')),

        _buildCalculatorButton(
          '÷',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _onOperatorPressed('÷'),
        ),
        _buildCalculatorButton('0', onPressed: () => _onNumberPressed('0')),
        _buildCalculatorButton('.', onPressed: _onDecimalPressed),
        _buildCalculatorButton(
          '=',
          color: Theme.of(context).colorScheme.primary,
          onPressed: _onEqualsPressed,
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
        backgroundColor: color ?? Theme.of(context).colorScheme.surface,
        foregroundColor: color != null
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            ..._accounts.map(
              (account) => ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(account.name),
                subtitle: Text(
                  '${account.type} • ₹${NumberFormat.currency(symbol: '').format(account.balance)}',
                ),
                trailing: _selectedAccountId == account.id
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedAccountId = account.id;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToAccountSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select To Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._accounts
                .where((account) => account.id != _selectedAccountId)
                .map(
                  (account) => ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(account.name),
                    subtitle: Text(
                      '${account.type} • ₹${NumberFormat.currency(symbol: '').format(account.balance)}',
                    ),
                    trailing: _selectedToAccountId == account.id
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedToAccountId = account.id;
                      });
                      Navigator.pop(context);
                    },
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
        : _incomeCategories;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categories.map(
              (category) => ListTile(
                leading: Icon(
                  Icons.local_offer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(category),
                trailing: _selectedCategory == category
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
