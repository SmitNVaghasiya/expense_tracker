// screens/index.dart
export 'dashboard/optimized_home_screen.dart'; // Updated
export 'financial/accounts_screen.dart';
export 'financial/add_loan_screen.dart' hide StringExtension;
export 'financial/add_payment_dialog.dart';
export 'financial/base_financial_screen.dart';
export 'financial/budgets_screen.dart';
export 'financial/financial_goals_screen.dart';
export 'financial/loans_screen.dart';
export 'financial/loan_details_screen.dart' hide StringExtension; // Added
export 'financial/optimized_budgets_screen.dart';
// export 'financial/personal_transaction_details_screen.dart'; // Removed
export 'reminders/bill_reminders_screen.dart';
export 'reminders/loan_reminder_settings_screen.dart';
export 'reminders/reminder_settings_screen.dart';
export 'reports/reports_screen.dart';
export 'reports/reports_tab_screen.dart';
export 'settings/backup_restore_screen.dart';
export 'settings/currency_selection_screen.dart';
export 'settings/delete_reset_screen.dart';
export 'settings/feedback_screen.dart';
export 'settings/help_screen.dart';
export 'settings/import_export_screen.dart';
export 'settings/theme_selection_screen.dart';
export 'shared/custom_drawer.dart';
export 'transactions/base_transaction_screen.dart' hide StringExtension;
export 'transactions/calculator_transaction_screen.dart';
export 'transactions/expenses_screen.dart';
export 'transactions/income_screen.dart';
export 'transactions/recurring_transactions_screen.dart';