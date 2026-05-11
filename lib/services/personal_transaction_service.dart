import 'package:spendwise/models/personal_transaction.dart';
import 'package:spendwise/services/storage_service.dart';
import 'dart:convert';

class PersonalTransactionService {
  static const String _collectionName = 'personal_transactions';

  // Get all personal transactions
  static Future<List<PersonalTransaction>> getPersonalTransactions() async {
    try {
      final data = await StorageService.getData(_collectionName);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => PersonalTransaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get personal transactions: $e');
    }
  }

  // Get transactions by type (lent or borrowed)
  static Future<List<PersonalTransaction>> getTransactionsByType(String type) async {
    try {
      final allTransactions = await getPersonalTransactions();
      return allTransactions.where((transaction) => transaction.type == type).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by type: $e');
    }
  }

  // Add new personal transaction
  static Future<PersonalTransaction> addPersonalTransaction(PersonalTransaction transaction) async {
    try {
      final transactions = await getPersonalTransactions();
      transactions.add(transaction);
      
      final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
      await StorageService.saveData(_collectionName, jsonData);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to add personal transaction: $e');
    }
  }

  // Update existing personal transaction
  static Future<PersonalTransaction> updatePersonalTransaction(PersonalTransaction transaction) async {
    try {
      final transactions = await getPersonalTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      
      if (index == -1) {
        throw Exception('Transaction not found');
      }
      
      transactions[index] = transaction;
      final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
      await StorageService.saveData(_collectionName, jsonData);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to update personal transaction: $e');
    }
  }

  // Delete personal transaction
  static Future<void> deletePersonalTransaction(String transactionId) async {
    try {
      final transactions = await getPersonalTransactions();
      transactions.removeWhere((t) => t.id == transactionId);
      
      final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
      await StorageService.saveData(_collectionName, jsonData);
    } catch (e) {
      throw Exception('Failed to delete personal transaction: $e');
    }
  }

  // Add payment to transaction
  static Future<PersonalTransaction> addPayment(String transactionId, PersonalPayment payment) async {
    try {
      final transactions = await getPersonalTransactions();
      final transactionIndex = transactions.indexWhere((t) => t.id == transactionId);
      
      if (transactionIndex == -1) {
        throw Exception('Transaction not found');
      }
      
      final transaction = transactions[transactionIndex];
      final updatedPaymentHistory = List<PersonalPayment>.from(transaction.paymentHistory)..add(payment);
      final newPaidAmount = updatedPaymentHistory.fold(0.0, (sum, p) => sum + p.amount);
      
      final updatedTransaction = transaction.copyWith(
        paidAmount: newPaidAmount,
        paymentHistory: updatedPaymentHistory,
      );
      
      await updatePersonalTransaction(updatedTransaction);
      return updatedTransaction;
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // Get transaction summary
  static Future<Map<String, dynamic>> getTransactionSummary() async {
    try {
      final transactions = await getPersonalTransactions();
      
      final lentTransactions = transactions.where((t) => t.type == 'lent').toList();
      final borrowedTransactions = transactions.where((t) => t.type == 'borrowed').toList();
      
      final totalLent = lentTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final totalBorrowed = borrowedTransactions.fold(0.0, (sum, t) => sum + t.amount);
      
      final totalPaidLent = lentTransactions.fold(0.0, (sum, t) => sum + t.paidAmount);
      final totalPaidBorrowed = borrowedTransactions.fold(0.0, (sum, t) => sum + t.paidAmount);
      
      return {
        'totalLent': totalLent,
        'totalBorrowed': totalBorrowed,
        'totalPaidLent': totalPaidLent,
        'totalPaidBorrowed': totalPaidBorrowed,
        'remainingLent': totalLent - totalPaidLent,
        'remainingBorrowed': totalBorrowed - totalPaidBorrowed,
        'totalTransactions': transactions.length,
        'lentTransactions': lentTransactions.length,
        'borrowedTransactions': borrowedTransactions.length,
      };
    } catch (e) {
      throw Exception('Failed to get transaction summary: $e');
    }
  }

  // Get transactions by person
  static Future<List<PersonalTransaction>> getTransactionsByPerson(String personName) async {
    try {
      final allTransactions = await getPersonalTransactions();
      return allTransactions.where((transaction) => 
        transaction.personName.toLowerCase().contains(personName.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by person: $e');
    }
  }

  // Get overdue transactions (transactions with interest that are past due)
  static Future<List<PersonalTransaction>> getOverdueTransactions() async {
    try {
      final allTransactions = await getPersonalTransactions();
      final now = DateTime.now();
      
      return allTransactions.where((transaction) {
        if (transaction.durationMonths == null) return false;
        
        final dueDate = transaction.date.add(Duration(days: transaction.durationMonths! * 30));
        return dueDate.isBefore(now) && !transaction.isFullyPaid;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get overdue transactions: $e');
    }
  }
}
