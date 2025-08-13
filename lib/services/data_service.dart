import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/database_service.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:convert';

class DataService {
  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    final dynamic result = await DatabaseService.getTransactions();
    return List<Transaction>.from(result);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    // Use a single database connection for all operations
    final db = await DatabaseService.database;
    
    try {
      // Start a transaction for atomicity
      await db.transaction((txn) async {
        // Add transaction to database
        await txn.insert(
          'transactions',
          transaction.toJson(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );

        // Update account balance if account is specified - use direct query instead of fetching all accounts
        if (transaction.accountId != null) {
          await _updateAccountBalanceDirect(txn, transaction.accountId!, transaction.amount, transaction.type);
        }
      });
    } catch (e) {
      // If transaction fails, rethrow the error
      rethrow;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    // Use a single database connection for all operations
    final db = await DatabaseService.database;
    
    try {
      // Start a transaction for atomicity
      await db.transaction((txn) async {
        // Get the old transaction to calculate balance difference
        final oldTransaction = await _getTransactionByIdDirect(txn, transaction.id);

        // Update transaction in database
        await txn.update(
          'transactions',
          transaction.toJson(),
          where: 'id = ?',
          whereArgs: [transaction.id],
        );

        // Update account balance if account is specified
        if (transaction.accountId != null) {
          // Reverse the old transaction effect
          if (oldTransaction != null && oldTransaction.accountId != null) {
            await _updateAccountBalanceDirect(
              txn,
              oldTransaction.accountId!,
              oldTransaction.amount,
              oldTransaction.type,
            );
          }

          // Apply the new transaction effect
          await _updateAccountBalanceDirect(
            txn,
            transaction.accountId!,
            transaction.amount,
            transaction.type,
          );
        }
      });
    } catch (e) {
      // If transaction fails, rethrow the error
      rethrow;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    // Use a single database connection for all operations
    final db = await DatabaseService.database;
    
    try {
      // Start a transaction for atomicity
      await db.transaction((txn) async {
        // Get the transaction being deleted to reverse its effect on account balance
        final transactionToDelete = await _getTransactionByIdDirect(txn, id);

        if (transactionToDelete != null && transactionToDelete.accountId != null) {
          // Update account balance to reverse the transaction
          await _updateAccountBalanceDirect(
            txn,
            transactionToDelete.accountId!,
            transactionToDelete.amount,
            transactionToDelete.type,
          );
        }

        // Delete the transaction from database
        await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
      });
    } catch (e) {
      // If transaction fails, rethrow the error
      rethrow;
    }
  }

  static Future<Transaction?> getTransactionById(String id) async {
    final transactions = await getTransactions();
    try {
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Budget methods
  static Future<List<Budget>> getBudgets() async {
    return await DatabaseService.getBudgets();
  }

  static Future<void> addBudget(Budget budget) async {
    await DatabaseService.addBudget(budget);
  }

  static Future<void> updateBudget(Budget budget) async {
    await DatabaseService.updateBudget(budget);
  }

  static Future<void> deleteBudget(String id) async {
    await DatabaseService.deleteBudget(id);
  }

  // Group methods
  static Future<List<Group>> getGroups() async {
    return await DatabaseService.getGroups();
  }

  static Future<void> addGroup(Group group) async {
    await DatabaseService.addGroup(group);
  }

  static Future<void> updateGroup(Group group) async {
    await DatabaseService.updateGroup(group);
  }

  static Future<void> deleteGroup(String id) async {
    await DatabaseService.deleteGroup(id);
  }

  // Account methods
  static Future<List<Account>> getAccounts() async {
    return await DatabaseService.getAccounts();
  }

  static Future<void> addAccount(Account account) async {
    await DatabaseService.addAccount(account);
  }

  static Future<void> updateAccount(Account account) async {
    await DatabaseService.updateAccount(account);
  }

  static Future<void> deleteAccount(String id) async {
    // Get all transactions for this account
    final transactions = await getTransactions();
    final accountTransactions = transactions
        .where((t) => t.accountId == id)
        .toList();

    // Delete all transactions for this account
    for (final transaction in accountTransactions) {
      await DatabaseService.deleteTransaction(transaction.id);
    }

    // Delete the account
    await DatabaseService.deleteAccount(id);
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

      final updatedAccount = account.copyWith(balance: newBalance);
      await DatabaseService.updateAccount(updatedAccount);
    }
  }

  // Helper method to reverse account balance when transaction is deleted or updated
  static Future<void> reverseAccountBalance(
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

      // Reverse the transaction effect
      if (transactionType == 'income') {
        newBalance -= amount; // Remove income
      } else if (transactionType == 'expense') {
        newBalance += amount; // Add back expense
      }

      final updatedAccount = account.copyWith(balance: newBalance);
      await DatabaseService.updateAccount(updatedAccount);
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

  // Data export methods
  static Future<String> exportTransactionsToJson() async {
    final transactions = await getTransactions();
    return json.encode(transactions.map((t) => t.toJson()).toList());
  }

  static Future<String> exportAccountsToJson() async {
    final accounts = await getAccounts();
    return json.encode(accounts.map((a) => a.toJson()).toList());
  }

  static Future<String> exportBudgetsToJson() async {
    final budgets = await getBudgets();
    return json.encode(budgets.map((b) => b.toJson()).toList());
  }

  static Future<String> exportGroupsToJson() async {
    final groups = await getGroups();
    return json.encode(groups.map((g) => g.toJson()).toList());
  }

  // Data import methods
  static Future<void> importTransactionsFromJson(String jsonData) async {
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      final transaction = Transaction.fromJson(item);
      await addTransaction(transaction);
    }
  }

  static Future<void> importAccountsFromJson(String jsonData) async {
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      final account = Account.fromJson(item);
      await addAccount(account);
    }
  }

  static Future<void> importBudgetsFromJson(String jsonData) async {
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      final budget = Budget.fromJson(item);
      await addBudget(budget);
    }
  }

  static Future<void> importGroupsFromJson(String jsonData) async {
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      final group = Group.fromJson(item);
      await addGroup(group);
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
  }

  // Clear specific data types
  static Future<void> clearAllTransactions() async {
    final db = await DatabaseService.database;
    await db.delete('transactions');
  }

  static Future<void> clearAllBudgets() async {
    final db = await DatabaseService.database;
    await db.delete('budgets');
  }

  static Future<void> clearAllAccounts() async {
    final db = await DatabaseService.database;
    await db.delete('accounts');
  }

  static Future<void> clearAllGroups() async {
    final db = await DatabaseService.database;
    await db.delete('groups');
  }

  // Recalculate all account balances based on transactions
  static Future<void> recalculateAllAccountBalances() async {
    final accounts = await getAccounts();
    final transactions = await getTransactions();

    // Create a map to store calculated balances
    final Map<String, double> calculatedBalances = {};

    // Initialize all accounts with 0 balance
    for (final account in accounts) {
      calculatedBalances[account.id] = 0.0;
    }

    // Calculate balances from transactions
    for (final transaction in transactions) {
      if (transaction.accountId != null) {
        final currentBalance = calculatedBalances[transaction.accountId] ?? 0.0;

        if (transaction.type == 'income') {
          calculatedBalances[transaction.accountId!] =
              currentBalance + transaction.amount;
        } else if (transaction.type == 'expense') {
          calculatedBalances[transaction.accountId!] =
              currentBalance - transaction.amount;
        }
      }
    }

    // Update all accounts with calculated balances
    for (final account in accounts) {
      final newBalance = calculatedBalances[account.id] ?? 0.0;
      final updatedAccount = account.copyWith(balance: newBalance);
      await DatabaseService.updateAccount(updatedAccount);
    }
  }

  // Helper method to update account balance directly without fetching all accounts
  static Future<void> _updateAccountBalanceDirect(
    sqflite.Transaction txn,
    String accountId,
    double amount,
    String transactionType,
  ) async {
    // Use a direct SQL query to update the account balance
    final sql = '''
      UPDATE accounts 
      SET balance = CASE 
        WHEN ? = 'income' THEN balance + ?
        WHEN ? = 'expense' THEN balance - ?
        ELSE balance
      END
      WHERE id = ?
    ''';
    
    await txn.rawUpdate(sql, [transactionType, amount, transactionType, amount, accountId]);
  }

  // Helper method to get transaction by ID directly from transaction context
  static Future<Transaction?> _getTransactionByIdDirect(
    sqflite.Transaction txn,
    String id,
  ) async {
    final List<Map<String, dynamic>> maps = await txn.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    return Transaction(
      id: maps[0]['id'],
      title: maps[0]['title'],
      amount: maps[0]['amount'],
      date: DateTime.parse(maps[0]['date']),
      category: maps[0]['category'],
      type: maps[0]['type'],
      accountId: maps[0]['accountId'],
      notes: maps[0]['notes'],
      transferId: maps[0]['transferId'],
      toAccountId: maps[0]['toAccountId'],
    );
  }
}
