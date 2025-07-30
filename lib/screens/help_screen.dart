import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Getting Started Section
            _buildSection(
              context,
              'Getting Started',
              Icons.rocket_launch,
              [
                'Add your first transaction by tapping the + button',
                'Set up your accounts and budgets',
                'Configure your preferred currency',
                'Enable daily reminders to track expenses',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Features Section
            _buildSection(
              context,
              'Key Features',
              Icons.star,
              [
                'Track income and expenses with categories',
                'Set monthly budgets and monitor spending',
                'View detailed reports and analytics',
                'Import/export data via CSV files',
                'Backup and restore your data',
                'Multiple currency support',
                'Light and dark theme options',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Navigation Section
            _buildSection(
              context,
              'Navigation',
              Icons.navigation,
              [
                'Dashboard: View overview and recent transactions',
                'Reports: Detailed spending analysis',
                'Budgets: Manage spending limits',
                'Accounts: Track multiple accounts',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSection(
              context,
              'Settings & Options',
              Icons.settings,
              [
                'Theme: Choose light, dark, or system theme',
                'Currency: Select your preferred currency',
                'Import/Export: Backup and restore data',
                'Daily Reminder: Get notifications to track expenses',
                'Delete & Reset: Clear data when needed',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tips Section
            _buildSection(
              context,
              'Tips for Better Tracking',
              Icons.lightbulb,
              [
                'Record transactions immediately after making them',
                'Use specific categories for better organization',
                'Set realistic budgets for each category',
                'Review your spending patterns regularly',
                'Export data periodically for backup',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Troubleshooting Section
            _buildSection(
              context,
              'Troubleshooting',
              Icons.build,
              [
                'If data doesn\'t save, check your device storage',
                'For import issues, ensure CSV format is correct',
                'Restart the app if it becomes unresponsive',
                'Clear app data if you encounter persistent issues',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Need More Help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'If you need additional support or have questions not covered here, please use the Feedback option in the menu to contact us.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to feedback screen
                        Navigator.pushNamed(context, '/feedback');
                      },
                      icon: const Icon(Icons.feedback),
                      label: const Text('Send Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Version
            Center(
              child: Text(
                'MyMoney v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}