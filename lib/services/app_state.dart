import 'package:flutter/foundation.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/error_service.dart';

class AppState extends ChangeNotifier {
  // Data lists
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Budget> _budgets = [];
  List<OverallBudget> _overallBudgets = [];
  List<Group> _groups = [];

  // Loading states
  bool _isLoadingTransactions = false;
  bool _isLoadingAccounts = false;
  bool _isLoadingBudgets = false;
  bool _isLoadingOverallBudgets = false;
  bool _isLoadingGroups = false;

  // Error states
  String? _transactionsError;
  String? _accountsError;
  String? _budgetsError;
  String? _overallBudgetsError;
  String? _groupsError;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<Budget> get budgets => _budgets;
  List<OverallBudget> get overallBudgets => _overallBudgets;
  List<Group> get groups => _groups;

  // Setters for testing
  set transactions(List<Transaction> value) {
    _transactions = value;
    notifyListeners();
  }

  set accounts(List<Account> value) {
    _accounts = value;
    notifyListeners();
  }

  set budgets(List<Budget> value) {
    _budgets = value;
    notifyListeners();
  }

  set overallBudgets(List<OverallBudget> value) {
    _overallBudgets = value;
    notifyListeners();
  }

  set groups(List<Group> value) {
    _groups = value;
    notifyListeners();
  }

  set transactionsError(String? value) {
    _transactionsError = value;
    notifyListeners();
  }

  set accountsError(String? value) {
    _accountsError = value;
    notifyListeners();
  }

  set budgetsError(String? value) {
    _budgetsError = value;
    notifyListeners();
  }

  set groupsError(String? value) {
    _groupsError = value;
    notifyListeners();
  }

  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isLoadingAccounts => _isLoadingAccounts;
  bool get isLoadingBudgets => _isLoadingBudgets;
  bool get isLoadingOverallBudgets => _isLoadingOverallBudgets;
  bool get isLoadingGroups => _isLoadingGroups;

  String? get transactionsError => _transactionsError;
  String? get accountsError => _accountsError;
  String? get budgetsError => _budgetsError;
  String? get overallBudgetsError => _overallBudgetsError;
  String? get groupsError => _groupsError;

  // Check if any data is loading
  bool get isLoading =>
      _isLoadingTransactions ||
      _isLoadingAccounts ||
      _isLoadingBudgets ||
      _isLoadingOverallBudgets ||
      _isLoadingGroups;

  // Check if there are any errors
  bool get hasErrors =>
      _transactionsError != null ||
      _accountsError != null ||
      _budgetsError != null ||
      _overallBudgetsError != null ||
      _groupsError != null;

  // Get transactions by type
  List<Transaction> getExpenses() {
    return _transactions.where((t) => t.type == 'expense').toList();
  }

