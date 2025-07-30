import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:expense_tracker/screens/income_screen.dart';
import 'package:expense_tracker/screens/budgets_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'package:expense_tracker/screens/accounts_screen.dart';
import 'package:expense_tracker/screens/import_export_screen.dart';
import 'package:expense_tracker/screens/theme_selection_screen.dart';
import 'package:expense_tracker/screens/currency_selection_screen.dart';
import 'package:expense_tracker/screens/backup_restore_screen.dart';
import 'package:expense_tracker/screens/delete_reset_screen.dart';
import 'package:expense_tracker/screens/help_screen.dart';
import 'package:expense_tracker/screens/feedback_screen.dart';
import 'package:expense_tracker/screens/reminder_settings_screen.dart';
import 'package:expense_tracker/screens/loans_screen.dart';
import 'package:expense_tracker/services/theme_provider.dart';
import 'package:expense_tracker/services/currency_provider.dart';
import 'package:expense_tracker/services/reminder_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => ReminderService()),
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
          title: 'Budget Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
              secondary: Colors.orange,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              primary: Colors.blue,
              secondary: Colors.orange,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(
              0xFF2C2C2C,
            ), // Light grey background
            cardColor: const Color(0xFF3A3A3A), // Medium grey cards
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF3A3A3A), // Medium grey app bar
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF3A3A3A), // Medium grey drawer
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF3A3A3A), // Medium grey bottom nav
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF3A3A3A), // Medium grey cards
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            dividerTheme: const DividerThemeData(
              color: Color(0xFF4A4A4A), // Light grey dividers
            ),
            listTileTheme: const ListTileThemeData(
              tileColor: Color(0xFF3A3A3A), // Medium grey list tiles
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
          routes: {
            '/expenses': (context) => const ExpensesScreen(),
            '/income': (context) => const IncomeScreen(),
            '/budgets': (context) => const BudgetsScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/accounts': (context) => const AccountsScreen(),
            '/import-export': (context) => const ImportExportScreen(),
            '/theme': (context) => const ThemeSelectionScreen(),
            '/currency': (context) => const CurrencySelectionScreen(),
            '/backup-restore': (context) => const BackupRestoreScreen(),
            '/delete-reset': (context) => const DeleteResetScreen(),
            '/help': (context) => const HelpScreen(),
            '/feedback': (context) => const FeedbackScreen(),
            '/reminder': (context) => const ReminderSettingsScreen(),
            '/loans': (context) => const LoansScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
