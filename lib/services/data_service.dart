import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataService {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _groupsKey = 'groups';

  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey) ?? '[]';
    final transactionsList = json.decode(transactionsJson) as List;
    return transactionsList
        .map((item) => Transaction.fromJson(item))
        .toList();
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index =
        transactions.indexWhere((element) => element.id == transaction.id);
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
}