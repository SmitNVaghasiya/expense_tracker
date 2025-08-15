import 'package:flutter/material.dart';
import 'package:spendwise/services/theme_provider.dart';
import 'package:provider/provider.dart';


class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose your preferred theme:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Light Theme Option
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.light_mode,
                      color: themeProvider.themeMode == ThemeMode.light
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: const Text('Light Theme'),
                    subtitle: const Text('Clean and bright interface'),
                    trailing: themeProvider.themeMode == ThemeMode.light
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.light);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Dark Theme Option
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.dark_mode,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Easy on the eyes in low light'),
                    trailing: themeProvider.themeMode == ThemeMode.dark
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.dark);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // System Theme Option
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.settings_system_daydream,
                      color: themeProvider.themeMode == ThemeMode.system
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: const Text('System Theme'),
                    subtitle: const Text('Follow your device settings'),
                    trailing: themeProvider.themeMode == ThemeMode.system
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.system);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Theme Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme Preview:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sample Transaction',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Food & Dining',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '₹500.00',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lunch at restaurant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
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
}
