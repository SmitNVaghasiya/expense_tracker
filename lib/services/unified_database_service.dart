import 'package:spendwise/services/database_service.dart';

import 'package:sqflite/sqflite.dart';

class UnifiedDatabaseService {
  static bool _initialized = false;

  static Future<Database> get database async {
    return await DatabaseService.database;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;
  }

  // Transaction methods
  static Future<List<dynamic>> getTransactions() async {
    // Always use mobile database for now to avoid web import issues
    return await DatabaseService.getTransactions();
  }

  static Future<void> addTransaction(dynamic transaction) async {
    await DatabaseService.addTransaction(transaction);
  }

  static Future<void> updateTransaction(dynamic transaction) async {
    await DatabaseService.updateTransaction(transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await DatabaseService.deleteTransaction(id);
  }

  // Account methods
  static Future<List<dynamic>> getAccounts() async {
    return await DatabaseService.getAccounts();
  }

  static Future<void> addAccount(dynamic account) async {
    try {
      await DatabaseService.addAccount(account);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateAccount(dynamic account) async {
    await DatabaseService.updateAccount(account);
  }

  static Future<void> deleteAccount(String id) async {
    await DatabaseService.deleteAccount(id);
  }

  static Future<void> updateAccountBalanceDirect({
    required String accountId,
    required double amount,
    required String transactionType,
    required DatabaseExecutor db,
  }) async {
    await DatabaseService.updateAccountBalanceDirect(
      accountId: accountId,
      amount: amount,
      transactionType: transactionType,
      db: db,
    );
  }

  static Future<void> transferAmount({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DatabaseExecutor db,
  }) async {
    await DatabaseService.transferAmount(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      db: db,
    );
  }

  // Category methods
  static Future<List<dynamic>> getCategories() async {
    return await DatabaseService.getCategories();
  }

  static Future<void> addCategory(dynamic category) async {
    await DatabaseService.addCategory(category);
  }

  static Future<void> updateCategory(dynamic category) async {
    await DatabaseService.updateCategory(category);
  }

  static Future<void> deleteCategory(String id) async {
    await DatabaseService.deleteCategory(id);
  }

  // Budget methods
  static Future<List<dynamic>> getBudgets() async {
    return await DatabaseService.getBudgets();
  }

  static Future<void> addBudget(dynamic budget) async {
    await DatabaseService.addBudget(budget);
  }

  static Future<void> updateBudget(dynamic budget) async {
    await DatabaseService.updateBudget(budget);
  }

  static Future<void> deleteBudget(String id) async {
    await DatabaseService.deleteBudget(id);
  }

  // Overall Budget methods
  static Future<List<dynamic>> getOverallBudgets() async {
    return await DatabaseService.getOverallBudgets();
  }

  static Future<void> addOverallBudget(dynamic budget) async {
    await DatabaseService.addOverallBudget(budget);
  }

  static Future<void> updateOverallBudget(dynamic budget) async {
    await DatabaseService.updateOverallBudget(budget);
  }

  static Future<void> deleteOverallBudget(String id) async {
    await DatabaseService.deleteOverallBudget(id);
  }

  // Group methods
  static Future<List<dynamic>> getGroups() async {
    return await DatabaseService.getGroups();
  }

  static Future<void> addGroup(dynamic group) async {
    await DatabaseService.addGroup(group);
  }

  static Future<void> updateGroup(dynamic group) async {
    await DatabaseService.updateGroup(group);
  }

  static Future<void> deleteGroup(String id) async {
    await DatabaseService.deleteGroup(id);
  }

  // Loan methods
  static Future<List<dynamic>> getLoans() async {
    return await DatabaseService.getLoans();
  }

  static Future<void> addLoan(dynamic loan) async {
    await DatabaseService.addLoan(loan);
  }

  static Future<void> updateLoan(dynamic loan) async {
    await DatabaseService.updateLoan(loan);
  }

  static Future<void> deleteLoan(String id) async {
    await DatabaseService.deleteLoan(id);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
  }

  // Clear specific data types
  static Future<void> clearAllTransactions() async {
    await DatabaseService.clearAllTransactions();
  }

  static Future<void> clearAllBudgets() async {
    await DatabaseService.clearAllBudgets();
  }

  static Future<void> clearAllAccounts() async {
    await DatabaseService.clearAllAccounts();
  }

  static Future<void> clearAllGroups() async {
    await DatabaseService.clearAllGroups();
  }
}
