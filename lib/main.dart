import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/screens/index.dart';
import 'package:spendwise/services/index.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/core/routes.dart';
import 'package:spendwise/core/navigation_state.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/screens/shell/main_navigation_shell.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time format service
  await TimeFormatService.initialize();

  // Initialize unified database service
  await UnifiedDatabaseService.initialize();

  // Initialize notifications only on mobile platforms
  if (!kIsWeb) {
    try {
      await BillReminderService.initializeNotifications();
    } catch (e) {
      // Error logged
    }
  }

  // Set preferred orientations only on mobile platforms
  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      // Error logged
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => ReminderService()),
        ChangeNotifierProvider(create: (context) => OptimizedAppState()),
        ChangeNotifierProvider(create: (context) => NavigationState()),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SpendWise',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          home: const MainNavigationShell(),
          routes: {
            AppRoutes.expenses: (context) => const ExpensesScreen(),
            AppRoutes.income: (context) => const IncomeScreen(),
            AppRoutes.budgets: (context) => const BudgetsScreen(),
            AppRoutes.reports: (context) => const ReportsScreen(),
            AppRoutes.accounts: (context) => const AccountsScreen(),
            AppRoutes.importExport: (context) => const ImportExportScreen(),
            AppRoutes.theme: (context) => const ThemeSelectionScreen(),
            AppRoutes.currency: (context) => const CurrencySelectionScreen(),
            AppRoutes.backupRestore: (context) => const BackupRestoreScreen(),
            AppRoutes.deleteReset: (context) => const DeleteResetScreen(),
            AppRoutes.help: (context) => const HelpScreen(),
            AppRoutes.feedback: (context) => const FeedbackScreen(),
            AppRoutes.reminder: (context) => const ReminderSettingsScreen(),
            AppRoutes.loans: (context) => const LoansScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
