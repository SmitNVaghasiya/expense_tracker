import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/services/app_state.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/group.dart';

void main() {
  group('AppState Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    group('Initial State', () {
      test('should have empty lists initially', () {
        expect(appState.transactions, isEmpty);
        expect(appState.accounts, isEmpty);
        expect(appState.budgets, isEmpty);
        expect(appState.groups, isEmpty);
      });

      test('should not be loading initially', () {
        expect(appState.isLoading, isFalse);
        expect(appState.isLoadingTransactions, isFalse);
        expect(appState.isLoadingAccounts, isFalse);
        expect(appState.isLoadingBudgets, isFalse);
        expect(appState.isLoadingGroups, isFalse);
      });

      test('should not have errors initially', () {
        expect(appState.hasErrors, isFalse);
        expect(appState.transactionsError, isNull);
        expect(appState.accountsError, isNull);
        expect(appState.budgetsError, isNull);
        expect(appState.groupsError, isNull);
      });
    });

    group('Transaction Filtering', () {
      late List<Transaction> testTransactions;

      setUp(() {
        testTransactions = [
          Transaction(
            id: '1',
            title: 'Salary',
            amount: 5000.0,
            date: DateTime.now(),
            category: 'Income',
            type: 'income',
          ),
          Transaction(
            id: '2',
            title: 'Groceries',
            amount: 100.0,
            date: DateTime.now(),
            category: 'Food',
            type: 'expense',
          ),
          Transaction(
            id: '3',
            title: 'Rent',
            amount: 1500.0,
            date: DateTime.now(),
            category: 'Housing',
            type: 'expense',
          ),
        ];
      });

      test('should filter expenses correctly', () {
        // Simulate loading transactions
        appState.transactions = testTransactions;

        final expenses = appState.getExpenses();
        expect(expenses.length, equals(2));
        expect(expenses.every((t) => t.type == 'expense'), isTrue);
      });

      test('should filter income correctly', () {
        // Simulate loading transactions
        appState.transactions = testTransactions;

        final income = appState.getIncome();
        expect(income.length, equals(1));
        expect(income.every((t) => t.type == 'income'), isTrue);
      });

      test('should filter transactions by date range', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        testTransactions = [
          Transaction(
            id: '1',
            title: 'Today',
            amount: 100.0,
            date: now,
            category: 'Test',
            type: 'expense',
          ),
          Transaction(
            id: '2',
            title: 'Yesterday',
            amount: 200.0,
            date: yesterday,
            category: 'Test',
            type: 'expense',
          ),
          Transaction(
            id: '3',
            title: 'Tomorrow',
            amount: 300.0,
            date: tomorrow,
            category: 'Test',
            type: 'expense',
          ),
        ];

        appState.transactions = testTransactions;

        final filtered = appState.getTransactionsByDateRange(
          yesterday,
          tomorrow,
        );
        expect(filtered.length, equals(3));
      });

      test('should filter transactions by category', () {
        appState.transactions = testTransactions;

        final foodTransactions = appState.getTransactionsByCategory('Food');
        expect(foodTransactions.length, equals(1));
        expect(foodTransactions.first.category, equals('Food'));
      });
    });

    group('Account Management', () {
      late List<Account> testAccounts;

      setUp(() {
        testAccounts = [
          Account(
            id: '1',
            name: 'Checking',
            balance: 1000.0,
            type: 'bank',
            createdAt: DateTime.now(),
          ),
          Account(
            id: '2',
            name: 'Savings',
            balance: 5000.0,
            type: 'bank',
            createdAt: DateTime.now(),
          ),
        ];
      });

      test('should find account by ID', () {
        appState.accounts = testAccounts;

        final account = appState.getAccountById('1');
        expect(account, isNotNull);
        expect(account!.name, equals('Checking'));
      });

      test('should return null for non-existent account', () {
        appState.accounts = testAccounts;

        final account = appState.getAccountById('999');
        expect(account, isNull);
      });
    });

    group('Budget Management', () {
      late List<Budget> testBudgets;

      setUp(() {
        testBudgets = [
          Budget(
            id: '1',
            name: 'Monthly Budget',
            limit: 2000.0,
            category: 'General',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 30)),
          ),
        ];
      });

      test('should find budget by ID', () {
        appState.budgets = testBudgets;

        final budget = appState.getBudgetById('1');
        expect(budget, isNotNull);
        expect(budget!.name, equals('Monthly Budget'));
      });

      test('should return null for non-existent budget', () {
        appState.budgets = testBudgets;

        final budget = appState.getBudgetById('999');
        expect(budget, isNull);
      });
    });

    group('Group Management', () {
      late List<Group> testGroups;

      setUp(() {
        testGroups = [
          Group(
            id: '1',
            name: 'Family',
            description: 'Family expenses',
            createdAt: DateTime.now(),
          ),
        ];
      });

      test('should find group by ID', () {
        appState.groups = testGroups;

        final group = appState.getGroupById('1');
        expect(group, isNotNull);
        expect(group!.name, equals('Family'));
      });

      test('should return null for non-existent group', () {
        appState.groups = testGroups;

        final group = appState.getGroupById('999');
        expect(group, isNull);
      });
    });

    group('Error Handling', () {
      test('should clear all errors', () {
        // Simulate errors
        appState.transactionsError = 'Test error';
        appState.accountsError = 'Test error';
        appState.budgetsError = 'Test error';
        appState.groupsError = 'Test error';

        expect(appState.hasErrors, isTrue);

        appState.clearAllErrors();

        expect(appState.hasErrors, isFalse);
        expect(appState.transactionsError, isNull);
        expect(appState.accountsError, isNull);
        expect(appState.budgetsError, isNull);
        expect(appState.groupsError, isNull);
      });
    });
  });
}
