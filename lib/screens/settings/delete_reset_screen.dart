import 'package:flutter/material.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;

class DeleteResetScreen extends StatefulWidget {
  const DeleteResetScreen({super.key});

  @override
  State<DeleteResetScreen> createState() => _DeleteResetScreenState();
}

class _DeleteResetScreenState extends State<DeleteResetScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete & Reset'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Warning: These actions cannot be undone. Make sure you have a backup before proceeding.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Delete Specific Data Section
            const Text(
              'Delete Specific Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Delete Transactions
            Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long, color: Colors.red.shade600),
                title: const Text('Delete All Transactions'),
                subtitle: const Text('Remove all income and expense records'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteConfirmation('transactions'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Delete Budgets
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.account_balance,
                  color: Colors.red.shade600,
                ),
                title: const Text('Delete All Budgets'),
                subtitle: const Text('Remove all budget categories and limits'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteConfirmation('budgets'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Delete Accounts
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red.shade600,
                ),
                title: const Text('Delete All Accounts'),
                subtitle: const Text('Remove all financial accounts'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteConfirmation('accounts'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Delete Groups
            Card(
              child: ListTile(
                leading: Icon(Icons.group, color: Colors.red.shade600),
                title: const Text('Delete All Groups'),
                subtitle: const Text('Remove all group memberships'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _showDeleteConfirmation('groups'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reset Everything Section
            const Text(
              'Reset Everything:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Reset All Data
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                subtitle: const Text(
                  'This will delete ALL data and reset the app to its initial state',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: ElevatedButton(
                  onPressed: _isLoading ? null : () => _showResetConfirmation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('RESET ALL'),
                ),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String dataType) async {
    String title;
    String message;

    switch (dataType) {
      case 'transactions':
        title = 'Delete All Transactions';
        message =
            'Are you sure you want to delete all transactions? This action cannot be undone.';
        break;
      case 'budgets':
        title = 'Delete All Budgets';
        message =
            'Are you sure you want to delete all budgets? This action cannot be undone.';
        break;
      case 'accounts':
        title = 'Delete All Accounts';
        message =
            'Are you sure you want to delete all accounts? This action cannot be undone.';
        break;
      case 'groups':
        title = 'Delete All Groups';
        message =
            'Are you sure you want to delete all groups? This action cannot be undone.';
        break;
      default:
        return;
    }

    bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return common_widgets.ConfirmationBottomSheet(
          title: title,
          message: message,
          confirmText: 'Delete',
          cancelText: 'Cancel',
          confirmColor: Colors.red,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
          icon: Icons.delete_forever,
        );
      },
    );

    if (confirm == true) {
      await _deleteData(dataType);
    }
  }

  Future<void> _showResetConfirmation() async {
    bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return common_widgets.ConfirmationBottomSheet(
          title: 'Reset All Data',
          message:
              'This will delete ALL data including transactions, budgets, accounts, and groups. '
              'This action cannot be undone. Are you absolutely sure?',
          confirmText: 'RESET ALL',
          cancelText: 'Cancel',
          confirmColor: Colors.red,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
          icon: Icons.warning,
        );
      },
    );

    if (confirm == true) {
      await _resetAllData();
    }
  }

  Future<void> _deleteData(String dataType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (dataType) {
        case 'transactions':
          await DataService.clearAllTransactions();
          break;
        case 'budgets':
          await DataService.clearAllBudgets();
          break;
        case 'accounts':
          await DataService.clearAllAccounts();
          break;
        case 'groups':
          await DataService.clearAllGroups();
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted all $dataType'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting $dataType: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DataService.clearAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
