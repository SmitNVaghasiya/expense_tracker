import 'package:flutter/material.dart';
import 'simple_time_input.dart';

class TimeInputDemo extends StatefulWidget {
  const TimeInputDemo({super.key});

  @override
  State<TimeInputDemo> createState() => _TimeInputDemoState();
}

class _TimeInputDemoState extends State<TimeInputDemo> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Input Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhanced Time Input',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This improved time input widget provides:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text('• Automatic system time format detection'),
                    const Text('• Toggle between 24-hour and 12-hour formats'),
                    const Text('• AM/PM indicators for 12-hour format'),
                    const Text('• Number-only keypad input'),
                    const Text('• Visual cues for valid time ranges'),
                    const Text('• Better error messages and validation'),
                    const SizedBox(height: 16),
                    Text(
                      'Selected Time: ${_selectedTime.format(context)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Time Input',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SimpleTimeInput(
                      initialTime: _selectedTime,
                      onTimeChanged: (time) {
                        setState(() {
                          _selectedTime = time;
                        });
                      },
                      label: 'Select Time',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Smart Format Detection',
                      'Automatically detects your system time format preference',
                      Icons.smart_toy,
                    ),
                    _buildFeatureItem(
                      'Easy Toggle',
                      'Switch between 24-hour and 12-hour formats with one tap',
                      Icons.swap_horiz,
                    ),
                    _buildFeatureItem(
                      'AM/PM Support',
                      'Clear AM/PM indicators for 12-hour format',
                      Icons.access_time_filled,
                    ),
                    _buildFeatureItem(
                      'Number Keypad',
                      'Direct number input for quick time entry',
                      Icons.dialpad,
                    ),
                    _buildFeatureItem(
                      'Visual Guidance',
                      'Clear hints and error messages for better UX',
                      Icons.visibility,
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

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
