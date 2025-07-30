import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class CsvImportService {
  static Future<void> importTransactionsFromCsv(String filePath) async {
    try {
      // Read the CSV file
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Skip the header row if it exists
      bool hasHeader = fields.isNotEmpty && 
          (fields[0][0] == 'Date' || 
           fields[0][0] == 'date' || 
           fields[0][0] == 'Title' ||
           fields[0][0] == 'title');

      int startIndex = hasHeader ? 1 : 0;

      // Process each row
      List<Transaction> transactions = [];
      for (int i = startIndex; i < fields.length; i++) {
        final row = fields[i];
        if (row.length >= 4) { // Ensure we have enough columns
          try {
            // Parse date (assuming format: DD/MM/YYYY or YYYY-MM-DD)
            DateTime date;
            if (row[0] is String) {
              String dateString = row[0].toString().trim();
              if (dateString.contains('/')) {
                // DD/MM/YYYY format
                List<String> parts = dateString.split('/');
                date = DateTime(
                  int.parse(parts[2]), 
                  int.parse(parts[1]), 
                  int.parse(parts[0])
                );
              } else if (dateString.contains('-')) {
                // YYYY-MM-DD format
                date = DateTime.parse(dateString);
              } else {
                // Try to parse as is
                date = DateTime.parse(dateString);
              }
            } else {
              date = DateTime.now(); // Default to now if parsing fails
            }

            // Parse amount (assuming it's in column 3)
            double amount = 0;
            if (row[3] is String) {
              // Remove currency symbols and commas
              String amountString = row[3].toString().trim();
              amountString = amountString.replaceAll(RegExp(r'[₹$,]'), '');
              amount = double.tryParse(amountString) ?? 0;
            } else if (row[3] is num) {
              amount = (row[3] as num).toDouble();
            }

            // Determine type (expense or income) based on amount or column 4
            String type = 'expense';
            if (amount >= 0) {
              type = 'income';
            } else {
              type = 'expense';
              amount = amount.abs(); // Make amount positive for expenses
            }

            // Create transaction
            final transaction = Transaction(
              id: const Uuid().v4(),
              title: (row[1] != null) ? row[1].toString().trim() : 'Imported Transaction',
              amount: amount,
              date: date,
              category: (row[2] != null) ? row[2].toString().trim() : 'Other',
              type: type,
            );

            transactions.add(transaction);
          } catch (e) {
            // Skip rows that can't be parsed
            debugPrint('Error parsing row $i: $e');
          }
        }
      }

      // Save all transactions
      for (var transaction in transactions) {
        await DataService.addTransaction(transaction);
      }
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      rethrow;
    }
  }
}