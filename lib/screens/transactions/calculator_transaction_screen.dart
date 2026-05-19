import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/optimized_data_service.dart';
import 'package:spendwise/services/optimized_app_state.dart';
import 'package:spendwise/services/category_service.dart';
import 'package:spendwise/services/currency_provider.dart';
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
  String _runningTotal = '0';
  String _selectedCategory = '';
  String? _selectedAccountId;
  String? _selectedToAccountId;
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

    if (widget.editingTransaction != null) {
      final t = widget.editingTransaction!;
      _selectedType     = t.type;
      _selectedCategory = t.category;
      _displayAmount    = t.amount.toStringAsFixed(0);
      _calculationString = _displayAmount;
      _selectedDate     = t.date;
      _selectedTime     = TimeOfDay.fromDateTime(t.date);
      _selectedAccountId   = t.accountId;
      _selectedToAccountId = t.toAccountId;
      _notesController.text = t.notes ?? '';
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
      _expenseCategories  = appState.categories.where((c) => c.type == 'expense').toList();
      _incomeCategories   = appState.categories.where((c) => c.type == 'income').toList();
      _transferCategories = appState.categories.where((c) => c.type == 'transfer').toList();

      if (widget.editingTransaction == null) {
        if (_selectedType == 'expense' && _expenseCategories.isNotEmpty) {
          _selectedCategory = _expenseCategories.first.name;
        } else if (_selectedType == 'income' && _incomeCategories.isNotEmpty) {
          _selectedCategory = _incomeCategories.first.name;
        } else if (_selectedType == 'transfer' && _transferCategories.isNotEmpty) {
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
    final accounts = await OptimizedDataService.getAccounts();

    if (accounts.isEmpty) {
      final defaultAccount = Account(
        id: const Uuid().v4(),
        name: 'Cash',
        balance: 0.0,
        type: 'cash',
        icon: 'wallet',
        createdAt: DateTime.now(),
      );
      await OptimizedDataService.addAccount(defaultAccount);
      if (mounted) {
        setState(() {
          _accounts = [defaultAccount];
          _selectedAccountId = defaultAccount.id;
        });
      }
    } else {
      final sorted = List<Account>.from(accounts)
        ..sort((a, b) {
          if (a.balance >= 0 && b.balance < 0) return -1;
          if (a.balance < 0 && b.balance >= 0) return 1;
          final ap = _accountPriority(a.type);
          final bp = _accountPriority(b.type);
          if (ap != bp) return bp.compareTo(ap);
          return b.balance.compareTo(a.balance);
        });
      if (mounted) {
        setState(() {
          _accounts = sorted;
          _selectedAccountId ??= sorted.first.id;
          if (_selectedType == 'transfer' && sorted.length > 1) {
            _selectedToAccountId ??= sorted[1].id;
          }
        });
      }
    }
  }

  int _accountPriority(String type) {
    const map = {'cash': 5, 'bank': 4, 'savings': 3, 'credit': 2, 'investment': 1};
    return map[type.toLowerCase()] ?? 0;
  }

  // ── Calculator logic ───────────────────────────────────────────────────────

  void _onNumber(String n) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_displayAmount == '0') {
        _displayAmount = n;
      } else {
        _displayAmount += n;
      }
      _calculationString += n;
      _tryUpdateTotal();
    });
  }

  void _onOperator(String op) {
    if (_calculationString.isNotEmpty &&
        !_isOp(_calculationString[_calculationString.length - 1])) {
      HapticFeedback.selectionClick();
      setState(() {
        _calculationString += op;
        _displayAmount = '0';
      });
    }
  }

  void _onEquals() {
    HapticFeedback.lightImpact();
    try {
      final result = _eval(_calculationString);
      setState(() {
        _displayAmount     = result.toStringAsFixed(2);
        _calculationString = _displayAmount;
        _runningTotal      = _displayAmount;
      });
    } catch (_) {
      setState(() {
        _displayAmount     = 'Error';
        _calculationString = '';
        _runningTotal      = '0';
      });
    }
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_calculationString.isNotEmpty) {
        _calculationString = _calculationString.substring(
          0, _calculationString.length - 1,
        );
        if (_calculationString.isEmpty) {
          _displayAmount = '0';
          _runningTotal  = '0';
        } else {
          final parts = _calculationString.split(RegExp(r'[+\-×÷]'));
          _displayAmount = parts.last.isEmpty ? '0' : parts.last;
          _tryUpdateTotal();
        }
      }
    });
  }

  void _onDecimal() {
    if (!_displayAmount.contains('.')) {
      setState(() {
        _displayAmount     += '.';
        _calculationString += '.';
      });
    }
  }

  void _onClear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _displayAmount     = '0';
      _calculationString = '';
      _runningTotal      = '0';
    });
  }

  void _tryUpdateTotal() {
    try {
      if (_calculationString.isNotEmpty) {
        _runningTotal = _eval(_calculationString).toStringAsFixed(2);
      }
    } catch (_) {}
  }

  bool _isOp(String c) => ['+', '-', '×', '÷'].contains(c);

  double _eval(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    final p = GrammarParser();
    final exp = p.parse(expr);
    final ev = RealEvaluator();
    return ev.evaluate(exp).toDouble();
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_selectedAccountId == null) {
      _snack('Please select an account');
      return;
    }
    if (_selectedCategory.isEmpty) {
      _snack('Please select a category');
      return;
    }
    final amount = double.tryParse(_displayAmount);
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount');
      return;
    }

    if (_selectedType == 'expense') {
      final acc = _accounts.firstWhere((a) => a.id == _selectedAccountId);
      if (acc.balance < amount) {
        final ok = await _confirmNegativeBalance(acc.name, acc.balance, amount);
        if (!ok) return;
      }
    }

    final txn = Transaction(
      id: widget.editingTransaction?.id ?? const Uuid().v4(),
      title: _selectedCategory,
      amount: amount,
      date: DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
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

    if (widget.editingTransaction != null) {
      await appState.updateTransactionOptimistically(txn);
    } else {
      await appState.addTransactionOptimistically(txn);
    }

    if (mounted) Navigator.pop(context, txn);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppText.bodyStyle(Colors.white)),
        backgroundColor: context.cInk,
      ),
    );
  }

  Future<bool> _confirmNegativeBalance(
    String name, double balance, double amount,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: context.cCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
              side: BorderSide(color: context.cBorder, width: 1),
            ),
            title: Text('Low balance', style: AppText.title(context.cInk)),
            content: Text(
              '"$name" will go negative (${context.watch<CurrencyProvider>().currencySymbol}${(balance - amount).toStringAsFixed(0)}). Continue?',
              style: AppText.bodyStyle(context.cInk2),
            ),
            actions: [
              AppButtonGhost(label: 'Cancel',  onTap: () => Navigator.pop(context, false)),
              AppButtonGhost(label: 'Proceed', onTap: () => Navigator.pop(context, true)),
            ],
          ),
        ) ??
        false;
  }

  // ── Date / time ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1800),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Selectors ──────────────────────────────────────────────────────────────

  void _showAccountSelector({bool toAccount = false}) {
    final list = toAccount
        ? _accounts.where((a) => a.id != _selectedAccountId).toList()
        : List<Account>.from(_accounts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectSheet(
        title: toAccount ? 'To Account' : 'Account',
        child: ListView(
          shrinkWrap: true,
          children: list.map((acc) {
            final sel = toAccount
                ? acc.id == _selectedToAccountId
                : acc.id == _selectedAccountId;
            return _SelectTile(
              leading: Text(_accountEmoji(acc.type),
                  style: const TextStyle(fontSize: 18)),
              title: acc.name,
              subtitle: acc.type,
              selected: sel,
              onTap: () {
                setState(() {
                  if (toAccount) {
                    _selectedToAccountId = acc.id;
                  } else {
                    _selectedAccountId = acc.id;
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategorySelector() {
    final cats = _selectedType == 'expense'
        ? _expenseCategories
        : _selectedType == 'income'
            ? _incomeCategories
            : _transferCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectSheet(
        title: 'Category',
        child: Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: cats.map((cat) {
            final sel = cat.name == _selectedCategory;
            final color = CategoryService.getColorFromHex(cat.color);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat.name);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? color.withValues(alpha: 0.15)
                      : context.cSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: sel ? color : context.cBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CategoryService.getIconData(cat.icon),
                        size: 14, color: sel ? color : context.cInk3),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: AppText.mono(
                        AppText.tinier + 1,
                        sel ? AppText.semibold : AppText.regular,
                        sel ? color : context.cInk3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _accountEmoji(String type) {
    const map = {
      'cash': '💵', 'bank': '🏦', 'savings': '🏧',
      'credit': '💳', 'debit': '💳', 'investment': '📈',
      'digital': '📱',
    };
    return map[type.toLowerCase()] ?? '💰';
  }

  IconData _categoryIcon(String name) {
    final all = [..._expenseCategories, ..._incomeCategories, ..._transferCategories];
    final cat = all.firstWhere(
      (c) => c.name == name,
      orElse: () => Category(
        id: '', name: '', type: '', icon: 'category',
        color: '#808080', createdAt: DateTime.now(),
      ),
    );
    return CategoryService.getIconData(cat.icon);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currencySymbol;
    final typeColor = _selectedType == 'income'
        ? AppColors.ok
        : _selectedType == 'expense'
            ? AppColors.danger
            : context.cAccent;

    return Scaffold(
      backgroundColor: context.cBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s4, AppSpacing.s8, AppSpacing.s4, 0,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppText.bodyStyle(context.cInk3).copyWith(
                        fontWeight: AppText.medium, fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.editingTransaction != null
                            ? 'Edit Transaction'
                            : 'Add Transaction',
                        style: AppText.bodyStyle(context.cInk).copyWith(
                          fontWeight: AppText.semibold, fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: AppText.bodyStyle(context.cAccent).copyWith(
                        fontWeight: AppText.bold, fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Type selector
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
              ),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  border: Border.all(color: context.cBorder, width: 1),
                ),
                child: Row(
                  children: ['expense', 'income', 'transfer'].map((t) {
                    final sel = t == _selectedType;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedType = t;
                            final cats = t == 'expense'
                                ? _expenseCategories
                                : t == 'income'
                                    ? _incomeCategories
                                    : _transferCategories;
                            if (cats.isNotEmpty) _selectedCategory = cats.first.name;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: sel
                                ? (t == 'income' ? AppColors.ok : t == 'expense' ? AppColors.danger : context.cAccent)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.r8),
                          ),
                          child: Center(
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: AppText.mono(
                                AppText.tinier + 1,
                                sel ? AppText.bold : AppText.medium,
                                sel ? Colors.white : context.cInk3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Account + Category row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SelectorChip(
                      label: _selectedType == 'transfer' ? 'From' : 'Account',
                      value: _accounts
                              .where((a) => a.id == _selectedAccountId)
                              .firstOrNull
                              ?.name ??
                          'Select',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => _showAccountSelector(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  if (_selectedType == 'transfer')
                    Expanded(
                      child: _SelectorChip(
                        label: 'To',
                        value: _accounts
                                .where((a) => a.id == _selectedToAccountId)
                                .firstOrNull
                                ?.name ??
                            'Select',
                        icon: Icons.account_balance_outlined,
                        onTap: () => _showAccountSelector(toAccount: true),
                      ),
                    )
                  else
                    Expanded(
                      child: _SelectorChip(
                        label: 'Category',
                        value: _selectedCategory.isEmpty ? 'Select' : _selectedCategory,
                        icon: _selectedCategory.isEmpty
                            ? Icons.grid_view_rounded
                            : _categoryIcon(_selectedCategory),
                        onTap: _showCategorySelector,
                        color: typeColor,
                      ),
                    ),
                ],
              ),
            ),

            // Notes
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, AppSpacing.s6, AppSpacing.s16, 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.cCard,
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  border: Border.all(color: context.cBorder, width: 1),
                ),
                child: TextField(
                  controller: _notesController,
                  style: AppText.bodyStyle(context.cInk).copyWith(fontSize: 12),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Add a note…',
                    hintStyle: AppText.bodyStyle(context.cInk3).copyWith(fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
                    ),
                    prefixIcon: Icon(Icons.notes_outlined,
                        size: 14, color: context.cInk3),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 32, minHeight: 0,
                    ),
                  ),
                ),
              ),
            ),

            // Display
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, AppSpacing.s6, AppSpacing.s16, 0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s14, vertical: AppSpacing.s10,
                ),
                decoration: BoxDecoration(
                  color: context.cCard,
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  border: Border.all(color: context.cBorder, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_calculationString.isNotEmpty &&
                              _calculationString != _displayAmount) ...[
                            Text(
                              _calculationString,
                              style: AppText.monoCaption(context.cInk3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            '$currency$_displayAmount',
                            style: AppText.mono(28, AppText.semibold, typeColor),
                          ),
                          if (_runningTotal != '0' &&
                              _runningTotal != _displayAmount &&
                              _calculationString != _displayAmount) ...[
                            const SizedBox(height: 2),
                            Text(
                              '= $currency$_runningTotal',
                              style: AppText.monoCaption(context.cInk3),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _IconBtn(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                          color: context.cInk3,
                        ),
                        const SizedBox(height: 4),
                        _IconBtn(
                          icon: Icons.clear,
                          onTap: _onClear,
                          color: context.cInk3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Date + Time
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, AppSpacing.s6, AppSpacing.s16, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
                        ),
                        decoration: BoxDecoration(
                          color: context.cCard,
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                          border: Border.all(color: context.cBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: context.cInk3),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM y').format(_selectedDate),
                              style: AppText.mono(10, AppText.medium, context.cInk2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
                        ),
                        decoration: BoxDecoration(
                          color: context.cCard,
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                          border: Border.all(color: context.cBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_outlined,
                                size: 12, color: context.cInk3),
                            const SizedBox(width: 4),
                            Text(
                              _selectedTime.format(context),
                              style: AppText.mono(10, AppText.medium, context.cInk2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Calculator grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12, AppSpacing.s6, AppSpacing.s12, AppSpacing.s8,
                ),
                child: _buildCalcGrid(typeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcGrid(Color accentColor) {
    final buttons = [
      ['7', '8', '9', '+'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '×'],
      ['.', '0', '=', '÷'],
    ];

    return Column(
      children: buttons.map((row) {
        return Expanded(
          child: Row(
            children: row.map((key) {
              final isOp = ['+', '-', '×', '÷'].contains(key);
              final isEq = key == '=';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _CalcKey(
                    label: key,
                    bg: isEq
                        ? accentColor
                        : isOp
                            ? context.cSurface
                            : context.cCard,
                    fg: isEq
                        ? Colors.white
                        : isOp
                            ? accentColor
                            : context.cInk,
                    borderColor: isEq ? Colors.transparent : context.cBorder,
                    onTap: () {
                      if (isEq) {
                        _onEquals();
                      } else if (isOp) {
                        _onOperator(key);
                      } else if (key == '.') {
                        _onDecimal();
                      } else {
                        _onNumber(key);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _SelectorChip extends StatelessWidget {
  const _SelectorChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.cInk2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(AppRadius.r10),
          border: Border.all(color: context.cBorder, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppText.mono(8, AppText.regular, context.cInk3)),
                  Text(
                    value,
                    style: AppText.mono(10, AppText.semibold, fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more, size: 14, color: context.cInk3),
          ],
        ),
      ),
    );
  }
}

class _CalcKey extends StatelessWidget {
  const _CalcKey({
    required this.label,
    required this.bg,
    required this.fg,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color bg;
  final Color fg;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.mono(18, AppText.semibold, fg),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _SelectSheet extends StatelessWidget {
  const _SelectSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.r16),
        ),
        border: Border.all(color: context.cBorder, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(
                color: context.cBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s14),
          Text(title, style: AppText.title(context.cInk)),
          const SizedBox(height: AppSpacing.s14),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s6),
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: selected
              ? (context.isDark ? AppColors.accentBgDark : AppColors.accentBg)
              : context.cSurface,
          borderRadius: BorderRadius.circular(AppRadius.r10),
          border: Border.all(
            color: selected ? context.cAccent : context.cBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.cardTitleStyle(context.cInk)),
                  Text(subtitle,
                      style: AppText.monoCaption(context.cInk3)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 14, color: context.cAccent),
          ],
        ),
      ),
    );
  }
}
