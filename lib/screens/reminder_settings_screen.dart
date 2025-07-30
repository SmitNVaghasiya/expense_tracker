import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/reminder_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReminderService>(
        builder: (context, reminderService, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Daily Expense Reminder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Get a daily reminder to track your expenses and stay on top of your budget.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Enable/Disable Switch
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable Daily Reminder'),
                    subtitle: const Text('Receive a notification every day'),
                    value: reminderService.isEnabled,
                    onChanged: (bool value) {
                      reminderService.setReminderEnabled(value);
                    },
                    secondary: Icon(
                      Icons.notifications_active,
                      color: reminderService.isEnabled 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Time Selection
                if (reminderService.isEnabled) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Reminder Time'),
                      subtitle: Text(reminderService.getReminderTimeString()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _selectTime(context, reminderService),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
                
                // Information Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• You\'ll receive a notification at the selected time\n'
                          '• The reminder will help you stay consistent with expense tracking\n'
                          '• You can change the time or disable it anytime\n'
                          '• Notifications work even when the app is closed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tips
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tips for Better Tracking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Set the reminder for a time when you\'re usually free\n'
                          '• Choose evening time to review your day\'s expenses\n'
                          '• Keep the reminder enabled to build a consistent habit\n'
                          '• Use the reminder as a cue to open the app and log expenses',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, ReminderService reminderService) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderService.reminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != reminderService.reminderTime) {
      reminderService.setReminderTime(picked);
    }
  }
} 