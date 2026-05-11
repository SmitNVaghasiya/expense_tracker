import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/loan.dart'; // Added Loan import
import 'package:spendwise/services/unified_database_service.dart';
import 'package:spendwise/services/cache_service.dart';

class OptimizedDataService {
  static final _cache = CacheService();

  static Future<List<Transaction>> getTransactions() async {
    const key = 'transactions_all';
    final cached = _cache.get<List<Transaction>>(key);
    if (cached != null) return cached;
    final result = List<Transaction>.from(await UnifiedDatabaseService.getTransactions());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addTransaction(Transaction transaction) async {
    await UnifiedDatabaseService.addTransaction(transaction);
    _cache.invalidateWhere((k) => k.startsWith('transactions'));
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await UnifiedDatabaseService.updateTransaction(transaction);
    _cache.invalidateWhere((k) => k.startsWith('transactions'));
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
  }

  static Future<void> deleteTransaction(String id) async {
    await UnifiedDatabaseService.deleteTransaction(id);
    _cache.invalidateWhere((k) => k.startsWith('transactions'));
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
  }

  static Future<List<Account>> getAccounts() async {
    const key = 'accounts_all';
    final cached = _cache.get<List<Account>>(key);
    if (cached != null) return cached;
    final result = List<Account>.from(await UnifiedDatabaseService.getAccounts());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addAccount(Account account) async {
    await UnifiedDatabaseService.addAccount(account);
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
  }

  static Future<void> updateAccount(Account account) async {
    await UnifiedDatabaseService.updateAccount(account);
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
  }

  static Future<void> deleteAccount(String id) async {
    await UnifiedDatabaseService.deleteAccount(id);
    _cache.invalidateWhere((k) => k.startsWith('accounts'));
    _cache.invalidateWhere((k) => k.startsWith('transactions'));
  }

  static Future<List<Budget>> getBudgets() async {
    const key = 'budgets_all';
    final cached = _cache.get<List<Budget>>(key);
    if (cached != null) return cached;
    final result = List<Budget>.from(await UnifiedDatabaseService.getBudgets());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addBudget(Budget budget) async {
    await UnifiedDatabaseService.addBudget(budget);
    _cache.invalidateWhere((k) => k.startsWith('budgets'));
  }

  static Future<void> updateBudget(Budget budget) async {
    await UnifiedDatabaseService.updateBudget(budget);
    _cache.invalidateWhere((k) => k.startsWith('budgets'));
  }

  static Future<void> deleteBudget(String id) async {
    await UnifiedDatabaseService.deleteBudget(id);
    _cache.invalidateWhere((k) => k.startsWith('budgets'));
  }

  static Future<List<Category>> getCategories() async {
    const key = 'categories_all';
    final cached = _cache.get<List<Category>>(key);
    if (cached != null) return cached;
    final result = List<Category>.from(await UnifiedDatabaseService.getCategories());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addCategory(Category category) async {
    await UnifiedDatabaseService.addCategory(category);
    _cache.invalidateWhere((k) => k.startsWith('categories'));
  }

  static Future<void> updateCategory(Category category) async {
    await UnifiedDatabaseService.updateCategory(category);
    _cache.invalidateWhere((k) => k.startsWith('categories'));
  }

  static Future<void> deleteCategory(String id) async {
    await UnifiedDatabaseService.deleteCategory(id);
    _cache.invalidateWhere((k) => k.startsWith('categories'));
  }

  static Future<List<Group>> getGroups() async {
    const key = 'groups_all';
    final cached = _cache.get<List<Group>>(key);
    if (cached != null) return cached;
    final result = List<Group>.from(await UnifiedDatabaseService.getGroups());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addGroup(Group group) async {
    await UnifiedDatabaseService.addGroup(group);
    _cache.invalidateWhere((k) => k.startsWith('groups'));
  }

  static Future<void> updateGroup(Group group) async {
    await UnifiedDatabaseService.updateGroup(group);
    _cache.invalidateWhere((k) => k.startsWith('groups'));
  }

  static Future<void> deleteGroup(String id) async {
    await UnifiedDatabaseService.deleteGroup(id);
    _cache.invalidateWhere((k) => k.startsWith('groups'));
  }

  static Future<Map<String, dynamic>> getTransactionSummary() async {
    final transactions = await getTransactions();
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpense += transaction.amount;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': totalIncome - totalExpense,
    };
  }

  // Loan related methods
  static Future<List<Loan>> getLoans() async {
    const key = 'loans_all';
    final cached = _cache.get<List<Loan>>(key);
    if (cached != null) return cached;
    final result = List<Loan>.from(await UnifiedDatabaseService.getLoans());
    _cache.set(key, result);
    return result;
  }

  static Future<void> addLoan(Loan loan) async {
    await UnifiedDatabaseService.addLoan(loan);
    _cache.invalidateWhere((k) => k.startsWith('loans'));
  }

  static Future<void> updateLoan(Loan loan) async {
    await UnifiedDatabaseService.updateLoan(loan);
    _cache.invalidateWhere((k) => k.startsWith('loans'));
  }

  static Future<void> deleteLoan(String id) async {
    await UnifiedDatabaseService.deleteLoan(id);
    _cache.invalidateWhere((k) => k.startsWith('loans'));
  }

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
}
