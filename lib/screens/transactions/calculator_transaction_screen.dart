import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/optimized_app_state.dart';
import 'package:spendwise/services/category_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:math_expressions/math_expressions.dart';

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
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  List<Category> _transferCategories = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategories();
  }

  void _loadCategories() {
    final appState = context.read<OptimizedAppState>();
    setState(() {
      _expenseCategories =
          appState.categories.where((c) => c.type == 'expense').toList();
      _incomeCategories =
          appState.categories.where((c) => c.type == 'income').toList();
      _transferCategories =
          appState.categories.where((c) => c.type == 'transfer').toList();

      if (widget.editingTransaction == null) {
        if (_selectedType == 'expense' && _expenseCategories.isNotEmpty) {
          _selectedCategory = _expenseCategories.first.name;
        } else if (_selectedType == 'income' && _incomeCategories.isNotEmpty) {
          _selectedCategory = _incomeCategories.first.name;
        } else if (_selectedType == 'transfer' &&
            _transferCategories.isNotEmpty) {
          _selectedCategory = _transferCategories.first.name;
        }
      }
    });
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

      // Parse the expression
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(expression);

      // Evaluate the expression
      RealEvaluator evaluator = RealEvaluator();
      num eval = evaluator.evaluate(exp);

      return eval.toDouble();
    } catch (e) {
      return double.tryParse(_displayAmount) ?? 0.0;
    }
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

    // ignore: use_build_context_synchronously
    final appState = Provider.of<OptimizedAppState>(context, listen: false);
    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);

    if (widget.editingTransaction != null) {
      await appState.updateTransactionOptimistically(transaction);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
      }
    } else {
      await appState.addTransactionOptimistically(transaction);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context, true);
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
                        if (_incomeCategories.isNotEmpty) {
                          _selectedCategory = _incomeCategories.first.name;
                        }
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
                        if (_expenseCategories.isNotEmpty) {
                          _selectedCategory = _expenseCategories.first.name;
                        }
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
                        if (_transferCategories.isNotEmpty) {
                          _selectedCategory = _transferCategories.first.name;
                        }
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
    final allCategories = [
      ..._expenseCategories,
      ..._incomeCategories,
      ..._transferCategories,
    ];
    final category = allCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(
        id: '',
        name: '',
        type: '',
        icon: 'category',
        color: '#808080',
        createdAt: DateTime.now(),
      ),
    );
    return CategoryService.getColorFromHex(category.color);
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
                            color: CategoryService.getColorFromHex(category.color)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CategoryService.getIconData(category.icon),
                            color: CategoryService.getColorFromHex(category.color),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: _selectedCategory == category.name
                            ? Icon(Icons.check,
                                color: CategoryService.getColorFromHex(
                                    category.color))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.name;
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
    final allCategories = [
      ..._expenseCategories,
      ..._incomeCategories,
      ..._transferCategories
    ];
    final category = allCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(
          id: '', // Default value
          name: '', // Default value
          type: '', // Default value
          icon: 'category', // Default value
          color: '#808080', // Default value
          createdAt: DateTime.now()),
    );
    return CategoryService.getIconData(category.icon);
  }

  // duplicate removed (defined earlier)
}
