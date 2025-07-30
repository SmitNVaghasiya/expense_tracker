import 'package:expense_tracker/models/loan.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class LoanService {
  static const String _loansKey = 'loans';

  static Future<List<Loan>> getLoans() async {
    final prefs = await SharedPreferences.getInstance();
    final loansJson = prefs.getString(_loansKey) ?? '[]';
    final loansList = json.decode(loansJson) as List;
    return loansList.map((item) => Loan.fromJson(item)).toList();
  }

  static Future<void> addLoan(Loan loan) async {
    final loans = await getLoans();
    loans.add(loan);
    await _saveLoans(loans);
  }

  static Future<void> updateLoan(Loan loan) async {
    final loans = await getLoans();
    final index = loans.indexWhere((element) => element.id == loan.id);
    if (index != -1) {
      loans[index] = loan;
      await _saveLoans(loans);
    }
  }

  static Future<void> deleteLoan(String id) async {
    final loans = await getLoans();
    loans.removeWhere((element) => element.id == id);
    await _saveLoans(loans);
  }

  // New method to add a payment to a loan
  static Future<void> addPayment(String loanId, LoanPayment payment) async {
    final loans = await getLoans();
    final loanIndex = loans.indexWhere((loan) => loan.id == loanId);
    
    if (loanIndex != -1) {
      final loan = loans[loanIndex];
      final updatedPaymentHistory = List<LoanPayment>.from(loan.paymentHistory)..add(payment);
      final newPaidAmount = loan.paidAmount + payment.amount;
      
      // Update loan with new payment
      final updatedLoan = loan.copyWith(
        paidAmount: newPaidAmount,
        paymentHistory: updatedPaymentHistory,
        status: newPaidAmount >= loan.amount ? 'repaid' : loan.status,
        nextPaymentDate: _calculateNextPaymentDate(loan),
      );
      
      loans[loanIndex] = updatedLoan;
      await _saveLoans(loans);
      
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
            orElse: () => Account(id: '', name: '', balance: 0, type: '', createdAt: DateTime.now()),
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

  static Future<void> _saveLoans(List<Loan> loans) async {
    final prefs = await SharedPreferences.getInstance();
    final loansJson = json.encode(
      loans.map((loan) => loan.toJson()).toList(),
    );
    await prefs.setString(_loansKey, loansJson);
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
        return DateTime(lastPayment.year, lastPayment.month + 1, loan.paymentDay ?? lastPayment.day);
      case 'weekly':
        return lastPayment.add(const Duration(days: 7));
      case 'biweekly':
        return lastPayment.add(const Duration(days: 14));
      case 'quarterly':
        return DateTime(lastPayment.year, lastPayment.month + 3, loan.paymentDay ?? lastPayment.day);
      case 'yearly':
        return DateTime(lastPayment.year + 1, lastPayment.month, loan.paymentDay ?? lastPayment.day);
      default:
        return null;
    }
  }

  static Future<void> _createAutoDeductTransaction(Loan loan, LoanPayment payment) async {
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