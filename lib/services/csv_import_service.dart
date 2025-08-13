import 'dart:io';
import 'package:spendwise/models/transaction.dart';

class CSVImportService {
  static Future<List<Transaction>> importFromCSV(File file) async {
    List<Transaction> transactions = [];

    try {
      String content = await file.readAsString();
      List<String> lines = content.split('\n');

      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> columns = line.split(',');
        if (columns.length >= 5) {
          try {
            DateTime date = DateTime.parse(columns[0]);
            String type = columns[1].toLowerCase();
            String category = columns[2];
            double amount = double.parse(columns[3]);
            String title = columns[4].replaceAll(';', ',');

            // Validate type
            if (type != 'income' && type != 'expense') {
              type = 'expense'; // Default to expense if invalid
            }

            Transaction transaction = Transaction(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              title: title,
              amount: amount,
              date: date,
              category: category,
              type: type,
            );

            transactions.add(transaction);
          } catch (e) {
            // Skip invalid lines
            // Skipping invalid line $i: $e
          }
        }
      }
    } catch (e) {
      throw Exception('Error reading CSV file: $e');
    }

    return transactions;
  }
}
