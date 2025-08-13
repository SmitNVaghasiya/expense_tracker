import 'package:spendwise/models/transaction.dart';

class PaginationService<T> {
  final List<T> _allItems;
  final int pageSize;
  int _currentPage = 0;
  bool _hasMoreItems = true;

  PaginationService(this._allItems, {this.pageSize = 20}) {
    _hasMoreItems = _allItems.length > pageSize;
  }

  // Get current page items
  List<T> get currentPageItems {
    final startIndex = _currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, _allItems.length);
    return _allItems.sublist(startIndex, endIndex);
  }

  // Get all loaded items (all pages loaded so far)
  List<T> get allLoadedItems {
    final endIndex = (_currentPage + 1) * pageSize;
    return _allItems.sublist(0, endIndex.clamp(0, _allItems.length));
  }

  // Check if there are more items to load
  bool get hasMoreItems => _hasMoreItems;

  // Get current page number
  int get currentPage => _currentPage;

  // Get total number of pages
  int get totalPages => (_allItems.length / pageSize).ceil();

  // Get total number of items
  int get totalItems => _allItems.length;

  // Load next page
  List<T> loadNextPage() {
    if (!_hasMoreItems) return [];

    _currentPage++;
    final startIndex = _currentPage * pageSize;

    if (startIndex >= _allItems.length) {
      _hasMoreItems = false;
      return [];
    }

    final endIndex = (startIndex + pageSize).clamp(0, _allItems.length);
    return _allItems.sublist(startIndex, endIndex);
  }

  // Reset pagination
  void reset() {
    _currentPage = 0;
    _hasMoreItems = _allItems.length > pageSize;
  }

  // Go to specific page
  List<T> goToPage(int page) {
    if (page < 0 || page >= totalPages) return [];

    _currentPage = page;
    final startIndex = _currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, _allItems.length);

    _hasMoreItems = endIndex < _allItems.length;
    return _allItems.sublist(startIndex, endIndex);
  }

  // Check if current page is the last page
  bool get isLastPage => _currentPage >= totalPages - 1;

  // Get page info
  Map<String, dynamic> get pageInfo {
    return {
      'currentPage': _currentPage + 1,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': pageSize,
      'hasMoreItems': _hasMoreItems,
      'isLastPage': isLastPage,
    };
  }
}

// Specialized pagination service for transactions
class TransactionPaginationService extends PaginationService<Transaction> {
  TransactionPaginationService(super.transactions, {super.pageSize});

  // Get transactions by type with pagination
  List<Transaction> getExpenses() {
    final expenses = _allItems.where((t) => t.type == 'expense').toList();
    return PaginationService<Transaction>(
      expenses,
      pageSize: pageSize,
    ).currentPageItems;
  }

  List<Transaction> getIncome() {
    final income = _allItems.where((t) => t.type == 'income').toList();
    return PaginationService<Transaction>(
      income,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get transactions by date range with pagination
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    final filteredTransactions = _allItems
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
    return PaginationService<Transaction>(
      filteredTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get transactions by category with pagination
  List<Transaction> getTransactionsByCategory(String category) {
    final filteredTransactions = _allItems
        .where((t) => t.category == category)
        .toList();
    return PaginationService<Transaction>(
      filteredTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get transactions by account with pagination
  List<Transaction> getTransactionsByAccount(String accountId) {
    final filteredTransactions = _allItems
        .where((t) => t.accountId == accountId)
        .toList();
    return PaginationService<Transaction>(
      filteredTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get recent transactions (last 30 days)
  List<Transaction> getRecentTransactions() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentTransactions = _allItems
        .where((t) => t.date.isAfter(thirtyDaysAgo))
        .toList();
    return PaginationService<Transaction>(
      recentTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get transactions by month
  List<Transaction> getTransactionsByMonth(int year, int month) {
    final filteredTransactions = _allItems
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
    return PaginationService<Transaction>(
      filteredTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get transactions by year
  List<Transaction> getTransactionsByYear(int year) {
    final filteredTransactions = _allItems
        .where((t) => t.date.year == year)
        .toList();
    return PaginationService<Transaction>(
      filteredTransactions,
      pageSize: pageSize,
    ).currentPageItems;
  }

  // Get summary statistics
  Map<String, dynamic> getSummary() {
    final expenses = _allItems.where((t) => t.type == 'expense');
    final income = _allItems.where((t) => t.type == 'income');

    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold(0.0, (sum, t) => sum + t.amount);
    final netAmount = totalIncome - totalExpenses;

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'netAmount': netAmount,
      'totalTransactions': _allItems.length,
      'expenseCount': expenses.length,
      'incomeCount': income.length,
    };
  }

  // Get summary for current page
  Map<String, dynamic> getCurrentPageSummary() {
    final currentItems = currentPageItems;
    final expenses = currentItems.where((t) => t.type == 'expense');
    final income = currentItems.where((t) => t.type == 'income');

    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold(0.0, (sum, t) => sum + t.amount);
    final netAmount = totalIncome - totalExpenses;

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'netAmount': netAmount,
      'totalTransactions': currentItems.length,
      'expenseCount': expenses.length,
      'incomeCount': income.length,
    };
  }
}
