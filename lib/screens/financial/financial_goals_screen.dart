import 'package:flutter/material.dart';
import 'package:spendwise/models/financial_goal.dart';
import 'package:spendwise/services/financial_goal_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/widgets/common/display_options_dialog.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  List<FinancialGoal> _goals = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, active, completed, overdue

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final goals = await FinancialGoalService.getFinancialGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading financial goals: $e')),
        );
      }
    }
  }

  List<FinancialGoal> get _filteredGoals {
    switch (_filterType) {
      case 'active':
        return _goals.where((g) => g.isActive).toList();
      case 'completed':
        return _goals.where((g) => g.isCompleted).toList();
      case 'overdue':
        return _goals.where((g) => g.isOverdue).toList();
      default:
        return _goals;
    }
  }

  Future<void> _toggleActiveStatus(FinancialGoal goal) async {
    try {
      final updated = goal.copyWith(isActive: !goal.isActive);
      await FinancialGoalService.updateFinancialGoal(updated);
      await _loadGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isActive ? 'Goal activated' : 'Goal deactivated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating goal: $e')));
      }
    }
  }

  Future<void> _deleteGoal(FinancialGoal goal) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => common_widgets.ConfirmationBottomSheet(
        title: 'Delete Financial Goal',
        message: 'Are you sure you want to delete "${goal.title}"?',
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
        await FinancialGoalService.deleteFinancialGoal(goal.id);
        await _loadGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Financial goal deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting goal: $e')));
        }
      }
    }
  }

  void _showDisplayOptions() async {
    await showDisplayOptionsDialog(
      context,
      selectedViewMode: 'MONTHLY', // Default for financial goals
      showTotal: true, // Default for financial goals
      carryOver: true, // Default for financial goals
      onViewModeChanged: (mode) {
        // Handle view mode changes if needed
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

  void _showAddEditDialog([FinancialGoal? goal]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEditGoalSheet(goal: goal, onSaved: _loadGoals),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
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
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
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
          : _filteredGoals.isEmpty
          ? _buildEmptyState()
          : _buildGoalsList(),
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
          Icon(Icons.flag, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No financial goals',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your first financial goal to start tracking your progress',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Financial Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = _filteredGoals[index];
        final progress = goal.progressPercentage;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: goal.isCompleted
                  ? Colors.green[100]
                  : goal.isOverdue
                  ? Colors.red[100]
                  : Colors.blue[100],
              child: Icon(
                goal.isCompleted ? Icons.check : Icons.flag,
                color: goal.isCompleted
                    ? Colors.green
                    : goal.isOverdue
                    ? Colors.red
                    : Colors.blue,
              ),
            ),
            title: Text(
              goal.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: goal.isCompleted ? Colors.grey[600] : null,
                decoration: goal.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: goal.isCompleted ? Colors.grey : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% • ${goal.statusText}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    _toggleActiveStatus(goal);
                    break;
                  case 'edit':
                    _showAddEditDialog(goal);
                    break;
                  case 'delete':
                    _deleteGoal(goal);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    goal.isCompleted ? 'Mark as Active' : 'Mark as Completed',
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
}

class _AddEditGoalSheet extends StatefulWidget {
  final FinancialGoal? goal;
  final VoidCallback onSaved;

  const _AddEditGoalSheet({this.goal, required this.onSaved});

  @override
  State<_AddEditGoalSheet> createState() => _AddEditGoalSheetState();
}

class _AddEditGoalSheetState extends State<_AddEditGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _goalType = 'savings';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      final goal = widget.goal!;
      _titleController.text = goal.title;
      _targetAmountController.text = goal.targetAmount.toString();
      _currentAmountController.text = goal.currentAmount.toString();
      _descriptionController.text = goal.description ?? '';
      _targetDate = goal.targetDate;
      _goalType = goal.goalType;
      _isCompleted = goal.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = double.parse(_currentAmountController.text);

      final goal = FinancialGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _targetDate,
        createdAt: DateTime.now(),
        goalType: _goalType,
        isActive: _isCompleted, // Using _isCompleted as isActive for now
      );

      if (widget.goal != null) {
        await FinancialGoalService.updateFinancialGoal(goal);
      } else {
        await FinancialGoalService.addFinancialGoal(goal);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.goal != null
                  ? 'Financial goal updated'
                  : 'Financial goal created',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving goal: $e')));
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
                  widget.goal != null
                      ? 'Edit Financial Goal'
                      : 'New Financial Goal',
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
                labelText: 'Goal Title',
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

            // Target Amount and Current Amount
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter target amount';
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
                  child: TextFormField(
                    controller: _currentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal Type and Target Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _goalType,
                    decoration: const InputDecoration(
                      labelText: 'Goal Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'savings',
                        child: Text('Savings'),
                      ),
                      DropdownMenuItem(
                        value: 'debt',
                        child: Text('Debt Repayment'),
                      ),
                      DropdownMenuItem(
                        value: 'investment',
                        child: Text('Investment'),
                      ),
                      DropdownMenuItem(
                        value: 'purchase',
                        child: Text('Purchase'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _goalType = value);
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
                        initialDate: _targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _targetDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Target Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
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

            // Completion Status
            SwitchListTile(
              title: const Text('Completed'),
              subtitle: const Text('Mark this goal as completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() => _isCompleted = value);
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _saveGoal,
              child: Text(widget.goal != null ? 'Update' : 'Create'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
