import 'package:flutter/material.dart';
import 'package:spendwise/models/bill_reminder.dart';
import 'package:spendwise/services/bill_reminder_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;

class BillRemindersScreen extends StatefulWidget {
  const BillRemindersScreen({super.key});

  @override
  State<BillRemindersScreen> createState() => _BillRemindersScreenState();
}

class _BillRemindersScreenState extends State<BillRemindersScreen> {
  List<BillReminder> _billReminders = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, paid, unpaid, overdue

  @override
  void initState() {
    super.initState();
    _loadBillReminders();
  }

  Future<void> _loadBillReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await BillReminderService.getBillReminders();
      setState(() {
        _billReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bill reminders: $e')),
        );
      }
    }
  }

  List<BillReminder> get _filteredReminders {
    switch (_filterType) {
      case 'paid':
        return _billReminders.where((r) => r.isPaid).toList();
      case 'unpaid':
        return _billReminders.where((r) => !r.isPaid).toList();
      case 'overdue':
        return _billReminders.where((r) => r.isOverdue).toList();
      default:
        return _billReminders;
    }
  }

  Future<void> _togglePaymentStatus(BillReminder reminder) async {
    try {
      final updated = reminder.copyWith(isPaid: !reminder.isPaid);
      await BillReminderService.updateBillReminder(updated);
      await _loadBillReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isPaid ? 'Bill marked as paid' : 'Bill marked as unpaid',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating bill: $e')));
      }
    }
  }

  Future<void> _deleteBillReminder(BillReminder reminder) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => common_widgets.ConfirmationBottomSheet(
        title: 'Delete Bill Reminder',
        message: 'Are you sure you want to delete "${reminder.title}"?',
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
        await BillReminderService.deleteBillReminder(reminder.id);
        await _loadBillReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill reminder deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting bill: $e')));
        }
      }
    }
  }

  void _showAddEditDialog([BillReminder? reminder]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEditBillReminderSheet(
        reminder: reminder,
        onSaved: _loadBillReminders,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminders'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'paid', child: Text('Paid')),
              const PopupMenuItem(value: 'unpaid', child: Text('Unpaid')),
              const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredReminders.isEmpty
          ? _buildEmptyState()
          : _buildRemindersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bill reminders',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first bill reminder to never miss a payment',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Bill Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = _filteredReminders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: reminder.isPaid
                  ? Colors.green[100]
                  : reminder.isOverdue
                  ? Colors.red[100]
                  : Colors.orange[100],
              child: Icon(
                reminder.isPaid ? Icons.check : Icons.receipt_long,
                color: reminder.isPaid
                    ? Colors.green
                    : reminder.isOverdue
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
            title: Text(
              reminder.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: reminder.isPaid ? Colors.grey[600] : null,
                decoration: reminder.isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  reminder.amount.toStringAsFixed(2),
                  style: TextStyle(
                    color: reminder.isPaid ? Colors.grey : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Due: ${_formatDate(reminder.dueDate)}',
                  style: TextStyle(
                    color: reminder.isOverdue ? Colors.red : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    _togglePaymentStatus(reminder);
                    break;
                  case 'edit':
                    _showAddEditDialog(reminder);
                    break;
                  case 'delete':
                    _deleteBillReminder(reminder);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    reminder.isPaid ? 'Mark as Unpaid' : 'Mark as Paid',
                  ),
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

class _AddEditBillReminderSheet extends StatefulWidget {
  final BillReminder? reminder;
  final VoidCallback onSaved;

  const _AddEditBillReminderSheet({this.reminder, required this.onSaved});

  @override
  State<_AddEditBillReminderSheet> createState() =>
      _AddEditBillReminderSheetState();
}

class _AddEditBillReminderSheetState extends State<_AddEditBillReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isPaid = false;
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  int _reminderDays = 3; // Days before due date

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _amountController.text = reminder.amount.toString();
      _descriptionController.text = reminder.notes ?? '';
      _dueDate = reminder.dueDate;
      _isPaid = reminder.isPaid;
      _isRecurring = reminder.recurringPattern != null;
      _recurringFrequency = reminder.recurringPattern ?? 'monthly';
      _reminderDays = reminder.reminderDays;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBillReminder() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = double.parse(_amountController.text);

      final reminder = BillReminder(
        id:
            widget.reminder?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        category: 'Bills', // Default category
        dueDate: _dueDate,
        isPaid: _isPaid,
        notes: _descriptionController.text.trim(),
        reminderDays: _reminderDays,
        recurringPattern: _isRecurring ? _recurringFrequency : null,
      );

      if (widget.reminder != null) {
        await BillReminderService.updateBillReminder(reminder);
      } else {
        await BillReminderService.addBillReminder(reminder);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder != null
                  ? 'Bill reminder updated'
                  : 'Bill reminder created',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving bill reminder: $e')),
        );
      }
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
                  widget.reminder != null
                      ? 'Edit Bill Reminder'
                      : 'New Bill Reminder',
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
                labelText: 'Bill Title',
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

            // Amount and Due Date
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
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _dueDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
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

            // Recurring Switch
            SwitchListTile(
              title: const Text('Recurring Bill'),
              subtitle: const Text('This bill repeats regularly'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() => _isRecurring = value);
              },
            ),

            // Recurring Frequency (if recurring)
            if (_isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                    value: 'quarterly',
                    child: Text('Quarterly'),
                  ),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurringFrequency = value);
                  }
                },
              ),
            ],

            const SizedBox(height: 16),

            // Payment Status
            SwitchListTile(
              title: const Text('Paid'),
              subtitle: const Text('Mark this bill as paid'),
              value: _isPaid,
              onChanged: (value) {
                setState(() => _isPaid = value);
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _saveBillReminder,
              child: Text(widget.reminder != null ? 'Update' : 'Create'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
