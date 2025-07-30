import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/group.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataService {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _groupsKey = 'groups';
  static const String _accountsKey = 'accounts';

  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey) ?? '[]';
    final transactionsList = json.decode(transactionsJson) as List;
    return transactionsList.map((item) => Transaction.fromJson(item)).toList();
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere(
      (element) => element.id == transaction.id,
    );
    if (index != -1) {
      transactions[index] = transaction;
      await _saveTransactions(transactions);
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((element) => element.id == id);
    await _saveTransactions(transactions);
  }

  static Future<void> _saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = json.encode(
      transactions.map((transaction) => transaction.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, transactionsJson);
  }

  // Budget methods
  static Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey) ?? '[]';
    final budgetsList = json.decode(budgetsJson) as List;
    return budgetsList.map((item) => Budget.fromJson(item)).toList();
  }

  static Future<void> addBudget(Budget budget) async {
    final budgets = await getBudgets();
    budgets.add(budget);
    await _saveBudgets(budgets);
  }

  static Future<void> updateBudget(Budget budget) async {
    final budgets = await getBudgets();
    final index = budgets.indexWhere((element) => element.id == budget.id);
    if (index != -1) {
      budgets[index] = budget;
      await _saveBudgets(budgets);
    }
  }

  static Future<void> deleteBudget(String id) async {
    final budgets = await getBudgets();
    budgets.removeWhere((element) => element.id == id);
    await _saveBudgets(budgets);
  }

  static Future<void> _saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = json.encode(
      budgets.map((budget) => budget.toJson()).toList(),
    );
    await prefs.setString(_budgetsKey, budgetsJson);
  }

  // Group methods
  static Future<List<Group>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getString(_groupsKey) ?? '[]';
    final groupsList = json.decode(groupsJson) as List;
    return groupsList.map((item) => Group.fromJson(item)).toList();
  }

  static Future<void> addGroup(Group group) async {
    final groups = await getGroups();
    groups.add(group);
    await _saveGroups(groups);
  }

  static Future<void> updateGroup(Group group) async {
    final groups = await getGroups();
    final index = groups.indexWhere((element) => element.id == group.id);
    if (index != -1) {
      groups[index] = group;
      await _saveGroups(groups);
    }
  }

  static Future<void> deleteGroup(String id) async {
    final groups = await getGroups();
    groups.removeWhere((element) => element.id == id);
    await _saveGroups(groups);
  }

  static Future<void> _saveGroups(List<Group> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = json.encode(
      groups.map((group) => group.toJson()).toList(),
    );
    await prefs.setString(_groupsKey, groupsJson);
  }

  // Account methods
  static Future<List<Account>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString(_accountsKey) ?? '[]';
    final accountsList = json.decode(accountsJson) as List;
    return accountsList.map((item) => Account.fromJson(item)).toList();
  }

  static Future<void> addAccount(Account account) async {
    final accounts = await getAccounts();
    accounts.add(account);
    await _saveAccounts(accounts);
  }

  static Future<void> updateAccount(Account account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((element) => element.id == account.id);
    if (index != -1) {
      accounts[index] = account;
      await _saveAccounts(accounts);
    }
  }

  static Future<void> deleteAccount(String id) async {
    final accounts = await getAccounts();
    accounts.removeWhere((element) => element.id == id);
    await _saveAccounts(accounts);
  }

  static Future<void> _saveAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = json.encode(
      accounts.map((account) => account.toJson()).toList(),
    );
    await prefs.setString(_accountsKey, accountsJson);
  }

  // Helper method to update account balance when transaction is added
  static Future<void> updateAccountBalance(
    String accountId,
    double amount,
    String transactionType,
  ) async {
    final accounts = await getAccounts();
    final accountIndex = accounts.indexWhere(
      (account) => account.id == accountId,
    );

    if (accountIndex != -1) {
      final account = accounts[accountIndex];
      double newBalance = account.balance;

      if (transactionType == 'income') {
        newBalance += amount;
      } else if (transactionType == 'expense') {
        newBalance -= amount;
      }

      accounts[accountIndex] = account.copyWith(balance: newBalance);
      await _saveAccounts(accounts);
    }
  }

  static Future<String> getAccountNameById(String accountId) async {
    final accounts = await getAccounts();
    final account = accounts.firstWhere(
      (account) => account.id == accountId,
      orElse: () => Account(
        id: accountId,
        name: 'Unknown Account',
        balance: 0,
        type: 'unknown',
        createdAt: DateTime.now(),
      ),
    );
    return account.name;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_groupsKey);
    await prefs.remove(_accountsKey);
  }

  // Clear specific data types
  static Future<void> clearAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
  }

  static Future<void> clearAllBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_budgetsKey);
  }

  static Future<void> clearAllAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
  }

  static Future<void> clearAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_groupsKey);
  }
}
