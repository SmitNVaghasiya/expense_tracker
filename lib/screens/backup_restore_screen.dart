import 'package:flutter/material.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CSVFormat {
  final String name;
  final int dateColumn;
  final int categoryColumn;
  final int amountColumn;
  final int notesColumn;
  final String sampleData;

  CSVFormat({
    required this.name,
    required this.dateColumn,
    required this.categoryColumn,
    required this.amountColumn,
    required this.notesColumn,
    required this.sampleData,
  });
}

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  List<String> _backupFiles = [];
  List<Map<String, dynamic>> _backupInfo = [];

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Directory? directory = await getApplicationDocumentsDirectory();
      Directory backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      List<FileSystemEntity> files = await backupDir.list().toList();
      _backupFiles = files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();

      // Get backup information
      _backupInfo.clear();
      for (String filePath in _backupFiles) {
        try {
          File file = File(filePath);
          String content = await file.readAsString();
          Map<String, dynamic> data = jsonDecode(content);

          DateTime timestamp = DateTime.parse(data['timestamp']);
          int transactionCount = (data['transactions'] as List).length;

          _backupInfo.add({
            'path': filePath,
            'timestamp': timestamp,
            'transactionCount': transactionCount,
            'fileName': filePath.split('/').last,
          });
        } catch (e) {
          print('Error reading backup file: $e');
        }
      }

      // Sort by timestamp (newest first)
      _backupInfo.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading backup files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backup Section
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.backup,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create a backup of all your transaction data. This will be stored locally on your device.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _createBackup,
                            icon: const Icon(Icons.save),
                            label: const Text('Create Backup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _exportBackup,
                            icon: const Icon(Icons.share),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Restore Section
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restore,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Restore from Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Restore your data from a previous backup. This will replace all current data.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _importBackup,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Import JSON'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _importCSV,
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Import CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.tertiary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadBackupFiles,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_backupInfo.isNotEmpty) ...[
                      Text(
                        'Available Backups:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _backupInfo.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> backup = _backupInfo[index];
                            DateTime timestamp = backup['timestamp'];
                            int transactionCount = backup['transactionCount'];

                            return Card(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: ListTile(
                                leading: const Icon(Icons.file_copy),
                                title: Text(
                                  'Backup: ${DateFormat('MMM dd, yyyy HH:mm').format(timestamp)}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  '$transactionCount transactions',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.restore),
                                      onPressed: () =>
                                          _restoreBackup(backup['path']),
                                      tooltip: 'Restore',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteBackup(backup['path']),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No backup files found.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all transactions and accounts
      List<Transaction> transactions = await DataService.getTransactions();
      List<Account> accounts = await DataService.getAccounts();

      // Create backup data
      Map<String, dynamic> backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'accounts': accounts.map((a) => a.toJson()).toList(),
      };

      // Get backup directory
      Directory? directory = await getApplicationDocumentsDirectory();
      Directory backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Create backup file
      String fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      File backupFile = File('${backupDir.path}/$fileName');

      await backupFile.writeAsString(jsonEncode(backupData));

      // Reload backup files
      await _loadBackupFiles();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully: ${backupFile.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportBackup() async {
    try {
      // Get all transactions
      List<Transaction> transactions = await DataService.getTransactions();
      List<Account> accounts = await DataService.getAccounts();

      // Create backup data
      Map<String, dynamic> backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'accounts': accounts.map((a) => a.toJson()).toList(),
      };

      // Save to file and share
      Directory? directory = await getApplicationDocumentsDirectory();
      String fileName =
          'mymoney_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      File backupFile = File('${directory.path}/$fileName');

      await backupFile.writeAsString(jsonEncode(backupData));

      // Share the file
      final Uri uri = Uri.file(backupFile.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> backupData = jsonDecode(content);

        // Show confirmation dialog
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Confirm Import',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Text(
                'This will replace all current data with the imported backup. This action cannot be undone. Are you sure?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Import',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          setState(() {
            _isLoading = true;
          });

          // Clear current data
          await DataService.clearAllData();

          // Restore transactions
          if (backupData['transactions'] != null) {
            List<dynamic> transactionsData = backupData['transactions'];
            for (dynamic transactionData in transactionsData) {
              Transaction transaction = Transaction.fromJson(transactionData);
              await DataService.addTransaction(transaction);
            }
          }

          // Restore accounts
          if (backupData['accounts'] != null) {
            List<dynamic> accountsData = backupData['accounts'];
            for (dynamic accountData in accountsData) {
              Account account = Account.fromJson(accountData);
              await DataService.addAccount(account);
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully imported backup'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        // Detect CSV format
        CSVFormat format = _detectCSVFormat(content);

        // Show format confirmation dialog
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'CSV Format Detected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected format: ${format.name}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sample data:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      format.sampleData,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will replace all current data. Continue?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Import',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          setState(() {
            _isLoading = true;
          });

          // Parse CSV and import
          List<Transaction> transactions = await _parseCSV(content, format);

          // Clear current data
          await DataService.clearAllData();

          // Import transactions
          for (Transaction transaction in transactions) {
            await DataService.addTransaction(transaction);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported ${transactions.length} transactions',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  CSVFormat _detectCSVFormat(String content) {
    List<List<dynamic>> rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) throw Exception('Empty CSV file');

    List<String> headers = rows[0]
        .map((e) => e.toString().toLowerCase())
        .toList();

    // Check for different formats
    if (headers.contains('date') &&
        headers.contains('category') &&
        headers.contains('amount')) {
      return CSVFormat(
        name: 'Standard Format',
        dateColumn: headers.indexOf('date'),
        categoryColumn: headers.indexOf('category'),
        amountColumn: headers.indexOf('amount'),
        notesColumn: headers.contains('note') ? headers.indexOf('note') : -1,
        sampleData: rows.length > 1 ? rows[1].join(', ') : 'No data',
      );
    } else if (headers.contains('date') &&
        headers.contains('description') &&
        headers.contains('amount')) {
      return CSVFormat(
        name: 'Description Format',
        dateColumn: headers.indexOf('date'),
        categoryColumn: headers.indexOf('description'),
        amountColumn: headers.indexOf('amount'),
        notesColumn: headers.contains('notes') ? headers.indexOf('notes') : -1,
        sampleData: rows.length > 1 ? rows[1].join(', ') : 'No data',
      );
    } else if (headers.contains('transaction_date') &&
        headers.contains('category') &&
        headers.contains('amount')) {
      return CSVFormat(
        name: 'Transaction Date Format',
        dateColumn: headers.indexOf('transaction_date'),
        categoryColumn: headers.indexOf('category'),
        amountColumn: headers.indexOf('amount'),
        notesColumn: headers.contains('description')
            ? headers.indexOf('description')
            : -1,
        sampleData: rows.length > 1 ? rows[1].join(', ') : 'No data',
      );
    } else {
      // Generic format - try to guess
      return CSVFormat(
        name: 'Auto-detected Format',
        dateColumn: headers.indexWhere((h) => h.contains('date')),
        categoryColumn: headers.indexWhere(
          (h) => h.contains('category') || h.contains('description'),
        ),
        amountColumn: headers.indexWhere((h) => h.contains('amount')),
        notesColumn: headers.indexWhere(
          (h) => h.contains('note') || h.contains('description'),
        ),
        sampleData: rows.length > 1 ? rows[1].join(', ') : 'No data',
      );
    }
  }

  Future<List<Transaction>> _parseCSV(String content, CSVFormat format) async {
    List<List<dynamic>> rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) return [];

    List<Transaction> transactions = [];

    // Skip header row
    for (int i = 1; i < rows.length; i++) {
      try {
        List<dynamic> row = rows[i];
        if (row.length < 3) continue; // Skip invalid rows

        // Parse date
        String dateStr = row[format.dateColumn].toString();
        DateTime date = _parseDate(dateStr);

        // Parse amount
        String amountStr = row[format.amountColumn].toString().replaceAll(
          ',',
          '',
        );
        double amount = double.parse(amountStr);

        // Determine type based on amount sign
        String type = amount < 0 ? 'expense' : 'income';
        amount = amount.abs(); // Make amount positive

        // Parse category/title
        String category = row[format.categoryColumn].toString().trim();
        String title = category; // Use category as title

        // Parse notes
        String? notes;
        if (format.notesColumn >= 0 && format.notesColumn < row.length) {
          String notesStr = row[format.notesColumn].toString().trim();
          if (notesStr.isNotEmpty) {
            notes = notesStr;
          }
        }

        // Create transaction
        Transaction transaction = Transaction(
          id: const Uuid().v4(),
          title: title,
          amount: amount,
          date: date,
          category: category,
          type: type,
          notes: notes,
        );

        transactions.add(transaction);
      } catch (e) {
        print('Error parsing row $i: $e');
        continue; // Skip problematic rows
      }
    }

    return transactions;
  }

  DateTime _parseDate(String dateStr) {
    // Try different date formats
    List<String> formats = [
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
      'dd/MM/yy',
      'MM/dd/yy',
    ];

    for (String format in formats) {
      try {
        return DateFormat(format).parse(dateStr);
      } catch (e) {
        continue;
      }
    }

    // If all formats fail, try parsing manually
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        if (year < 100) year += 2000; // Handle 2-digit years
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Continue to next format
    }

    throw Exception('Unable to parse date: $dateStr');
  }

  Future<void> _deleteBackup(String backupPath) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this backup? This action cannot be undone.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        File backupFile = File(backupPath);
        await backupFile.delete();

        // Reload backup files
        await _loadBackupFiles();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting backup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _restoreBackup(String backupPath) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Confirm Restore',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'This will replace all current data with the backup. This action cannot be undone. Are you sure?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Restore',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Read backup file
      File backupFile = File(backupPath);
      String content = await backupFile.readAsString();
      Map<String, dynamic> backupData = jsonDecode(content);

      // Clear current data
      await DataService.clearAllData();

      // Restore transactions
      if (backupData['transactions'] != null) {
        List<dynamic> transactionsData = backupData['transactions'];
        for (dynamic transactionData in transactionsData) {
          Transaction transaction = Transaction.fromJson(transactionData);
          await DataService.addTransaction(transaction);
        }
      }

      // Restore accounts
      if (backupData['accounts'] != null) {
        List<dynamic> accountsData = backupData['accounts'];
        for (dynamic accountData in accountsData) {
          Account account = Account.fromJson(accountData);
          await DataService.addAccount(account);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully restored backup'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