  List<Transaction> getIncome() {
    return _transactions.where((t) => t.type == 'income').toList();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get transactions by category
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  // Get account by ID
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get group by ID
  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadTransactions(),
      loadAccounts(),
      loadBudgets(),
      loadOverallBudgets(),
      loadGroups(),
    ]);
  }

  // Load transactions
  Future<void> loadTransactions() async {
    _setTransactionsLoading(true);
    _clearTransactionsError();

    try {
      final transactions = await DataService.getTransactions();
      _transactions = transactions;
      notifyListeners();
    } catch (e, stackTrace) {
      _setTransactionsError('Failed to load transactions: $e');
      ErrorService.logError(
        'Failed to load transactions',
        context: 'AppState.loadTransactions',
        stackTrace: stackTrace,
      );
    } finally {
      _setTransactionsLoading(false);
    }
  }

  // Load accounts
  Future<void> loadAccounts() async {
    _setAccountsLoading(true);
    _clearAccountsError();

    try {
      final accounts = await DataService.getAccounts();
      _accounts = accounts;
      notifyListeners();
    } catch (e, stackTrace) {
      _setAccountsError('Failed to load accounts: $e');
      ErrorService.logError(
        'Failed to load accounts',
        context: 'AppState.loadAccounts',
        stackTrace: stackTrace,
      );
    } finally {
      _setAccountsLoading(false);
    }
  }

  // Load budgets
  Future<void> loadBudgets() async {
    _setBudgetsLoading(true);
    _clearBudgetsError();

    try {
      final budgets = await DataService.getBudgets();
      _budgets = budgets;
      notifyListeners();
    } catch (e, stackTrace) {
      _setBudgetsError('Failed to load budgets: $e');
      ErrorService.logError(
        'Failed to load budgets',
        context: 'AppState.loadBudgets',
        stackTrace: stackTrace,
      );
    } finally {
      _setBudgetsLoading(false);
    }
  }

  // Load overall budgets
  Future<void> loadOverallBudgets() async {
    _setOverallBudgetsLoading(true);
    _clearOverallBudgetsError();

    try {
      final overallBudgets = await DataService.getOverallBudgets();
      _overallBudgets = overallBudgets;
      notifyListeners();
    } catch (e, stackTrace) {
      _setOverallBudgetsError('Failed to load overall budgets: $e');
      ErrorService.logError(
        'Failed to load overall budgets',
        context: 'AppState.loadOverallBudgets',
        stackTrace: stackTrace,
      );
    } finally {
      _setOverallBudgetsLoading(false);
    }
  }

  // Load groups
  Future<void> loadGroups() async {
    _setGroupsLoading(true);
    _clearGroupsError();

    try {
      final groups = await DataService.getGroups();
      _groups = groups;
      notifyListeners();
    } catch (e, stackTrace) {
      _setGroupsError('Failed to load groups: $e');
      ErrorService.logError(
        'Failed to load groups',
        context: 'AppState.loadGroups',
        stackTrace: stackTrace,
      );
    } finally {
      _setGroupsLoading(false);
    }
  }

  // Add transaction
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      // Optimistic update - add to local state immediately
      _transactions.add(transaction);
      notifyListeners();

      // Update account balance optimistically
      if (transaction.accountId != null) {
        final accountIndex = _accounts.indexWhere(
          (a) => a.id == transaction.accountId,
        );
        if (accountIndex != -1) {
          final account = _accounts[accountIndex];
          double newBalance = account.balance;

          if (transaction.type == 'income') {
            newBalance += transaction.amount;
          } else if (transaction.type == 'expense') {
            newBalance -= transaction.amount;
          }

          _accounts[accountIndex] = account.copyWith(balance: newBalance);
          notifyListeners();
        }
      }

      // Perform database operation in background
      await DataService.addTransaction(transaction);
      return true;
    } catch (e, stackTrace) {
      // Rollback optimistic update on error
      _transactions.removeWhere((t) => t.id == transaction.id);

      // Rollback account balance
      if (transaction.accountId != null) {
        final accountIndex = _accounts.indexWhere(
          (a) => a.id == transaction.accountId,
        );
        if (accountIndex != -1) {
          final account = _accounts[accountIndex];
          double newBalance = account.balance;

          if (transaction.type == 'income') {
            newBalance -= transaction.amount;
          } else if (transaction.type == 'expense') {
            newBalance += transaction.amount;
          }

          _accounts[accountIndex] = account.copyWith(balance: newBalance);
        }
      }

      notifyListeners();

      ErrorService.logError(
        'Failed to add transaction',
        context: 'AppState.addTransaction',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Update transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      // Find the old transaction for rollback
      final oldTransactionIndex = _transactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (oldTransactionIndex == -1) return false;

      final oldTransaction = _transactions[oldTransactionIndex];

      // Optimistic update - update local state immediately
      _transactions[oldTransactionIndex] = transaction;
      notifyListeners();

      // Update account balance optimistically
      if (transaction.accountId != null) {
        final accountIndex = _accounts.indexWhere(
          (a) => a.id == transaction.accountId,
        );
        if (accountIndex != -1) {
          final account = _accounts[accountIndex];
          double newBalance = account.balance;

          // Reverse old transaction effect
          if (oldTransaction.type == 'income') {
            newBalance -= oldTransaction.amount;
          } else if (oldTransaction.type == 'expense') {
            newBalance += oldTransaction.amount;
          }

          // Apply new transaction effect
          if (transaction.type == 'income') {
            newBalance += transaction.amount;
          } else if (transaction.type == 'expense') {
            newBalance -= transaction.amount;
          }

          _accounts[accountIndex] = account.copyWith(balance: newBalance);
          notifyListeners();
        }
      }

      // Perform database operation in background
      await DataService.updateTransaction(transaction);
      return true;
    } catch (e, stackTrace) {
      // Rollback optimistic update on error
      await loadTransactions(); // Reload to restore correct state
      await loadAccounts(); // Reload accounts to restore correct balances

      ErrorService.logError(
        'Failed to update transaction',
        context: 'AppState.updateTransaction',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String id) async {
    try {
      // Find the transaction to delete for rollback
      final transactionIndex = _transactions.indexWhere((t) => t.id == id);
      if (transactionIndex == -1) return false;

      final transactionToDelete = _transactions[transactionIndex];

      // Optimistic update - remove from local state immediately
      _transactions.removeAt(transactionIndex);
      notifyListeners();

      // Update account balance optimistically
      if (transactionToDelete.accountId != null) {
        final accountIndex = _accounts.indexWhere(
          (a) => a.id == transactionToDelete.accountId,
        );
        if (accountIndex != -1) {
          final account = _accounts[accountIndex];
          double newBalance = account.balance;

          // Reverse the transaction effect
          if (transactionToDelete.type == 'income') {
            newBalance -= transactionToDelete.amount;
          } else if (transactionToDelete.type == 'expense') {
            newBalance += transactionToDelete.amount;
          }

          _accounts[accountIndex] = account.copyWith(balance: newBalance);
          notifyListeners();
        }
      }

      // Perform database operation in background
      await DataService.deleteTransaction(id);
      return true;
    } catch (e, stackTrace) {
      // Rollback optimistic update on error
      await loadTransactions(); // Reload to restore correct state
      await loadAccounts(); // Reload accounts to restore correct balances

      ErrorService.logError(
        'Failed to delete transaction',
        context: 'AppState.deleteTransaction',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Add account
  Future<bool> addAccount(Account account) async {
    try {
      await DataService.addAccount(account);
      await loadAccounts(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to add account',
        context: 'AppState.addAccount',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Update account
  Future<bool> updateAccount(Account account) async {
    try {
      await DataService.updateAccount(account);
      await loadAccounts(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to update account',
        context: 'AppState.updateAccount',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String id) async {
    try {
      await DataService.deleteAccount(id);
      await loadAccounts(); // Reload to get updated data
      await loadTransactions(); // Also reload transactions as they might be affected
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to delete account',
        context: 'AppState.deleteAccount',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Add budget
  Future<bool> addBudget(Budget budget) async {
    try {
      await DataService.addBudget(budget);
      await loadBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to add budget',
        context: 'AppState.addBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Update budget
  Future<bool> updateBudget(Budget budget) async {
    try {
      await DataService.updateBudget(budget);
      await loadBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to update budget',
        context: 'AppState.updateBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Delete budget
  Future<bool> deleteBudget(String id) async {
    try {
      await DataService.deleteBudget(id);
      await loadBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to delete budget',
        context: 'AppState.deleteBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Add overall budget
  Future<bool> addOverallBudget(OverallBudget budget) async {
    try {
      await DataService.addOverallBudget(budget);
      await loadOverallBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to add overall budget',
        context: 'AppState.addOverallBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Update overall budget
  Future<bool> updateOverallBudget(OverallBudget budget) async {
    try {
      await DataService.updateOverallBudget(budget);
      await loadOverallBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to update overall budget',
        context: 'AppState.updateOverallBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Delete overall budget
  Future<bool> deleteOverallBudget(String id) async {
    try {
      await DataService.deleteOverallBudget(id);
      await loadOverallBudgets(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to delete overall budget',
        context: 'AppState.deleteOverallBudget',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Add group
  Future<bool> addGroup(Group group) async {
    try {
      await DataService.addGroup(group);
      await loadGroups(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to add group',
        context: 'AppState.addGroup',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Update group
  Future<bool> updateGroup(Group group) async {
    try {
      await DataService.updateGroup(group);
      await loadGroups(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to update group',
        context: 'AppState.updateGroup',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Delete group
  Future<bool> deleteGroup(String id) async {
    try {
      await DataService.deleteGroup(id);
      await loadGroups(); // Reload to get updated data
      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to delete group',
        context: 'AppState.deleteGroup',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Clear all errors
  void clearAllErrors() {
    _clearTransactionsError();
    _clearAccountsError();
    _clearBudgetsError();
    _clearGroupsError();
  }

  // Private methods for state management
  void _setTransactionsLoading(bool loading) {
    _isLoadingTransactions = loading;
    notifyListeners();
  }

  void _setAccountsLoading(bool loading) {
    _isLoadingAccounts = loading;
    notifyListeners();
  }

  void _setBudgetsLoading(bool loading) {
    _isLoadingBudgets = loading;
    notifyListeners();
  }

  void _setOverallBudgetsLoading(bool loading) {
    _isLoadingOverallBudgets = loading;
    notifyListeners();
  }

  void _setGroupsLoading(bool loading) {
    _isLoadingGroups = loading;
    notifyListeners();
  }

  void _setTransactionsError(String? error) {
    _transactionsError = error;
    notifyListeners();
  }

  void _setAccountsError(String? error) {
    _accountsError = error;
    notifyListeners();
  }

  void _setBudgetsError(String? error) {
    _budgetsError = error;
    notifyListeners();
  }

  void _setOverallBudgetsError(String? error) {
    _overallBudgetsError = error;
    notifyListeners();
  }

  void _setGroupsError(String? error) {
    _groupsError = error;
    notifyListeners();
  }

  void _clearTransactionsError() {
    _transactionsError = null;
    notifyListeners();
  }

  void _clearAccountsError() {
    _accountsError = null;
    notifyListeners();
  }

  void _clearBudgetsError() {
    _budgetsError = null;
    notifyListeners();
  }

  void _clearOverallBudgetsError() {
    _overallBudgetsError = null;
    notifyListeners();
  }

  void _clearGroupsError() {
    _groupsError = null;
    notifyListeners();
  }
}
