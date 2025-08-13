import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendwise/screens/index.dart';
import 'package:spendwise/services/index.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await BillReminderService.initializeNotifications();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => ReminderService()),
        ChangeNotifierProvider(create: (context) => AppState()),
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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
              secondary: Colors.orange,
            ),
            useMaterial3: true,
            // Fix pixel issues with better scaling
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // Ensure proper text scaling
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
            // Fix floating action button positioning
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              elevation: 6.0,
              shape: CircleBorder(),
            ),
            // Fix bottom navigation bar
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              type: BottomNavigationBarType.fixed,
              elevation: 8.0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              primary: Colors.blue,
              secondary: Colors.orange,
            ),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xFF2C2C2C),
            cardColor: const Color(0xFF3A3A3A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF3A3A3A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF3A3A3A),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF3A3A3A),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              elevation: 8.0,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF3A3A3A),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            dividerTheme: const DividerThemeData(color: Color(0xFF4A4A4A)),
            listTileTheme: const ListTileThemeData(
              tileColor: Color(0xFF3A3A3A),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              elevation: 6.0,
              shape: CircleBorder(),
            ),
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
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
