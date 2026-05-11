import 'package:flutter/foundation.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/group.dart';

class AppState extends ChangeNotifier {
  // Basic fields required by tests
  List<Transaction> transactions = [];
  List<Account> accounts = [];
  List<Budget> budgets = [];
  List<Group> groups = [];

  bool isLoading = false;
  bool isLoadingTransactions = false;
  bool isLoadingAccounts = false;
  bool isLoadingBudgets = false;
  bool isLoadingGroups = false;

  String? transactionsError;
  String? accountsError;
  String? budgetsError;
  String? groupsError;

  bool get hasErrors =>
      transactionsError != null ||
      accountsError != null ||
      budgetsError != null ||
      groupsError != null;

  // Helper methods used by tests
  List<Transaction> getExpenses() =>
      transactions.where((t) => t.type.toLowerCase() == 'expense').toList();

  List<Transaction> getIncome() =>
      transactions.where((t) => t.type.toLowerCase() == 'income').toList();

  List<Transaction> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return transactions
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return transactions.where((t) => t.category == category).toList();
  }

  Account? getAccountById(String id) {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Budget? getBudgetById(String id) {
    try {
      return budgets.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Group? getGroupById(String id) {
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearAllErrors() {
    transactionsError = null;
    accountsError = null;
    budgetsError = null;
    groupsError = null;
    notifyListeners();
  }
}


