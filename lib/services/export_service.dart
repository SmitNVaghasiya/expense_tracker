import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/models/transaction.dart';

import 'package:intl/intl.dart';

class ExportService {
  // Export all data to JSON
  static Future<String> exportAllDataToJson() async {
    final transactions = await DataService.getTransactions();
    final accounts = await DataService.getAccounts();
    final budgets = await DataService.getBudgets();
    final groups = await DataService.getGroups();

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
    };

    return json.encode(data);
  }

  // Export transactions to CSV
  static Future<String> exportTransactionsToCsv() async {
    final transactions = await DataService.getTransactions();

    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Date,Type,Category,Title,Amount,Account,Notes');

    // Add data rows
    for (final transaction in transactions) {
      final accountName = transaction.accountId != null
          ? await DataService.getAccountNameById(transaction.accountId!)
          : 'No Account';

      csvData.writeln(
        [
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.type,
          transaction.category,
          transaction.title,
          transaction.amount.toString(),
          accountName,
          transaction.notes ?? '',
        ].map((field) => '"${field.replaceAll('"', '""')}"').join(','),
      );
    }

    return csvData.toString();
  }

  // Export accounts to CSV
  static Future<String> exportAccountsToCsv() async {
    final accounts = await DataService.getAccounts();

    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Name,Type,Balance,Created Date');

    // Add data rows
    for (final account in accounts) {
      csvData.writeln(
        [
          account.name,
          account.type,
          account.balance.toString(),
          DateFormat('yyyy-MM-dd').format(account.createdAt),
        ].map((field) => '"${field.replaceAll('"', '""')}"').join(','),
      );
    }

    return csvData.toString();
  }

  // Export budgets to CSV
  static Future<String> exportBudgetsToCsv() async {
    final budgets = await DataService.getBudgets();

    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Name,Category,Amount,Start Date,End Date');

    // Add data rows
    for (final budget in budgets) {
      csvData.writeln(
        [
          budget.name,
          budget.category,
          budget.limit.toString(),
          DateFormat('yyyy-MM-dd').format(budget.startDate),
          DateFormat('yyyy-MM-dd').format(budget.endDate),
        ].map((field) => '"${field.replaceAll('"', '""')}"').join(','),
      );
    }

    return csvData.toString();
  }

  // Save file to device
  static Future<String> saveFileToDevice(
    String content,
    String filename,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file.path;
  }

  // Generate financial report
  static Future<Map<String, dynamic>> generateFinancialReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await DataService.getTransactions();

    // Filter by date range if provided
    List<Transaction> filteredTransactions = transactions;
    if (startDate != null || endDate != null) {
      filteredTransactions = transactions.where((t) {
        if (startDate != null && t.date.isBefore(startDate)) return false;
        if (endDate != null && t.date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // Calculate totals
    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> categoryExpenses = {};
    Map<String, double> categoryIncome = {};

    for (final transaction in filteredTransactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
        categoryIncome[transaction.category] =
            (categoryIncome[transaction.category] ?? 0) + transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpenses += transaction.amount;
        categoryExpenses[transaction.category] =
            (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;

    return {
      'period': {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      },
      'summary': {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': balance,
        'transactionCount': filteredTransactions.length,
      },
      'categoryBreakdown': {
        'expenses': categoryExpenses,
        'income': categoryIncome,
      },
      'transactions': filteredTransactions.map((t) => t.toJson()).toList(),
    };
  }

  // Export financial report to JSON
  static Future<String> exportFinancialReportToJson({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final report = await generateFinancialReport(
      startDate: startDate,
      endDate: endDate,
    );
    return json.encode(report);
  }

  // Get export file path
  static Future<String> getExportFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  // Check if file exists
  static Future<bool> fileExists(String filename) async {
    final file = File(await getExportFilePath(filename));
    return await file.exists();
  }

  // Delete export file
  static Future<void> deleteExportFile(String filename) async {
    final file = File(await getExportFilePath(filename));
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Get all export files
  static Future<List<FileSystemEntity>> getExportFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    return files
        .where(
          (file) =>
              file.path.contains('export_') ||
              file.path.contains('report_') ||
              file.path.contains('backup_'),
        )
        .toList();
  }
}
