import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/core/navigation_state.dart';
import 'package:spendwise/screens/financial/financial_goals_screen.dart';
import 'package:spendwise/screens/reminders/bill_reminders_screen.dart';
import 'package:spendwise/screens/transactions/recurring_transactions_screen.dart';
import 'package:spendwise/screens/reminders/reminder_settings_screen.dart';
import 'package:spendwise/screens/settings/backup_restore_screen.dart';
import 'package:spendwise/screens/settings/currency_selection_screen.dart';
import 'package:spendwise/screens/settings/import_export_screen.dart';
import 'package:spendwise/screens/settings/feedback_screen.dart';
import 'package:spendwise/screens/settings/help_screen.dart';
import 'package:spendwise/screens/settings/delete_reset_screen.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';

class CustomDrawer extends StatelessWidget {
  // Keep callback for backwards compatibility but it's optional now
  final Function(int index)? onDestinationSelected;

  const CustomDrawer({super.key, this.onDestinationSelected});

  void _navigateToTab(BuildContext context, int shellIndex) {
    Navigator.pop(context);
    final navState = Provider.of<NavigationState>(context, listen: false);
    navState.setIndex(shellIndex);
  }

  void _pushRoute(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'SpendWise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personal Finance Manager',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // --- Main tabs ---
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () => _navigateToTab(context, 0),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Accounts'),
            onTap: () => _navigateToTab(context, 1),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: const Text('Budgets'),
            onTap: () => _navigateToTab(context, 2),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => _navigateToTab(context, 3),
          ),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text('Loans'),
            onTap: () => _navigateToTab(context, 4),
          ),

          const Divider(),

          // --- Sub-screens (pushed as routes) ---
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Financial Goals'),
            onTap: () => _pushRoute(context, const FinancialGoalsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Bill Reminders'),
            onTap: () => _pushRoute(context, const BillRemindersScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Recurring Transactions'),
            onTap: () => _pushRoute(context, const RecurringTransactionsScreen()),
          ),

          const Divider(),

          // --- Settings ---
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _pushRoute(context, const ReminderSettingsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () => _pushRoute(context, const BackupRestoreScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            onTap: () => _pushRoute(context, const CurrencySelectionScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Import/Export'),
            onTap: () => _pushRoute(context, const ImportExportScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calculator'),
            onTap: () => _pushRoute(context,
                const CalculatorTransactionScreen(initialType: 'expense')),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () => _pushRoute(context, const FeedbackScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => _pushRoute(context, const HelpScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete & Reset'),
            onTap: () => _pushRoute(context, const DeleteResetScreen()),
          ),
        ],
      ),
    );
  }
}
