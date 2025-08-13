import 'package:flutter/material.dart';
import 'package:spendwise/services/loan_reminder_service.dart';

class LoanReminderSettingsScreen extends StatefulWidget {
  const LoanReminderSettingsScreen({super.key});

  @override
  State<LoanReminderSettingsScreen> createState() =>
      _LoanReminderSettingsScreenState();
}

class _LoanReminderSettingsScreenState
    extends State<LoanReminderSettingsScreen> {
  bool _reminderEnabled = true;
  bool _autoDeductEnabled = false;
  int _reminderAdvanceDays = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await LoanReminderService.getReminderSettings();
    setState(() {
      _reminderEnabled = settings['reminderEnabled'] ?? true;
      _autoDeductEnabled = settings['autoDeductEnabled'] ?? false;
      _reminderAdvanceDays = settings['reminderAdvanceDays'] ?? 3;
    });
  }

  Future<void> _updateSettings() async {
    await LoanReminderService.updateReminderSettings(
      reminderEnabled: _reminderEnabled,
      autoDeductEnabled: _autoDeductEnabled,
      reminderAdvanceDays: _reminderAdvanceDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Reminder Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Loan Reminder Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Configure automatic reminders and deductions for your loans.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reminder Settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Loan Reminders'),
                    subtitle: const Text(
                      'Get notified about upcoming loan payments',
                    ),
                    value: _reminderEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _reminderEnabled = value;
                      });
                      _updateSettings();
                    },
                    secondary: Icon(
                      Icons.notifications,
                      color: _reminderEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),

                  if (_reminderEnabled) ...[
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Reminder Advance Days'),
                      subtitle: Text(
                        'Remind me $_reminderAdvanceDays days before payment',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_reminderAdvanceDays > 1) {
                                setState(() {
                                  _reminderAdvanceDays--;
                                });
                                _updateSettings();
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text('$_reminderAdvanceDays'),
                          IconButton(
                            onPressed: () {
                              if (_reminderAdvanceDays < 30) {
                                setState(() {
                                  _reminderAdvanceDays++;
                                });
                                _updateSettings();
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Auto-Deduction Settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Auto-Deduction'),
                    subtitle: const Text(
                      'Automatically deduct loan payments from selected account',
                    ),
                    value: _autoDeductEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _autoDeductEnabled = value;
                      });
                      _updateSettings();
                    },
                    secondary: Icon(
                      Icons.account_balance_wallet,
                      color: _autoDeductEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),

                  if (_autoDeductEnabled) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Auto-Deduction Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Auto-deduction will only work for loans with linked accounts\n'
                            '• Sufficient balance is required in the linked account\n'
                            '• Failed deductions will be reported in loan alerts\n'
                            '• You can manually process deductions from the loans screen',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Information Card
            Card(
              color: Colors.orange.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Set up auto-deduction for recurring loan payments\n'
                      '• Keep sufficient balance in linked accounts\n'
                      '• Review loan alerts regularly\n'
                      '• Manual processing is available as backup',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
