import 'package:flutter/foundation.dart' hide Category; // Hide Category from foundation
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/transaction.dart';
// import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/optimized_data_service.dart';

class OptimizedAppState extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Budget> _budgets = [];
  List<Category> _categories = [];
  List<Group> _groups = [];

  List<Transaction> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<Budget> get budgets => _budgets;
  List<Category> get categories => _categories;
  List<Group> get groups => _groups;

  OptimizedAppState() {
    loadData();
  }

  Future<void> loadData() async {
    _transactions = await OptimizedDataService.getTransactions();
    _accounts = await OptimizedDataService.getAccounts();
    _budgets = await OptimizedDataService.getBudgets();
    _categories = await OptimizedDataService.getCategories();
    _groups = await OptimizedDataService.getGroups();
    notifyListeners();
  }

  Future<bool> addTransaction(Transaction transaction) async {
    // Optimistic: update local state immediately
    _transactions = [transaction, ..._transactions];
    notifyListeners();
    try {
      await OptimizedDataService.addTransaction(transaction);
      // Refresh accounts since balance changed
      _accounts = await OptimizedDataService.getAccounts();
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback on failure
      _transactions = _transactions.where((t) => t.id != transaction.id).toList();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    final oldList = List<Transaction>.from(_transactions);
    _transactions = _transactions.map((t) => t.id == transaction.id ? transaction : t).toList();
    notifyListeners();
    try {
      await OptimizedDataService.updateTransaction(transaction);
      _accounts = await OptimizedDataService.getAccounts();
      notifyListeners();
      return true;
    } catch (e) {
      _transactions = oldList;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    final oldList = List<Transaction>.from(_transactions);
    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
    try {
      await OptimizedDataService.deleteTransaction(id);
      _accounts = await OptimizedDataService.getAccounts();
      notifyListeners();
      return true;
    } catch (e) {
      _transactions = oldList;
      notifyListeners();
      return false;
    }
  }

  Future<void> addAccount(Account account) async {
    await OptimizedDataService.addAccount(account);
    _accounts = await OptimizedDataService.getAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    await OptimizedDataService.updateAccount(account);
    _accounts = await OptimizedDataService.getAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await OptimizedDataService.deleteAccount(id);
    _accounts = await OptimizedDataService.getAccounts();
    _transactions = await OptimizedDataService.getTransactions();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await OptimizedDataService.addBudget(budget);
    _budgets = await OptimizedDataService.getBudgets();
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    await OptimizedDataService.updateBudget(budget);
    _budgets = await OptimizedDataService.getBudgets();
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await OptimizedDataService.deleteBudget(id);
    _budgets = await OptimizedDataService.getBudgets();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await OptimizedDataService.addCategory(category);
    _categories = await OptimizedDataService.getCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await OptimizedDataService.updateCategory(category);
    _categories = await OptimizedDataService.getCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await OptimizedDataService.deleteCategory(id);
    _categories = await OptimizedDataService.getCategories();
    notifyListeners();
  }

  Future<void> addGroup(Group group) async {
    await OptimizedDataService.addGroup(group);
    _groups = await OptimizedDataService.getGroups();
    notifyListeners();
  }

  Future<void> updateGroup(Group group) async {
    await OptimizedDataService.updateGroup(group);
    _groups = await OptimizedDataService.getGroups();
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    await OptimizedDataService.deleteGroup(id);
    _groups = await OptimizedDataService.getGroups();
    notifyListeners();
  }

  // Minimal API expected by screens to avoid undefined_method errors.
  // Uses cached data if already loaded — avoids a redundant full DB reload on every call.
  Future<Map<String, dynamic>> loadEssentialData({
    required String filterPeriod,
    required DateTime selectedDate,
  }) async {
    if (_transactions.isEmpty && _accounts.isEmpty) {
      await loadData();
    }
    return {
      'transactions': _transactions,
      'accounts': _accounts,
      'budgets': _budgets,
    };
  }

  // Optimistic operations — delegate to the main methods which already do this
  Future<bool> addTransactionOptimistically(Transaction transaction) =>
      addTransaction(transaction);

  Future<bool> updateTransactionOptimistically(Transaction transaction) =>
      updateTransaction(transaction);

  Future<bool> deleteTransactionOptimistically(String id) =>
      deleteTransaction(id);
}