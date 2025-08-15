import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path_provider/path_provider.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/models/group.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/error_service.dart';
import 'dart:convert';
import 'package:spendwise/models/loan.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'spendwise.db';
  static const int _dbVersion = 6; // Increment version to trigger upgrades

  // Table names
  static const String _transactionsTable = 'transactions';
  static const String _accountsTable = 'accounts';
  static const String _budgetsTable = 'budgets';
  static const String _overallBudgetsTable = 'overall_budgets';
  static const String _categoriesTable = 'categories';
  static const String _groupsTable = 'groups';
  static const String _loansTable = 'loans';
  static const String _financialGoalsTable = 'financial_goals';
  static const String _billRemindersTable = 'bill_reminders';
  static const String _recurringTransactionsTable = 'recurring_transactions';

  // Initialize database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    try {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Add delay to ensure platform channels are ready
      await Future.delayed(const Duration(milliseconds: 100));

      final io.Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, _dbName);

      print('Database path: $path'); // Debug log

      final Database database = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      return database;
    } catch (e, stackTrace) {
      print('Database initialization error: $e'); // Debug log
      ErrorService.logError(
        'Failed to initialize database: $e',
        context: 'DatabaseService._initDatabase',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Create tables
  static Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        accountId TEXT,
        notes TEXT,
        transferId TEXT,
        toAccountId TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_transactions_type ON $_transactionsTable(type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_account ON $_transactionsTable(accountId)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $_transactionsTable(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON $_transactionsTable(category)',
    );

    // Create accounts table
    await db.execute('''
      CREATE TABLE $_accountsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        "limit" REAL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create index for accounts
    await db.execute('CREATE INDEX idx_accounts_type ON $_accountsTable(type)');

    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create index for categories
    await db.execute(
      'CREATE INDEX idx_categories_type ON $_categoriesTable(type)',
    );

    // Create budgets table
    await db.execute('''
      CREATE TABLE $_budgetsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        "limit" REAL NOT NULL,
        category TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL
      )
    ''');

    // Create overall budgets table
    await db.execute('''
      CREATE TABLE $_overallBudgetsTable (
        id TEXT PRIMARY KEY,
        "limit" REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        name TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    // Create groups table
    await db.execute('''
    CREATE TABLE $_groupsTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      createdAt TEXT NOT NULL
    )
  ''');

    // Create loans table
    await db.execute('''
    CREATE TABLE $_loansTable (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      person TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      dueDate TEXT,
      status TEXT NOT NULL,
      notes TEXT,
      accountId TEXT,
      paymentFrequency TEXT,
      paymentDay INTEGER,
      monthlyPayment REAL,
      paidAmount REAL NOT NULL,
      autoDeduct INTEGER NOT NULL,
      nextPaymentDate TEXT,
      nextPaymentAmount REAL,
      paymentHistory TEXT,
      createdAt TEXT NOT NULL
    )
  ''');

    // Create recurring transactions table
    await db.execute('''
    CREATE TABLE $_recurringTransactionsTable (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL,
      accountId TEXT,
      notes TEXT,
      toAccountId TEXT,
      frequency TEXT NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT,
      nextDueDate TEXT NOT NULL,
      isActive INTEGER NOT NULL,
      transferId TEXT
    )
  ''');

    // Create bill reminders table
    await db.execute('''
    CREATE TABLE $_billRemindersTable (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      dueDate TEXT NOT NULL,
      accountId TEXT,
      notes TEXT,
      isPaid INTEGER NOT NULL,
      paidDate TEXT,
      reminderDays INTEGER NOT NULL,
      isActive INTEGER NOT NULL,
      recurringPattern TEXT,
      nextDueDate TEXT
    )
  ''');

    // Create financial goals table
    await db.execute('''
    CREATE TABLE $_financialGoalsTable (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      targetAmount REAL NOT NULL,
      currentAmount REAL NOT NULL,
      targetDate TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      goalType TEXT NOT NULL,
      accountId TEXT,
      isActive INTEGER NOT NULL,
      category TEXT,
      color TEXT
    )
  ''');
  }

  // Database upgrade
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add transfer fields to transactions table
      await db.execute(
        'ALTER TABLE $_transactionsTable ADD COLUMN transferId TEXT',
      );
      await db.execute(
        'ALTER TABLE $_transactionsTable ADD COLUMN toAccountId TEXT',
      );
    }

    if (oldVersion < 3) {
      // Create new tables for recurring transactions, bill reminders, and financial goals
      await db.execute('''
        CREATE TABLE $_recurringTransactionsTable (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          type TEXT NOT NULL,
          accountId TEXT,
          notes TEXT,
          toAccountId TEXT,
          frequency TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT,
          nextDueDate TEXT NOT NULL,
          isActive INTEGER NOT NULL,
          transferId TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE $_billRemindersTable (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          dueDate TEXT NOT NULL,
          accountId TEXT,
          notes TEXT,
          isPaid INTEGER NOT NULL,
          paidDate TEXT,
          reminderDays INTEGER NOT NULL,
          isActive INTEGER NOT NULL,
          recurringPattern TEXT,
          nextDueDate TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE $_financialGoalsTable (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          targetAmount REAL NOT NULL,
          currentAmount REAL NOT NULL,
          targetDate TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          goalType TEXT NOT NULL,
          accountId TEXT,
          isActive INTEGER NOT NULL,
          category TEXT,
          color TEXT
        )
      ''');
    }

    if (oldVersion < 4) {
      // Fix budgets table - rename amount to limit
      await db.execute('ALTER TABLE $_budgetsTable RENAME TO budgets_old');
      await db.execute('''
        CREATE TABLE $_budgetsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          "limit" REAL NOT NULL,
          category TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT NOT NULL
        )
      ''');
      await db.execute('''
        INSERT INTO $_budgetsTable (id, name, "limit", category, startDate, endDate)
        SELECT id, name, amount, category, startDate, endDate FROM budgets_old
      ''');
      await db.execute('DROP TABLE budgets_old');

      // Fix loans table - add missing columns and reorder
      await db.execute('ALTER TABLE $_loansTable RENAME TO loans_old');
      await db.execute('''
        CREATE TABLE $_loansTable (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          person TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          dueDate TEXT,
          status TEXT NOT NULL,
          notes TEXT,
          accountId TEXT,
          paymentFrequency TEXT,
          paymentDay INTEGER,
          monthlyPayment REAL,
          paidAmount REAL NOT NULL,
          autoDeduct INTEGER NOT NULL,
          nextPaymentDate TEXT,
          nextPaymentAmount REAL,
          paymentHistory TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        INSERT INTO $_loansTable (id, type, person, amount, date, dueDate, status, notes, accountId, 
                          paymentFrequency, paymentDay, monthlyPayment, paidAmount, autoDeduct, 
                          nextPaymentDate, nextPaymentAmount, paymentHistory, createdAt)
        SELECT id, type, person, amount, date, dueDate, status, notes, accountId,
               paymentFrequency, paymentDay, 0.0, paidAmount, autoDeduct,
               nextPaymentDate, nextPaymentAmount, paymentHistory, createdAt
        FROM loans_old
      ''');
      await db.execute('DROP TABLE loans_old');

      // Create indexes for better performance
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_type ON $_transactionsTable(type)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_account ON $_transactionsTable(accountId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_date ON $_transactionsTable(date)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_category ON $_transactionsTable(category)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_accounts_type ON $_accountsTable(type)',
      );
    }

    if (oldVersion < 5) {
      // Add limit column to accounts table
      await db.execute('ALTER TABLE $_accountsTable ADD COLUMN "limit" REAL');

      // Create categories table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_categoriesTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon TEXT NOT NULL,
          color TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          isDefault INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create index for categories
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_categories_type ON $_categoriesTable(type)',
      );
    }

    if (oldVersion < 6) {
      // Create overall budgets table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_overallBudgetsTable (
          id TEXT PRIMARY KEY,
          "limit" REAL NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT NOT NULL,
          name TEXT NOT NULL,
          isActive INTEGER NOT NULL
        )
      ''');
    }
  }

  // Transaction methods
  static Future<List<Transaction>> getTransactions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _transactionsTable,
      );
      return List.generate(maps.length, (i) {
        return Transaction(
          id: maps[i]['id'],
          title: maps[i]['title'],
          amount: maps[i]['amount'],
          date: DateTime.parse(maps[i]['date']),
          category: maps[i]['category'],
          type: maps[i]['type'],
          accountId: maps[i]['accountId'],
          notes: maps[i]['notes'],
          transferId: maps[i]['transferId'],
          toAccountId: maps[i]['toAccountId'],
        );
      });
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to get transactions: $e',
        context: 'DatabaseService.getTransactions',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> addTransaction(Transaction transaction) async {
    try {
      final db = await database;
      await db.insert(
        _transactionsTable,
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      ErrorService.logError(
        'Failed to add transaction: $e',
        context: 'DatabaseService.addTransaction',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update(
      _transactionsTable,
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Account methods
  static Future<List<Account>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_accountsTable);
    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        name: maps[i]['name'],
        balance: maps[i]['balance'],
        type: maps[i]['type'],
        icon: maps[i]['icon'],
        limit: maps[i]['limit'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
      );
    });
  }

  static Future<void> addAccount(Account account) async {
    final db = await database;
    await db.insert(
      _accountsTable,
      account.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update(
      _accountsTable,
      account.toJson(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  static Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete(_accountsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Category methods
  static Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_categoriesTable);
    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  static Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _categoriesTable,
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  static Future<void> addCategory(Category category) async {
    final db = await database;
    await db.insert(
      _categoriesTable,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      _categoriesTable,
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(_categoriesTable, where: 'id = ?', whereArgs: [id]);
  }

  // Budget methods
  static Future<List<Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_budgetsTable);
    return List.generate(maps.length, (i) {
      return Budget.fromJson(maps[i]);
    });
  }

  static Future<void> addBudget(Budget budget) async {
    final db = await database;
    await db.insert(
      _budgetsTable,
      budget.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update(
      _budgetsTable,
      budget.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(_budgetsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Overall Budget methods
  static Future<List<OverallBudget>> getOverallBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _overallBudgetsTable,
    );
    return List.generate(maps.length, (i) {
      return OverallBudget.fromJson(maps[i]);
    });
  }

  static Future<void> addOverallBudget(OverallBudget budget) async {
    final db = await database;
    await db.insert(
      _overallBudgetsTable,
      budget.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateOverallBudget(OverallBudget budget) async {
    final db = await database;
    await db.update(
      _overallBudgetsTable,
      budget.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<void> deleteOverallBudget(String id) async {
    final db = await database;
    await db.delete(_overallBudgetsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Group methods
  static Future<List<Group>> getGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_groupsTable);
    return List.generate(maps.length, (i) {
      return Group.fromJson(maps[i]);
    });
  }

  static Future<void> addGroup(Group group) async {
    final db = await database;
    await db.insert(
      _groupsTable,
      group.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateGroup(Group group) async {
    final db = await database;
    await db.update(
      _groupsTable,
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  static Future<void> deleteGroup(String id) async {
    final db = await database;
    await db.delete(_groupsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Migration method from SharedPreferences to SQLite
  static Future<void> migrateFromSharedPreferences({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required List<Budget> budgets,
    required List<Group> groups,
  }) async {
    // Add all existing data to the database
    for (final transaction in transactions) {
      await addTransaction(transaction);
    }

    for (final account in accounts) {
      await addAccount(account);
    }

    for (final budget in budgets) {
      await addBudget(budget);
    }

    for (final group in groups) {
      await addGroup(group);
    }
  }

  // Loan methods
  static Future<List<Loan>> getLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_loansTable);
    return List.generate(maps.length, (i) {
      final map = maps[i];
      // Convert payment history from JSON string to List
      List<LoanPayment> paymentHistory = [];
      if (map['paymentHistory'] != null) {
        try {
          final List<dynamic> historyList = jsonDecode(map['paymentHistory']);
          paymentHistory = historyList
              .map((p) => LoanPayment.fromJson(p))
              .toList();
        } catch (e) {
          // If parsing fails, use empty list
          paymentHistory = [];
        }
      }

      return Loan(
        id: map['id'],
        type: map['type'],
        person: map['person'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
        status: map['status'],
        notes: map['notes'],
        accountId: map['accountId'],
        paymentFrequency: map['paymentFrequency'],
        paymentDay: map['paymentDay'],
        monthlyPayment: map['monthlyPayment'],
        paidAmount: map['paidAmount'] ?? 0.0,
        paymentHistory: paymentHistory,
        autoDeduct: map['autoDeduct'] == 1,
        nextPaymentDate: map['nextPaymentDate'] != null
            ? DateTime.parse(map['nextPaymentDate'])
            : null,
      );
    });
  }

  static Future<void> addLoan(Loan loan) async {
    final db = await database;
    final loanData = loan.toJson();
    // Convert payment history to JSON string for SQLite storage
    loanData['paymentHistory'] = jsonEncode(
      loan.paymentHistory.map((p) => p.toJson()).toList(),
    );
    await db.insert(
      _loansTable,
      loanData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateLoan(Loan loan) async {
    final db = await database;
    final loanData = loan.toJson();
    // Convert payment history to JSON string for SQLite storage
    loanData['paymentHistory'] = jsonEncode(
      loan.paymentHistory.map((p) => p.toJson()).toList(),
    );
    await db.update(
      _loansTable,
      loanData,
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  static Future<void> deleteLoan(String id) async {
    final db = await database;
    await db.delete(_loansTable, where: 'id = ?', whereArgs: [id]);
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete the database file to force recreation
    try {
      final io.Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, _dbName);
      final file = io.File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors if file doesn't exist
    }
  }
}
