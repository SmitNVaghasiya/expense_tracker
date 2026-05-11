import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/unified_database_service.dart';
import 'package:spendwise/models/loan.dart';

class DataService {
  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    try {
      final dynamic result = await UnifiedDatabaseService.getTransactions();
      return List<Transaction>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final db = await UnifiedDatabaseService.database;
    await db.transaction((txn) async {
      await txn.insert(
        'transactions',
        transaction.toJson(),
      );

      if (transaction.type == 'transfer') {
        if (transaction.accountId == null || transaction.toAccountId == null) {
          throw Exception('Transfer must have a from and to account.');
        }
        await UnifiedDatabaseService.transferAmount(
          fromAccountId: transaction.accountId!,
          toAccountId: transaction.toAccountId!,
          amount: transaction.amount,
          db: txn,
        );
      } else {
        if (transaction.accountId != null) {
          await UnifiedDatabaseService.updateAccountBalanceDirect(
            accountId: transaction.accountId!,
            amount: transaction.amount,
            transactionType: transaction.type,
            db: txn,
          );
        }
      }
    });
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final db = await UnifiedDatabaseService.database;
    await db.transaction((txn) async {
      // Get the old transaction to calculate balance difference
      final oldTransactionMap = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (oldTransactionMap.isEmpty) {
        throw Exception('Transaction not found for update');
      }

      final oldTransaction = Transaction.fromJson(oldTransactionMap.first);

      // Revert the old transaction effect
      if (oldTransaction.type == 'transfer') {
        if (oldTransaction.accountId != null &&
            oldTransaction.toAccountId != null) {
          await UnifiedDatabaseService.transferAmount(
            fromAccountId: oldTransaction.toAccountId!,
            toAccountId: oldTransaction.accountId!,
            amount: oldTransaction.amount,
            db: txn,
          );
        }
      } else {
        if (oldTransaction.accountId != null) {
          await UnifiedDatabaseService.updateAccountBalanceDirect(
            accountId: oldTransaction.accountId!,
            amount: oldTransaction.amount,
            transactionType: oldTransaction.type == 'income' ? 'expense' : 'income', // Reverse type
            db: txn,
          );
        }
      }

      // Apply the new transaction effect
      if (transaction.type == 'transfer') {
        if (transaction.accountId == null || transaction.toAccountId == null) {
          throw Exception('Transfer must have a from and to account.');
        }
        await UnifiedDatabaseService.transferAmount(
          fromAccountId: transaction.accountId!,
          toAccountId: transaction.toAccountId!,
          amount: transaction.amount,
          db: txn,
        );
      } else {
        if (transaction.accountId != null) {
          await UnifiedDatabaseService.updateAccountBalanceDirect(
            accountId: transaction.accountId!,
            amount: transaction.amount,
            transactionType: transaction.type,
            db: txn,
          );
        }
      }

      // Finally, update the transaction record itself
      await txn.update(
        'transactions',
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    });
  }

  static Future<void> deleteTransaction(String id) async {
    final db = await UnifiedDatabaseService.database;
    await db.transaction((txn) async {
      final transactions = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (transactions.isEmpty) {
        return; // Transaction already deleted
      }

      final transactionToDelete = Transaction.fromJson(transactions.first);

      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);

      if (transactionToDelete.type == 'transfer') {
        if (transactionToDelete.accountId != null &&
            transactionToDelete.toAccountId != null) {
          await UnifiedDatabaseService.transferAmount(
            fromAccountId: transactionToDelete.toAccountId!,
            toAccountId: transactionToDelete.accountId!,
            amount: transactionToDelete.amount,
            db: txn,
          );
        }
      } else {
        if (transactionToDelete.accountId != null) {
          await UnifiedDatabaseService.updateAccountBalanceDirect(
            accountId: transactionToDelete.accountId!,
            amount: transactionToDelete.amount,
            transactionType:
                transactionToDelete.type == 'income' ? 'expense' : 'income', // Reverse type
            db: txn,
          );
        }
      }
    });
  }

