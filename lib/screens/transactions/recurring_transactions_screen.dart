import 'package:flutter/material.dart';
import 'package:spendwise/models/recurring_transaction.dart';
import 'package:spendwise/services/recurring_transaction_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/widgets/common/display_options_dialog.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  final RecurringTransactionService _service = RecurringTransactionService();
  List<RecurringTransaction> _recurringTransactions = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    _loadRecurringTransactions();
  }

  Future<void> _loadRecurringTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions =
          await RecurringTransactionService.getRecurringTransactions();
      setState(() {
        _recurringTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recurring transactions: $e')),
        );
      }
    }
  }

  List<RecurringTransaction> get _filteredTransactions {
    switch (_filterType) {
      case 'active':
        return _recurringTransactions.where((t) => t.isActive).toList();
      case 'inactive':
        return _recurringTransactions.where((t) => !t.isActive).toList();
      default:
        return _recurringTransactions;
    }
  }

  Future<void> _toggleActiveStatus(RecurringTransaction transaction) async {
    try {
      final updated = transaction.copyWith(isActive: !transaction.isActive);
      await RecurringTransactionService.updateRecurringTransaction(updated);
      await _loadRecurringTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isActive
                  ? 'Recurring transaction activated'
                  : 'Recurring transaction deactivated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => common_widgets.ConfirmationBottomSheet(
        title: 'Delete Recurring Transaction',
        message: 'Are you sure you want to delete "${transaction.title}"?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        icon: Icons.delete_forever,
      ),
    );

    if (confirmed == true) {
      try {
        await RecurringTransactionService.deleteRecurringTransaction(
          transaction.id,
        );
        await _loadRecurringTransactions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recurring transaction deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction: $e')),
          );
        }
      }
    }
  }

  void _showDisplayOptions() async {
    await showDisplayOptionsDialog(
      context,
      selectedViewMode: 'MONTHLY', // Default for recurring transactions
      showTotal: true, // Default for recurring transactions
      carryOver: true, // Default for recurring transactions
      onViewModeChanged: (mode) {
        // Handle view mode changes if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View mode changed to: $mode')),
        );
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

  void _showAddEditDialog([RecurringTransaction? transaction]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEditRecurringTransactionSheet(
        transaction: transaction,
        onSaved: _loadRecurringTransactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDisplayOptions,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTransactions.isEmpty
          ? _buildEmptyState()
          : _buildTransactionsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return common_widgets.EmptyStateWidget(
      icon: Icons.repeat,
      title: 'No recurring transactions',
      message: 'Add your first recurring transaction to automate your finances',
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isActive
                  ? Colors.green[100]
                  : Colors.grey[100],
              child: Icon(
                transaction.isActive ? Icons.repeat : Icons.pause,
                color: transaction.isActive ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(
              transaction.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.isActive ? null : Colors.grey[600],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  transaction.amount.toStringAsFixed(2),
                  style: TextStyle(
                    color: transaction.type == 'expense'
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.frequency} • Next: ${_formatDate(transaction.nextDueDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    _toggleActiveStatus(transaction);
                    break;
                  case 'edit':
                    _showAddEditDialog(transaction);
                    break;
                  case 'delete':
                    _deleteRecurringTransaction(transaction);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(transaction.isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 0) return 'Overdue';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddEditRecurringTransactionSheet extends StatefulWidget {
  final RecurringTransaction? transaction;
  final VoidCallback onSaved;

  const _AddEditRecurringTransactionSheet({
    this.transaction,
    required this.onSaved,
  });

  @override
  State<_AddEditRecurringTransactionSheet> createState() =>
      _AddEditRecurringTransactionSheetState();
}

class _AddEditRecurringTransactionSheetState
    extends State<_AddEditRecurringTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedFrequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  final String _currency = 'USD';

  final RecurringTransactionService _service = RecurringTransactionService();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.notes ?? '';
      _selectedType = transaction.type;
      _selectedFrequency = transaction.frequency;
      _startDate = transaction.startDate;
      _endDate = transaction.endDate;
      _isActive = transaction.isActive;
      // Currency is not part of the RecurringTransaction model
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRecurringTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = double.parse(_amountController.text);

      final transaction = RecurringTransaction(
        id:
            widget.transaction?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        type: _selectedType,
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        notes: _descriptionController.text.trim(),
        category: 'General', // TODO: Add category selection
        accountId: 'default', // TODO: Add account selection
        nextDueDate: _calculateNextDueDate(),
      );

      if (widget.transaction != null) {
        await RecurringTransactionService.updateRecurringTransaction(
          transaction,
        );
      } else {
        await RecurringTransactionService.addRecurringTransaction(transaction);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction != null
                  ? 'Recurring transaction updated'
                  : 'Recurring transaction created',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    }
  }

  DateTime _calculateNextDueDate() {
    final now = DateTime.now();
    if (_startDate.isAfter(now)) return _startDate;

    switch (_selectedFrequency) {
      case 'daily':
        return now;
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month + 1, _startDate.day);
      case 'yearly':
        return DateTime(now.year + 1, _startDate.month, _startDate.day);
      default:
        return now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.transaction != null
                      ? 'Edit Recurring Transaction'
                      : 'New Recurring Transaction',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount and Type
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'expense',
                        child: Text('EXPENSE'),
                      ),
                      DropdownMenuItem(value: 'income', child: Text('INCOME')),
                      DropdownMenuItem(
                        value: 'transfer',
                        child: Text('TRANSFER'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frequency and Start Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFrequency = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(1800),
                        lastDate: DateTime.now().add(const Duration(days: 36500)),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Active Status
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Enable this recurring transaction'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _saveRecurringTransaction,
              child: Text(widget.transaction != null ? 'Update' : 'Create'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
