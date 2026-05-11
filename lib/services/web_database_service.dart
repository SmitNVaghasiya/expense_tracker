import 'dart:convert';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/category.dart' as models;
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/services/storage_service.dart';

class WebDatabaseService {
  static const String _transactionsKey = 'transactions';
  static const String _accountsKey = 'accounts';
  static const String _budgetsKey = 'budgets';
  static const String _overallBudgetsKey = 'overall_budgets';
  static const String _categoriesKey = 'categories';
  static const String _groupsKey = 'groups';
  static const String _loansKey = 'loans';

  static Future<void> initialize() async {
    await StorageService.initialize();

    // Initialize default categories if they don't exist
    final categories = await getCategories();
    if (categories.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      models.Category(
        id: '1',
        name: 'Food & Dining',
        type: 'expense',
        color: '#FF6B6B',
        icon: '🍽️',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '2',
        name: 'Transportation',
        type: 'expense',
        color: '#4ECDC4',
        icon: '🚗',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '3',
        name: 'Shopping',
        type: 'expense',
        color: '#45B7D1',
        icon: '🛍️',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '4',
        name: 'Entertainment',
        type: 'expense',
        color: '#96CEB4',
        icon: '🎬',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '5',
        name: 'Healthcare',
        type: 'expense',
        color: '#FFEAA7',
        icon: '🏥',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '6',
        name: 'Education',
        type: 'expense',
        color: '#DDA0DD',
        icon: '📚',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '7',
        name: 'Utilities',
        type: 'expense',
        color: '#98D8C8',
        icon: '💡',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '8',
        name: 'Housing',
        type: 'expense',
        color: '#F7DC6F',
        icon: '🏠',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '9',
        name: 'Income',
        type: 'income',
        color: '#BB8FCE',
        icon: '💰',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      models.Category(
        id: '10',
        name: 'Other',
        type: 'expense',
        color: '#85C1E9',
        icon: '📌',
        createdAt: DateTime.now(),
        isDefault: true,
      ),
    ];

    for (final category in defaultCategories) {
      await addCategory(category);
    }
  }

  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    try {
      final data = await StorageService.getData(_transactionsKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addTransaction(Transaction transaction) async {
    try {
      final transactions = await getTransactions();
      transactions.add(transaction);
      await StorageService.saveData(
        _transactionsKey,
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    try {
      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        transactions[index] = transaction;
        await StorageService.saveData(
          _transactionsKey,
          jsonEncode(transactions.map((t) => t.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    try {
      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == id);
      await StorageService.saveData(
        _transactionsKey,
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Account methods
  static Future<List<Account>> getAccounts() async {
    try {
      final data = await StorageService.getData(_accountsKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Account.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addAccount(Account account) async {
    try {
      final accounts = await getAccounts();
      accounts.add(account);
      await StorageService.saveData(
        _accountsKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateAccount(Account account) async {
    try {
      final accounts = await getAccounts();
      final index = accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        accounts[index] = account;
        await StorageService.saveData(
          _accountsKey,
          jsonEncode(accounts.map((a) => a.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteAccount(String id) async {
    try {
      final accounts = await getAccounts();
      accounts.removeWhere((a) => a.id == id);
      await StorageService.saveData(
        _accountsKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Category methods
  static Future<List<models.Category>> getCategories() async {
    try {
      final data = await StorageService.getData(_categoriesKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => models.Category.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addCategory(models.Category category) async {
    try {
      final categories = await getCategories();
      categories.add(category);
      await StorageService.saveData(
        _categoriesKey,
        jsonEncode(categories.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateCategory(models.Category category) async {
    try {
      final categories = await getCategories();
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
        await StorageService.saveData(
          _categoriesKey,
          jsonEncode(categories.map((c) => c.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      final categories = await getCategories();
      categories.removeWhere((c) => c.id == id);
      await StorageService.saveData(
        _categoriesKey,
        jsonEncode(categories.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Budget methods
  static Future<List<Budget>> getBudgets() async {
    try {
      final data = await StorageService.getData(_budgetsKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addBudget(Budget budget) async {
    try {
      final budgets = await getBudgets();
      budgets.add(budget);
      await StorageService.saveData(
        _budgetsKey,
        jsonEncode(budgets.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateBudget(Budget budget) async {
    try {
      final budgets = await getBudgets();
      final index = budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        budgets[index] = budget;
        await StorageService.saveData(
          _budgetsKey,
          jsonEncode(budgets.map((b) => b.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteBudget(String id) async {
    try {
      final budgets = await getBudgets();
      budgets.removeWhere((b) => b.id == id);
      await StorageService.saveData(
        _budgetsKey,
        jsonEncode(budgets.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Overall Budget methods
  static Future<List<OverallBudget>> getOverallBudgets() async {
    try {
      final data = await StorageService.getData(_overallBudgetsKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => OverallBudget.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addOverallBudget(OverallBudget budget) async {
    try {
      final budgets = await getOverallBudgets();
      budgets.add(budget);
      await StorageService.saveData(
        _overallBudgetsKey,
        jsonEncode(budgets.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateOverallBudget(OverallBudget budget) async {
    try {
      final budgets = await getOverallBudgets();
      final index = budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        budgets[index] = budget;
        await StorageService.saveData(
          _overallBudgetsKey,
          jsonEncode(budgets.map((b) => b.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteOverallBudget(String id) async {
    try {
      final budgets = await getOverallBudgets();
      budgets.removeWhere((b) => b.id == id);
      await StorageService.saveData(
        _overallBudgetsKey,
        jsonEncode(budgets.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Group methods
  static Future<List<Group>> getGroups() async {
    try {
      final data = await StorageService.getData(_groupsKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Group.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addGroup(Group group) async {
    try {
      final groups = await getGroups();
      groups.add(group);
      await StorageService.saveData(
        _groupsKey,
        jsonEncode(groups.map((g) => g.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateGroup(Group group) async {
    try {
      final groups = await getGroups();
      final index = groups.indexWhere((g) => g.id == group.id);
      if (index != -1) {
        groups[index] = group;
        await StorageService.saveData(
          _groupsKey,
          jsonEncode(groups.map((g) => g.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteGroup(String id) async {
    try {
      final groups = await getGroups();
      groups.removeWhere((g) => g.id == id);
      await StorageService.saveData(
        _groupsKey,
        jsonEncode(groups.map((g) => g.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Loan methods
  static Future<List<Loan>> getLoans() async {
    try {
      final data = await StorageService.getData(_loansKey);
      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Loan.fromJson(json)).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addLoan(Loan loan) async {
    try {
      final loans = await getLoans();
      loans.add(loan);
      await StorageService.saveData(
        _loansKey,
        jsonEncode(loans.map((l) => l.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateLoan(Loan loan) async {
    try {
      final loans = await getLoans();
      final index = loans.indexWhere((l) => l.id == loan.id);
      if (index != -1) {
        loans[index] = loan;
        await StorageService.saveData(
          _loansKey,
          jsonEncode(loans.map((l) => l.toJson()).toList()),
        );
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteLoan(String id) async {
    try {
      final loans = await getLoans();
      loans.removeWhere((l) => l.id == id);
      await StorageService.saveData(
        _loansKey,
        jsonEncode(loans.map((l) => l.toJson()).toList()),
      );
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      await StorageService.clearAll();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Clear specific data types
  static Future<void> clearAllTransactions() async {
    try {
      await StorageService.saveData(_transactionsKey, '[]');
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllBudgets() async {
    try {
      await StorageService.saveData(_budgetsKey, '[]');
      await StorageService.saveData(_overallBudgetsKey, '[]');
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllAccounts() async {
    try {
      await StorageService.saveData(_accountsKey, '[]');
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllGroups() async {
    try {
      await StorageService.saveData(_groupsKey, '[]');
    } catch (e) {
      // Error logged
      rethrow;
    }
  }
}
