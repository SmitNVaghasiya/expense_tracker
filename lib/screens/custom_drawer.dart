import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/theme_selection_screen.dart';
import 'package:expense_tracker/screens/currency_selection_screen.dart';
import 'package:expense_tracker/screens/help_screen.dart';
import 'package:expense_tracker/screens/import_export_screen.dart';
import 'package:expense_tracker/screens/reminder_settings_screen.dart';
import 'package:expense_tracker/screens/backup_restore_screen.dart';
import 'package:expense_tracker/screens/delete_reset_screen.dart';
import 'package:expense_tracker/screens/feedback_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'MyMoney',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Expense Tracker',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Import/Export
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Import/Export'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportExportScreen(),
                ),
              );
            },
          ),

          // Theme
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSelectionScreen(),
                ),
              );
            },
          ),

          // Currency
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Currency'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencySelectionScreen(),
                ),
              );
            },
          ),

          // Reminder
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Daily Reminder'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReminderSettingsScreen(),
                ),
              );
            },
          ),

          // Delete and Reset
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete & Reset'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteResetScreen(),
                ),
              );
            },
          ),

          // Backup and Restore
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupRestoreScreen(),
                ),
              );
            },
          ),

          // Help
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),

          // Feedback
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),

          // Divider
          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement about screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About screen coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
