import 'package:spendwise/models/loan.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/unified_database_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class LoanService {
  static Future<List<Loan>> getLoans() async {
    final result = await UnifiedDatabaseService.getLoans();
    return List<Loan>.from(result);
  }

  static Future<void> addLoan(Loan loan) async {
    await UnifiedDatabaseService.addLoan(loan);
  }

  static Future<void> updateLoan(Loan loan) async {
    await UnifiedDatabaseService.updateLoan(loan);
  }

  static Future<void> deleteLoan(String id) async {
    await UnifiedDatabaseService.deleteLoan(id);
  }

  // New method to add a payment to a loan
  static Future<void> addPayment(String loanId, LoanPayment payment) async {
    final loans = await getLoans();
    final loanIndex = loans.indexWhere((loan) => loan.id == loanId);

    if (loanIndex != -1) {
      final loan = loans[loanIndex];
      final updatedPaymentHistory = List<LoanPayment>.from(loan.paymentHistory)
        ..add(payment);
      final newPaidAmount = loan.paidAmount + payment.amount;

      // Update loan with new payment
      final updatedLoan = loan.copyWith(
        paidAmount: newPaidAmount,
        paymentHistory: updatedPaymentHistory,
        status: newPaidAmount >= loan.amount ? 'repaid' : loan.status,
        nextPaymentDate: _calculateNextPaymentDate(loan),
      );

      await UnifiedDatabaseService.updateLoan(updatedLoan); // Corrected to use UnifiedDatabaseService

      // If auto deduct is enabled, create a transaction
      if (loan.autoDeduct && payment.accountId != null) {
        await _createAutoDeductTransaction(updatedLoan, payment);
      }
    }
  }

  // Method to process automatic deductions
  static Future<void> processAutoDeductions() async {
    final loans = await getLoans();
    final now = DateTime.now();

    for (final loan in loans) {
      if (loan.autoDeduct &&
          loan.status == 'pending' &&
          loan.nextPaymentDate != null &&
          loan.nextPaymentDate!.isBefore(now)) {
        // Check if account has sufficient balance
        if (loan.accountId != null) {
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

          if (account.balance >= loan.nextPaymentAmount) {
            // Create automatic payment
            final payment = LoanPayment(
              amount: loan.nextPaymentAmount,
              date: now,
              notes: 'Automatic deduction',
              accountId: loan.accountId,
            );

            await addPayment(loan.id, payment);
          }
        }
      }
    }
  }

  // Get loans that need attention (overdue, next payment due, etc.)
  static Future<List<Loan>> getLoansNeedingAttention() async {
    final loans = await getLoans();
    final now = DateTime.now();

    return loans.where((loan) {
      // Overdue loans
      if (loan.isOverdue) return true;

      // Next payment due
      if (loan.isNextPaymentDue) return true;

      // Loans with auto deduct enabled and next payment within 7 days
      if (loan.autoDeduct &&
          loan.nextPaymentDate != null &&
          loan.nextPaymentDate!.difference(now).inDays <= 7) {
        return true;
      }

      return false;
    }).toList();
  }

  // Get loan statistics
  static Future<Map<String, dynamic>> getLoanStatistics() async {
    final loans = await getLoans();

    double totalLent = 0;
    double totalBorrowed = 0;
    double totalPaidLent = 0;
    double totalPaidBorrowed = 0;
    int overdueLoans = 0;
    int pendingLoans = 0;

    for (final loan in loans) {
      if (loan.type == 'lent') {
        totalLent += loan.amount;
        totalPaidLent += loan.paidAmount;
      } else {
        totalBorrowed += loan.amount;
        totalPaidBorrowed += loan.paidAmount;
      }

      if (loan.isOverdue) overdueLoans++;
      if (loan.status == 'pending') pendingLoans++;
    }

    return {
      'totalLent': totalLent,
      'totalBorrowed': totalBorrowed,
      'totalPaidLent': totalPaidLent,
      'totalPaidBorrowed': totalPaidBorrowed,
      'overdueLoans': overdueLoans,
      'pendingLoans': pendingLoans,
      'netPosition': totalLent - totalBorrowed,
    };
  }

  // Calculate Monthly Payment (EMI) for formal loans
  static double calculateMonthlyPayment({
    required double principal,
    required double annualInterestRate,
    required int termInMonths,
  }) {
    if (annualInterestRate == 0) {
      return principal / termInMonths;
    }
    final monthlyInterestRate = annualInterestRate / 100 / 12;
    final emi = principal *
        monthlyInterestRate *
        pow(1 + monthlyInterestRate, termInMonths) /
        (pow(1 + monthlyInterestRate, termInMonths) - 1);
    return emi;
  }

  // Generate Amortization Schedule
  static List<Map<String, dynamic>> generateAmortizationSchedule({
    required double principal,
    required double annualInterestRate,
    required int termInMonths,
    DateTime? startDate,
  }) {
    final List<Map<String, dynamic>> schedule = [];
    double remainingBalance = principal;
    final monthlyInterestRate = annualInterestRate / 100 / 12;
    final monthlyPayment = calculateMonthlyPayment(
      principal: principal,
      annualInterestRate: annualInterestRate,
      termInMonths: termInMonths,
    );
    DateTime currentDate = startDate ?? DateTime.now();

    for (int i = 1; i <= termInMonths; i++) {
      final interestPaid = remainingBalance * monthlyInterestRate;
      double principalPaid = monthlyPayment - interestPaid;

      // Adjust last payment to clear remaining balance if it's slightly off
      if (i == termInMonths) {
        principalPaid = remainingBalance;
      }

      remainingBalance -= principalPaid;

      schedule.add({
        'paymentNumber': i,
        'paymentDate': currentDate.toIso8601String(),
        'startingBalance': principal,
        'interestPaid': interestPaid,
        'principalPaid': principalPaid,
        'endingBalance': remainingBalance.clamp(0.0, double.infinity), // Ensure non-negative
      });

      // Move to next month
      currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
    }
    return schedule;
  }

  // Simulate Extra Payments
  static Map<String, dynamic> simulateExtraPayment({
    required double principal,
    required double annualInterestRate,
    required int termInMonths,
    required double extraPaymentAmount,
    String extraPaymentFrequency = 'one-time',
  }) {
    double currentPrincipal = principal;
    int currentTermInMonths = termInMonths;
    double totalOriginalInterest = 0;
    double totalNewInterest = 0;

    final monthlyInterestRate = annualInterestRate / 100 / 12;
    final originalMonthlyPayment = calculateMonthlyPayment(
      principal: principal,
      annualInterestRate: annualInterestRate,
      termInMonths: termInMonths,
    );

    // Calculate original total interest
    totalOriginalInterest = (originalMonthlyPayment * termInMonths) - principal;

    // Simulate payments with extra amount
    for (int i = 1; i <= currentTermInMonths; i++) {
      if (currentPrincipal <= 0) break;

      final interestPaid = currentPrincipal * monthlyInterestRate;
      double principalPaid = originalMonthlyPayment - interestPaid;

      double paymentWithExtra = originalMonthlyPayment;
      if (extraPaymentFrequency == 'monthly') {
        paymentWithExtra += extraPaymentAmount;
      } else if (extraPaymentFrequency == 'one-time' && i == 1) {
        // Apply one-time extra payment only to the first payment
        paymentWithExtra += extraPaymentAmount;
      }

      // Ensure principal paid is not more than remaining principal
      principalPaid = min(principalPaid, currentPrincipal);
      double extraPrincipalPaid = max(0, paymentWithExtra - originalMonthlyPayment);
      extraPrincipalPaid = min(extraPrincipalPaid, currentPrincipal - principalPaid);

      currentPrincipal -= (principalPaid + extraPrincipalPaid);
      totalNewInterest += interestPaid;

      if (currentPrincipal <= 0) {
        currentTermInMonths = i;
        break;
      }
    }

    final totalInterestSaved = totalOriginalInterest - totalNewInterest;
    final newTotalPayments = (originalMonthlyPayment * currentTermInMonths) + (extraPaymentFrequency == 'one-time' ? extraPaymentAmount : 0);
    final originalTotalPayments = originalMonthlyPayment * termInMonths;

    return {
      'newTermInMonths': currentTermInMonths,
      'totalInterestSaved': totalInterestSaved,
      'newTotalPayments': newTotalPayments,
      'originalTotalPayments': originalTotalPayments,
    };
  }

  static DateTime? _calculateNextPaymentDate(Loan loan) {
    if (loan.paymentFrequency == null || loan.paymentFrequency == 'one-time') {
      return null;
    }

    final lastPayment = loan.paymentHistory.isNotEmpty
        ? loan.paymentHistory.last.date
        : loan.date;

    switch (loan.paymentFrequency) {
      case 'monthly':
        return DateTime(
          lastPayment.year,
          lastPayment.month + 1,
          lastPayment.day,
        );
      case 'weekly':
        return lastPayment.add(const Duration(days: 7));
      case 'biweekly':
        return lastPayment.add(const Duration(days: 14));
      case 'quarterly':
        return DateTime(
          lastPayment.year,
          lastPayment.month + 3,
          lastPayment.day,
        );
      case 'yearly':
        return DateTime(
          lastPayment.year + 1,
          lastPayment.month,
          lastPayment.day,
        );
      default:
        return null;
    }
  }

  static Future<void> _createAutoDeductTransaction(
    Loan loan,
    LoanPayment payment,
  ) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: 'Loan Payment - ${loan.person}',
      amount: payment.amount,
      type: loan.type == 'lent' ? 'income' : 'expense',
      category: 'Loan Payment',
      date: payment.date,
      accountId: payment.accountId,
      notes: 'Automatic loan payment deduction',
    );

    await DataService.addTransaction(transaction);
  }
}