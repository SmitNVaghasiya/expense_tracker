import 'dart:io';
import 'package:spendwise/models/transaction.dart';

class CSVImportService {
  /// Imports transactions from a CSV file.
  ///
  /// Supports two formats:
  ///
  /// Format A (SpendWise export):
  ///   date,type,category,amount,title[,notes,accountId]
  ///   2023-12-19,expense,Food,90.00,Lunch
  ///
  /// Format B (your personal CSV / generic export):
  ///   Date, Category, Amount, Note
  ///   19/12/2023, Eating Out, -90.00, some note
  ///   — amount sign determines type: negative = expense, positive = income
  ///   — date in dd/MM/yyyy or yyyy-MM-dd
  static Future<CSVImportResult> importFromCSV(
    File file, {
    String? defaultAccountId,
  }) async {
    final transactions = <Transaction>[];
    final errors = <String>[];

    try {
      final content = await file.readAsString();
      final lines = content.split('\n');
      if (lines.isEmpty) return CSVImportResult(transactions: [], errors: ['File is empty']);

      final header = _parseLine(lines[0]);
      final format = _detectFormat(header);

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final cols = _parseLine(line);
          final Transaction tx;

          if (format == _CSVFormat.spendWise) {
            tx = _parseSpendWiseRow(cols, i, defaultAccountId);
          } else {
            tx = _parseGenericRow(cols, i, defaultAccountId);
          }

          transactions.add(tx);
        } catch (e) {
          errors.add('Row ${i + 1}: $e');
        }
      }
    } catch (e) {
      throw Exception('Cannot read CSV file: $e');
    }

    return CSVImportResult(transactions: transactions, errors: errors);
  }

  // ── Format detection ──────────────────────────────────────────────

  static _CSVFormat _detectFormat(List<String> header) {
    if (header.length >= 5 &&
        header[1].toLowerCase().contains('type')) {
      return _CSVFormat.spendWise;
    }
    return _CSVFormat.generic;
  }

  // ── SpendWise export format ───────────────────────────────────────
  // date, type, category, amount, title [, notes, accountId]

  static Transaction _parseSpendWiseRow(
    List<String> cols,
    int lineIndex,
    String? defaultAccountId,
  ) {
    if (cols.length < 5) throw 'Expected 5+ columns, got ${cols.length}';

    final date = _parseDate(cols[0]);
    final type = cols[1].toLowerCase() == 'income' ? 'income' : 'expense';
    final category = cols[2];
    final amount = double.parse(cols[3]);
    final title = cols[4];
    final notes = cols.length > 5 ? cols[5] : null;
    final accountId = cols.length > 6 ? cols[6] : defaultAccountId;

    return Transaction(
      id: '${DateTime.now().millisecondsSinceEpoch}_$lineIndex',
      title: title.isEmpty ? category : title,
      amount: amount.abs(),
      date: date,
      category: category,
      type: type,
      accountId: accountId,
      notes: notes?.isEmpty == true ? null : notes,
    );
  }

  // ── Generic / personal CSV format ────────────────────────────────
  // Date, Category, Amount, Note
  // 19/12/2023, Eating Out, -90.00, some note

  static Transaction _parseGenericRow(
    List<String> cols,
    int lineIndex,
    String? defaultAccountId,
  ) {
    if (cols.length < 3) throw 'Expected at least 3 columns (Date, Category, Amount), got ${cols.length}';

    final date = _parseDate(cols[0]);
    final category = cols[1];
    final rawAmount = double.parse(cols[2]);
    final note = cols.length > 3 ? cols[3] : null;

    // Sign convention: negative = expense, positive = income
    final type = rawAmount < 0 ? 'expense' : 'income';
    final amount = rawAmount.abs();

    return Transaction(
      id: '${DateTime.now().millisecondsSinceEpoch}_$lineIndex',
      title: (note?.isNotEmpty == true) ? note! : category,
      amount: amount,
      date: date,
      category: category,
      type: type,
      accountId: defaultAccountId,
      notes: note?.isNotEmpty == true ? note : null,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Parses a CSV line, handling quoted fields and trimming whitespace.
  static List<String> _parseLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  /// Parses dates in dd/MM/yyyy or yyyy-MM-dd format.
  static DateTime _parseDate(String raw) {
    final s = raw.trim();

    // dd/MM/yyyy
    final slashParts = s.split('/');
    if (slashParts.length == 3 && slashParts[0].length <= 2) {
      final day = int.parse(slashParts[0]);
      final month = int.parse(slashParts[1]);
      final year = int.parse(slashParts[2]);
      return DateTime(year, month, day);
    }

    // yyyy-MM-dd or ISO 8601
    return DateTime.parse(s);
  }
}

// ── Result type ────────────────────────────────────────────────────

class CSVImportResult {
  final List<Transaction> transactions;
  final List<String> errors;

  CSVImportResult({required this.transactions, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => transactions.length;
}

enum _CSVFormat { spendWise, generic }
