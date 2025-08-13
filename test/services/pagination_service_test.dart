// import 'package:flutter_test/flutter_test.dart';
// import 'package:spendwise/services/pagination_service.dart';
// import 'package:spendwise/models/transaction.dart';

// void main() {
//   group('PaginationService Tests', () {
//     late List<Transaction> testTransactions;
//     late PaginationService<Transaction> paginationService;

//     setUp(() {
//       testTransactions = List.generate(
//         50,
//         (index) => Transaction(
//           id: 'transaction_$index',
//           title: 'Transaction $index',
//           amount: (index + 1) * 10.0,
//           date: DateTime.now().subtract(Duration(days: index)),
//           category: 'Test',
//           type: index % 2 == 0 ? 'expense' : 'income',
//         ),
//       );
//     });

//     group('Basic Pagination', () {
//       test('should initialize with correct page size', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         expect(paginationService.pageSize, equals(10));
//         expect(paginationService.totalItems, equals(50));
//         expect(paginationService.totalPages, equals(5));
//       });

//       test('should return correct current page items', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         final currentItems = paginationService.currentPageItems;
//         expect(currentItems.length, equals(10));
//         expect(currentItems.first.id, equals('transaction_0'));
//         expect(currentItems.last.id, equals('transaction_9'));
//       });

//       test('should load next page correctly', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         final nextPageItems = paginationService.loadNextPage();
//         expect(nextPageItems.length, equals(10));
//         expect(nextPageItems.first.id, equals('transaction_10'));
//         expect(nextPageItems.last.id, equals('transaction_19'));
//         expect(paginationService.currentPage, equals(1));
//       });

//       test('should handle last page correctly', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         // Go to last page (5 pages total, so 4 calls to loadNextPage)
//         for (int i = 0; i < 4; i++) {
//           paginationService.loadNextPage();
//         }
//         // Now we're on the last page, calling loadNextPage again should return empty
//         final lastPageItems = paginationService.loadNextPage();
//         expect(lastPageItems.length, equals(0)); // No more items
//         expect(paginationService.hasMoreItems, isFalse);
//       });

//       test('should reset pagination correctly', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         paginationService.loadNextPage();
//         expect(paginationService.currentPage, equals(1));

//         paginationService.reset();
//         expect(paginationService.currentPage, equals(0));
//         expect(paginationService.hasMoreItems, isTrue);
//       });
//     });

//     group('TransactionPaginationService Tests', () {
//       late TransactionPaginationService transactionPaginationService;

//       setUp(() {
//         transactionPaginationService = TransactionPaginationService(
//           testTransactions,
//           pageSize: 10,
//         );
//       });

//       test('should filter expenses correctly', () {
//         final expenses = transactionPaginationService.getExpenses();
//         expect(expenses.length, equals(10)); // First page of expenses
//         expect(expenses.every((t) => t.type == 'expense'), isTrue);
//       });

//       test('should filter income correctly', () {
//         final income = transactionPaginationService.getIncome();
//         expect(income.length, equals(10)); // First page of income
//         expect(income.every((t) => t.type == 'income'), isTrue);
//       });

//       test('should filter by date range correctly', () {
//         final now = DateTime.now();
//         final startDate = now.subtract(const Duration(days: 10));
//         final endDate = now.subtract(const Duration(days: 5));

//         final filtered = transactionPaginationService
//             .getTransactionsByDateRange(startDate, endDate);
//         expect(
//           filtered.length,
//           equals(7),
//         ); // 7 transactions in range (days 5-10)
//       });

//       test('should filter by category correctly', () {
//         final filtered = transactionPaginationService.getTransactionsByCategory(
//           'Test',
//         );
//         expect(filtered.length, equals(10)); // First page
//         expect(filtered.every((t) => t.category == 'Test'), isTrue);
//       });

//       test('should get recent transactions correctly', () {
//         final recent = transactionPaginationService.getRecentTransactions();
//         expect(recent.length, equals(10)); // First page of recent transactions
//         expect(
//           recent.every(
//             (t) => t.date.isAfter(
//               DateTime.now().subtract(const Duration(days: 30)),
//             ),
//           ),
//           isTrue,
//         );
//       });

//       test('should get transactions by month correctly', () {
//         final now = DateTime.now();
//         final monthTransactions = transactionPaginationService
//             .getTransactionsByMonth(now.year, now.month);
//         expect(
//           monthTransactions.length,
//           equals(2),
//         ); // Only 2 transactions in current month
//         expect(
//           monthTransactions.every(
//             (t) => t.date.year == now.year && t.date.month == now.month,
//           ),
//           isTrue,
//         );
//       });

//       test('should get transactions by year correctly', () {
//         final now = DateTime.now();
//         final yearTransactions = transactionPaginationService
//             .getTransactionsByYear(now.year);
//         expect(yearTransactions.length, equals(10)); // First page
//         expect(yearTransactions.every((t) => t.date.year == now.year), isTrue);
//       });

//       test('should calculate summary correctly', () {
//         final summary = transactionPaginationService.getSummary();
//         expect(summary['totalTransactions'], equals(50));
//         expect(summary['expenseCount'], equals(25));
//         expect(summary['incomeCount'], equals(25));
//         expect(
//           summary['totalExpenses'],
//           equals(6250.0),
//         ); // Sum of even indices * 10 (0,2,4,6,8...48) * 10
//         expect(
//           summary['totalIncome'],
//           equals(6500.0),
//         ); // Sum of odd indices * 10 (1,3,5,7,9...49) * 10
//         expect(summary['netAmount'], equals(250.0)); // 6500 - 6250
//       });

//       test('should calculate current page summary correctly', () {
//         final summary = transactionPaginationService.getCurrentPageSummary();
//         expect(summary['totalTransactions'], equals(10));
//         expect(summary['expenseCount'], equals(5));
//         expect(summary['incomeCount'], equals(5));
//       });
//     });

//     group('Edge Cases', () {
//       test('should handle empty list', () {
//         paginationService = PaginationService([], pageSize: 10);
//         expect(paginationService.currentPageItems, isEmpty);
//         expect(paginationService.totalPages, equals(0));
//         expect(paginationService.hasMoreItems, isFalse);
//       });

//       test('should handle list smaller than page size', () {
//         final smallList = testTransactions.take(5).toList();
//         paginationService = PaginationService(smallList, pageSize: 10);
//         expect(paginationService.currentPageItems.length, equals(5));
//         expect(paginationService.totalPages, equals(1));
//         expect(paginationService.hasMoreItems, isFalse);
//       });

//       test('should handle exact page size', () {
//         final exactList = testTransactions.take(10).toList();
//         paginationService = PaginationService(exactList, pageSize: 10);
//         expect(paginationService.currentPageItems.length, equals(10));
//         expect(paginationService.totalPages, equals(1));
//         expect(paginationService.hasMoreItems, isFalse);
//       });

//       test('should go to specific page correctly', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         final page2Items = paginationService.goToPage(2);
//         expect(paginationService.currentPage, equals(2));
//         expect(page2Items.length, equals(10));
//         expect(page2Items.first.id, equals('transaction_20'));
//       });

//       test('should handle invalid page numbers', () {
//         paginationService = PaginationService(testTransactions, pageSize: 10);
//         final invalidPageItems = paginationService.goToPage(-1);
//         expect(invalidPageItems, isEmpty);

//         final outOfRangeItems = paginationService.goToPage(10);
//         expect(outOfRangeItems, isEmpty);
//       });
//     });
//   });
// }
