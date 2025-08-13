import 'package:spendwise/models/loan.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanReminderService {
  static const String _reminderEnabledKey = 'loan_reminder_enabled';
  static const String _autoDeductEnabledKey = 'loan_auto_deduct_enabled';
  static const String _reminderAdvanceDaysKey = 'loan_reminder_advance_days';

  // Check for loans that need attention
  static Future<List<Map<String, dynamic>>> getLoanAlerts() async {
    final loans = await LoanService.getLoans();
    final now = DateTime.now();
    final List<Map<String, dynamic>> alerts = [];

    for (final loan in loans) {
      if (loan.status == 'pending') {
        // Overdue loans
        if (loan.dueDate != null && loan.dueDate!.isBefore(now)) {
          alerts.add({
            'type': 'overdue',
            'loan': loan,
            'title': 'Loan Overdue',
            'message':
                '${loan.person} loan is overdue by ${now.difference(loan.dueDate!).inDays} days.',
            'severity': 'high',
            'daysOverdue': now.difference(loan.dueDate!).inDays,
          });
        }

        // Due soon loans
        if (loan.dueDate != null &&
            loan.dueDate!.isAfter(now) &&
            loan.dueDate!.difference(now).inDays <= 7) {
          alerts.add({
            'type': 'due_soon',
            'loan': loan,
            'title': 'Loan Due Soon',
            'message':
                '${loan.person} loan is due in ${loan.dueDate!.difference(now).inDays} days.',
            'severity': 'medium',
            'daysUntilDue': loan.dueDate!.difference(now).inDays,
          });
        }

        // Next payment due
        if (loan.nextPaymentDate != null &&
            loan.nextPaymentDate!.isBefore(now)) {
          alerts.add({
            'type': 'payment_due',
            'loan': loan,
            'title': 'Payment Due',
            'message':
                'Next payment of ₹${loan.nextPaymentAmount.toStringAsFixed(2)} is due for ${loan.person}.',
            'severity': 'medium',
            'amount': loan.nextPaymentAmount,
          });
        }

        // Auto-deduction failed
        if (loan.autoDeduct && loan.accountId != null) {
          final accounts = await DataService.getAccounts();
          final account = accounts.firstWhere(
            (acc) => acc.id == loan.accountId,
            orElse: () => Account(
              id: '',
              name: '',
              balance: 0,
              type: '',
              createdAt: DateTime.now(),
            ),
          );

          if (account.balance < (loan.nextPaymentAmount ?? 0)) {
            alerts.add({
              'type': 'auto_deduct_failed',
              'loan': loan,
              'title': 'Auto-Deduction Failed',
              'message':
                  'Insufficient balance for auto-deduction of ₹${loan.nextPaymentAmount.toStringAsFixed(2)}.',
              'severity': 'high',
              'requiredAmount': loan.nextPaymentAmount,
              'availableBalance': account.balance,
            });
          }
        }
      }
    }

    return alerts;
  }

  // Process automatic deductions
  static Future<List<Map<String, dynamic>>> processAutoDeductions() async {
    final loans = await LoanService.getLoans();
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = [];

    for (final loan in loans) {
      if (loan.autoDeduct &&
          loan.status == 'pending' &&
          loan.nextPaymentDate != null &&
          loan.nextPaymentDate!.isBefore(now) &&
          loan.accountId != null) {
        final accounts = await DataService.getAccounts();
        final account = accounts.firstWhere(
          (acc) => acc.id == loan.accountId,
          orElse: () => Account(
            id: '',
            name: '',
            balance: 0,
            type: '',
            createdAt: DateTime.now(),
          ),
        );

        if (account.balance >= (loan.nextPaymentAmount ?? 0)) {
          try {
            // Create automatic payment
            final payment = LoanPayment(
              amount: loan.nextPaymentAmount ?? 0,
              date: now,
              notes: 'Automatic deduction',
              accountId: loan.accountId,
            );

            await LoanService.addPayment(loan.id, payment);

            results.add({
              'loan': loan,
              'status': 'success',
              'message': 'Auto-deduction successful for ${loan.person}',
              'amount': payment.amount,
            });
          } catch (e) {
            results.add({
              'loan': loan,
              'status': 'error',
              'message': 'Auto-deduction failed: $e',
            });
          }
        } else {
          results.add({
            'loan': loan,
            'status': 'insufficient_balance',
            'message': 'Insufficient balance for auto-deduction',
            'requiredAmount': loan.nextPaymentAmount,
            'availableBalance': account.balance,
          });
        }
      }
    }

    return results;
  }

  // Get loan statistics
  static Future<Map<String, dynamic>> getLoanStatistics() async {
    final loans = await LoanService.getLoans();
    final now = DateTime.now();

    double totalLent = 0;
    double totalBorrowed = 0;
    double totalRepaid = 0;
    double totalRemaining = 0;
    int overdueLoans = 0;
    int dueSoonLoans = 0;

    for (final loan in loans) {
      if (loan.type == 'lent') {
        totalLent += loan.amount;
      } else {
        totalBorrowed += loan.amount;
      }

      totalRepaid += loan.paidAmount;
      totalRemaining += loan.remainingAmount;

      if (loan.status == 'pending') {
        if (loan.dueDate != null && loan.dueDate!.isBefore(now)) {
          overdueLoans++;
        } else if (loan.dueDate != null &&
            loan.dueDate!.isAfter(now) &&
            loan.dueDate!.difference(now).inDays <= 7) {
          dueSoonLoans++;
        }
      }
    }

    return {
      'totalLent': totalLent,
      'totalBorrowed': totalBorrowed,
      'totalRepaid': totalRepaid,
      'totalRemaining': totalRemaining,
      'overdueLoans': overdueLoans,
      'dueSoonLoans': dueSoonLoans,
      'totalLoans': loans.length,
      'activeLoans': loans.where((loan) => loan.status == 'pending').length,
    };
  }

  // Get reminder settings
  static Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'reminderEnabled': prefs.getBool(_reminderEnabledKey) ?? true,
      'autoDeductEnabled': prefs.getBool(_autoDeductEnabledKey) ?? false,
      'reminderAdvanceDays': prefs.getInt(_reminderAdvanceDaysKey) ?? 3,
    };
  }

  // Update reminder settings
  static Future<void> updateReminderSettings({
    bool? reminderEnabled,
    bool? autoDeductEnabled,
    int? reminderAdvanceDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (reminderEnabled != null) {
      await prefs.setBool(_reminderEnabledKey, reminderEnabled);
    }
    if (autoDeductEnabled != null) {
      await prefs.setBool(_autoDeductEnabledKey, autoDeductEnabled);
    }
    if (reminderAdvanceDays != null) {
      await prefs.setInt(_reminderAdvanceDaysKey, reminderAdvanceDays);
    }
  }

  // Get upcoming payments
  static Future<List<Map<String, dynamic>>> getUpcomingPayments() async {
    final loans = await LoanService.getLoans();
    final now = DateTime.now();
    final List<Map<String, dynamic>> upcomingPayments = [];

    for (final loan in loans) {
      if (loan.status == 'pending' && loan.nextPaymentDate != null) {
        final daysUntilPayment = loan.nextPaymentDate!.difference(now).inDays;

        if (daysUntilPayment >= 0 && daysUntilPayment <= 30) {
          upcomingPayments.add({
            'loan': loan,
            'daysUntilPayment': daysUntilPayment,
            'amount': loan.nextPaymentAmount,
            'isOverdue': daysUntilPayment < 0,
          });
        }
      }
    }

    // Sort by payment date
    upcomingPayments.sort(
      (a, b) => a['daysUntilPayment'].compareTo(b['daysUntilPayment']),
    );

    return upcomingPayments;
  }
}
