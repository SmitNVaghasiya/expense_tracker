import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'SpendWise';
  static const String appVersion = '1.0.0';
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
}

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color accent = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF3A3A3A);
  static const Color darkDivider = Color(0xFF4A4A4A);
}

class AppRoutes {
  // Main routes
  static const String home = '/';
  static const String dashboard = '/dashboard';

  // Transaction routes
  static const String expenses = '/expenses';
  static const String income = '/income';
  static const String recurringTransactions = '/recurring-transactions';
  static const String calculatorTransaction = '/calculator-transaction';

  // Financial routes
  static const String accounts = '/accounts';
  static const String budgets = '/budgets';
  static const String financialGoals = '/financial-goals';
  static const String loans = '/loans';
  static const String addLoan = '/add-loan';

  // Reminder routes
  static const String billReminders = '/bill-reminders';
  static const String reminderSettings = '/reminder-settings';
  static const String loanReminderSettings = '/loan-reminder-settings';

  // Other routes
  static const String reports = '/reports';
  static const String themeSelection = '/theme';
  static const String currencySelection = '/currency';
  static const String backupRestore = '/backup-restore';
  static const String importExport = '/import-export';
  static const String deleteReset = '/delete-reset';
  static const String help = '/help';
  static const String feedback = '/feedback';
}

class AppStrings {
  // Common actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String close = 'Close';

  // Transaction types
  static const String expense = 'expense';
  static const String income = 'income';

  // Loan types
  static const String lent = 'lent';
  static const String borrowed = 'borrowed';

  // Status
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String overdue = 'overdue';
  static const String repaid = 'repaid';
}

class AppDimensions {
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  static const double buttonHeight = 48.0;
  static const double buttonRadius = 8.0;

  static const double cardRadius = 12.0;
  static const double cardElevation = 2.0;

  static const double inputRadius = 8.0;
  static const double inputHeight = 48.0;
}