  // Budget methods
  static Future<List<Budget>> getBudgets() async {
    try {
      final result = await UnifiedDatabaseService.getBudgets();
      return List<Budget>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addBudget(Budget budget) async {
    try {
      await UnifiedDatabaseService.addBudget(budget);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateBudget(Budget budget) async {
    try {
      await UnifiedDatabaseService.updateBudget(budget);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteBudget(String id) async {
    try {
      await UnifiedDatabaseService.deleteBudget(id);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Overall Budget methods
  static Future<List<OverallBudget>> getOverallBudgets() async {
    try {
      final result = await UnifiedDatabaseService.getOverallBudgets();
      return List<OverallBudget>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addOverallBudget(OverallBudget budget) async {
    try {
      await UnifiedDatabaseService.addOverallBudget(budget);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateOverallBudget(OverallBudget budget) async {
    try {
      await UnifiedDatabaseService.updateOverallBudget(budget);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteOverallBudget(String id) async {
    try {
      await UnifiedDatabaseService.deleteOverallBudget(id);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Group methods
  static Future<List<Group>> getGroups() async {
    try {
      final result = await UnifiedDatabaseService.getGroups();
      return List<Group>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addGroup(Group group) async {
    try {
      await UnifiedDatabaseService.addGroup(group);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateGroup(Group group) async {
    try {
      await UnifiedDatabaseService.updateGroup(group);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteGroup(String id) async {
    try {
      await UnifiedDatabaseService.deleteGroup(id);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Account methods
  static Future<List<Account>> getAccounts() async {
    try {
      final result = await UnifiedDatabaseService.getAccounts();
      return List<Account>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addAccount(Account account) async {
    try {
      await UnifiedDatabaseService.addAccount(account);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateAccount(Account account) async {
    try {
      await UnifiedDatabaseService.updateAccount(account);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteAccount(String id) async {
    final db = await UnifiedDatabaseService.database;
    await db.transaction((txn) async {
      // Delete all transactions for this account
      await txn.delete('transactions', where: 'accountId = ? OR toAccountId = ?', whereArgs: [id]);

      // Delete the account
      await txn.delete('accounts', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      await UnifiedDatabaseService.clearAllData();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Clear specific data types
  static Future<void> clearAllTransactions() async {
    try {
      await UnifiedDatabaseService.clearAllTransactions();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllBudgets() async {
    try {
      await UnifiedDatabaseService.clearAllBudgets();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllAccounts() async {
    try {
      await UnifiedDatabaseService.clearAllAccounts();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> clearAllGroups() async {
    try {
      await UnifiedDatabaseService.clearAllGroups();
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Get account name by ID
  static Future<String> getAccountNameById(String accountId) async {
    try {
      final accounts = await getAccounts();
      final account = accounts.firstWhere(
        (account) => account.id == accountId,
        orElse: () => Account(
          id: '',
          name: 'Unknown Account',
          balance: 0,
          type: '',
          createdAt: DateTime.now(),
        ),
      );
      return account.name;
    } catch (e) {
      // Error logged
      return 'Unknown Account';
    }
  }

  // Category methods
  static Future<List<Category>> getCategories() async {
    try {
      final result = await UnifiedDatabaseService.getCategories();
      return List<Category>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<List<Category>> getCategoriesByType(String type) async {
    try {
      final categories = await getCategories();
      return categories.where((category) => category.type == type).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addCategory(Category category) async {
    try {
      await UnifiedDatabaseService.addCategory(category);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateCategory(Category category) async {
    try {
      await UnifiedDatabaseService.updateCategory(category);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      await UnifiedDatabaseService.deleteCategory(id);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Loan methods
  static Future<List<Loan>> getLoans() async {
    try {
      final result = await UnifiedDatabaseService.getLoans();
      return List<Loan>.from(result);
    } catch (e) {
      // Error logged
      return [];
    }
  }

  static Future<void> addLoan(Loan loan) async {
    try {
      await UnifiedDatabaseService.addLoan(loan);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> updateLoan(Loan loan) async {
    try {
      await UnifiedDatabaseService.updateLoan(loan);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  static Future<void> deleteLoan(String id) async {
    try {
      await UnifiedDatabaseService.deleteLoan(id);
    } catch (e) {
      // Error logged
      rethrow;
    }
  }
}
