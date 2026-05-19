import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spendwise/models/recurring_transaction.dart';
import 'package:spendwise/models/transaction.dart';
import 'data_service.dart';

class RecurringTransactionService {
  static const _uuid = Uuid();

  // Get all recurring transactions
  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    try {
      if (kIsWeb) {
        // For web, we'll use a simplified approach
        // You can implement web storage for recurring transactions if needed
        return [];
      } else {
        // For mobile, use the existing database approach
        // This is a simplified version - you may need to implement proper recurring transaction storage
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Add a new recurring transaction
  static Future<void> addRecurringTransaction(
    RecurringTransaction recurringTransaction,
  ) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update a recurring transaction
  static Future<void> updateRecurringTransaction(
    RecurringTransaction recurringTransaction,
  ) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a recurring transaction
  static Future<void> deleteRecurringTransaction(String id) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get recurring transaction by ID
  static Future<RecurringTransaction?> getRecurringTransactionById(
    String id,
  ) async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      return recurringTransactions.firstWhere(
        (rt) => rt.id == id,
        orElse: () => throw Exception('Recurring transaction not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Check and create transactions for today
  static Future<List<Transaction>> checkAndCreateTransactionsForToday() async {
    try {
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
    } catch (e) {
      return [];
    }
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
        notes: 'Auto-generated from recurring transaction',
      );

      // Add the transaction using the data service
      await DataService.addTransaction(transaction);
      return transaction;
    } catch (e) {
      return null;
    }
  }

  // Get recurring transactions by account
  static Future<List<RecurringTransaction>> getRecurringTransactionsByAccount(
    String accountId,
  ) async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      return recurringTransactions
          .where((rt) => rt.accountId == accountId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get recurring transactions by category
  static Future<List<RecurringTransaction>> getRecurringTransactionsByCategory(
    String category,
  ) async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      return recurringTransactions
          .where((rt) => rt.category == category)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get active recurring transactions
  static Future<List<RecurringTransaction>>
  getActiveRecurringTransactions() async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      return recurringTransactions.where((rt) => rt.isActive).toList();
    } catch (e) {
      return [];
    }
  }

  // Pause a recurring transaction
  static Future<void> pauseRecurringTransaction(String id) async {
    try {
      final recurringTransaction = await getRecurringTransactionById(id);
      if (recurringTransaction != null) {
        final pausedRecurring = recurringTransaction.copyWith(isActive: false);
        await updateRecurringTransaction(pausedRecurring);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Resume a recurring transaction
  static Future<void> resumeRecurringTransaction(String id) async {
    try {
      final recurringTransaction = await getRecurringTransactionById(id);
      if (recurringTransaction != null) {
        final resumedRecurring = recurringTransaction.copyWith(isActive: true);
        await updateRecurringTransaction(resumedRecurring);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get overdue recurring transactions
  static Future<List<RecurringTransaction>>
  getOverdueRecurringTransactions() async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      final now = DateTime.now();
      return recurringTransactions
          .where((rt) => rt.isActive && rt.nextDueDate.isBefore(now))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get upcoming recurring transactions
  static Future<List<RecurringTransaction>> getUpcomingRecurringTransactions(
    int daysAhead,
  ) async {
    try {
      final recurringTransactions = await getRecurringTransactions();
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      return recurringTransactions
          .where(
            (rt) =>
                rt.isActive &&
                rt.nextDueDate.isAfter(now) &&
                rt.nextDueDate.isBefore(futureDate),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
