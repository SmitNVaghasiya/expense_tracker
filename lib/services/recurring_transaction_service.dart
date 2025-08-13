import 'package:uuid/uuid.dart';
import 'package:spendwise/models/recurring_transaction.dart';
import 'package:spendwise/models/transaction.dart';
import 'data_service.dart';
import 'database_service.dart';

class RecurringTransactionService {
  static const _uuid = Uuid();

  // Get all recurring transactions
  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
    );
    return List.generate(
      maps.length,
      (i) => RecurringTransaction.fromJson(maps[i]),
    );
  }

  // Add a new recurring transaction
  static Future<void> addRecurringTransaction(
    RecurringTransaction recurringTransaction,
  ) async {
    final db = await DatabaseService.database;
    await db.insert('recurring_transactions', recurringTransaction.toJson());
  }

  // Update a recurring transaction
  static Future<void> updateRecurringTransaction(
    RecurringTransaction recurringTransaction,
  ) async {
    final db = await DatabaseService.database;
    await db.update(
      'recurring_transactions',
      recurringTransaction.toJson(),
      where: 'id = ?',
      whereArgs: [recurringTransaction.id],
    );
  }

  // Delete a recurring transaction
  static Future<void> deleteRecurringTransaction(String id) async {
    final db = await DatabaseService.database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Get recurring transaction by ID
  static Future<RecurringTransaction?> getRecurringTransactionById(
    String id,
  ) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransaction.fromJson(maps.first);
    }
    return null;
  }

  // Check and create transactions for today
  static Future<List<Transaction>> checkAndCreateTransactionsForToday() async {
    final recurringTransactions = await getRecurringTransactions();
    final List<Transaction> createdTransactions = [];

    for (final recurringTransaction in recurringTransactions) {
      if (recurringTransaction.shouldCreateTransactionToday()) {
        final transaction = await createTransactionFromRecurring(
          recurringTransaction,
        );
        if (transaction != null) {
          createdTransactions.add(transaction);

          // Update the next due date
          final updatedRecurring = recurringTransaction.copyWith(
            nextDueDate: recurringTransaction.calculateNextDueDate(),
          );
          await updateRecurringTransaction(updatedRecurring);
        }
      }
    }

    return createdTransactions;
  }

  // Create a transaction from a recurring transaction
  static Future<Transaction?> createTransactionFromRecurring(
    RecurringTransaction recurringTransaction,
  ) async {
    try {
      final transaction = Transaction(
        id: _uuid.v4(),
        title: recurringTransaction.title,
        amount: recurringTransaction.amount,
        date: DateTime.now(),
        category: recurringTransaction.category,
        type: recurringTransaction.type,
        accountId: recurringTransaction.accountId,
        notes: recurringTransaction.notes,
        transferId: recurringTransaction.transferId,
        toAccountId: recurringTransaction.toAccountId,
      );

      await DataService.addTransaction(transaction);
      return transaction;
    } catch (e) {
      print('Error creating transaction from recurring: $e');
      return null;
    }
  }

  // Get upcoming recurring transactions
  static Future<List<RecurringTransaction>> getUpcomingRecurringTransactions({
    int days = 7,
  }) async {
    final allRecurring = await getRecurringTransactions();
    final today = DateTime.now();
    final endDate = today.add(Duration(days: days));

    return allRecurring.where((recurring) {
      return recurring.isActive &&
          recurring.nextDueDate.isAfter(today) &&
          recurring.nextDueDate.isBefore(endDate);
    }).toList();
  }

  // Get overdue recurring transactions
  static Future<List<RecurringTransaction>>
  getOverdueRecurringTransactions() async {
    final allRecurring = await getRecurringTransactions();
    final today = DateTime.now();

    return allRecurring.where((recurring) {
      return recurring.isActive &&
          recurring.nextDueDate.isBefore(today) &&
          (recurring.endDate == null || today.isBefore(recurring.endDate!));
    }).toList();
  }

  // Pause a recurring transaction
  static Future<void> pauseRecurringTransaction(String id) async {
    final recurring = await getRecurringTransactionById(id);
    if (recurring != null) {
      final updated = recurring.copyWith(isActive: false);
      await updateRecurringTransaction(updated);
    }
  }

  // Resume a recurring transaction
  static Future<void> resumeRecurringTransaction(String id) async {
    final recurring = await getRecurringTransactionById(id);
    if (recurring != null) {
      final updated = recurring.copyWith(isActive: true);
      await updateRecurringTransaction(updated);
    }
  }

  // Get recurring transactions by frequency
  static Future<List<RecurringTransaction>> getRecurringTransactionsByFrequency(
    String frequency,
  ) async {
    final allRecurring = await getRecurringTransactions();
    return allRecurring
        .where((recurring) => recurring.frequency == frequency)
        .toList();
  }

  // Get recurring transactions by category
  static Future<List<RecurringTransaction>> getRecurringTransactionsByCategory(
    String category,
  ) async {
    final allRecurring = await getRecurringTransactions();
    return allRecurring
        .where((recurring) => recurring.category == category)
        .toList();
  }

  // Get total monthly recurring amount
  static Future<double> getTotalMonthlyRecurringAmount() async {
    final monthlyRecurring = await getRecurringTransactionsByFrequency(
      'monthly',
    );
    double total = 0.0;

    for (final recurring in monthlyRecurring) {
      if (recurring.isActive) {
        if (recurring.type == 'income') {
          total += recurring.amount;
        } else if (recurring.type == 'expense') {
          total -= recurring.amount;
        }
      }
    }

    return total;
  }

  // Get recurring transactions summary
  static Future<Map<String, dynamic>> getRecurringTransactionsSummary() async {
    final allRecurring = await getRecurringTransactions();
    final activeRecurring = allRecurring.where((r) => r.isActive).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final recurring in activeRecurring) {
      if (recurring.type == 'income') {
        totalIncome += recurring.amount;
      } else if (recurring.type == 'expense') {
        totalExpense += recurring.amount;
      }
    }

    return {
      'totalRecurring': allRecurring.length,
      'activeRecurring': activeRecurring.length,
      'totalMonthlyIncome': totalIncome,
      'totalMonthlyExpense': totalExpense,
      'netMonthlyAmount': totalIncome - totalExpense,
    };
  }
}
