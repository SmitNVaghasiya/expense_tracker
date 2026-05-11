import 'package:flutter/material.dart';
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/screens/financial/add_loan_screen.dart';
// import 'package:spendwise/screens/financial/personal_transaction_details_screen.dart'; // Removed unused import
import 'package:spendwise/screens/financial/add_payment_dialog.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/screens/financial/base_financial_screen.dart';
import 'package:spendwise/screens/shared/custom_drawer.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/core/performance_mixins.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/screens/financial/loan_details_screen.dart'; // Added import for LoanDetailsScreen

enum LoanTransactionFilter { all, lent, borrowed }

class LoansScreen extends BaseFinancialScreen {
  const LoansScreen({super.key})
    : super(
        screenTitle: 'Personal Money',
        screenIcon: Icons.add,
        primaryColor: Colors.blue,
        floatingActionButtonTooltip: 'Add Transaction',
      );

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen>
    with
        ValueNotifierMixin,
        EfficientListMixin,
        ScrollPerformanceMixin {
  // ValueNotifiers for efficient state management
  late final ValueNotifier<List<Loan>> _loansNotifier;
  late final ValueNotifier<List<Loan>> _filteredLoansNotifier;
  late final ValueNotifier<List<Account>> _accountsNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  late final ValueNotifier<Map<String, dynamic>> _summaryNotifier;
  
  LoanTransactionFilter _transactionFilter = LoanTransactionFilter.all;
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Settled'

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
  }

  void _initializeNotifiers() {
    _loansNotifier = getNotifier('loans', []);
    _filteredLoansNotifier = getNotifier('filteredLoans', []);
    _accountsNotifier = getNotifier('accounts', []);
    _isLoadingNotifier = getNotifier('isLoading', true);
    _summaryNotifier = getNotifier('summary', {});
  }

  Future<void> _loadData() async {
    _isLoadingNotifier.value = true;

    try {
      final loans = await LoanService.getLoans();
      final accounts = await DataService.getAccounts();
      final summary = await LoanService.getLoanStatistics();

      if (mounted) {
        setState(() {
          _loansNotifier.value = loans;
          _accountsNotifier.value = accounts;
          _summaryNotifier.value = summary;
          _isLoadingNotifier.value = false;
        });
        _filterLoans();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNotifier.value = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading loans: $e')),
        );
      }
    }
  }

  void _filterLoans() {
    List<Loan> filtered = _loansNotifier.value;

    // Filter by type (lent/borrowed/all)
    switch (_transactionFilter) {
      case LoanTransactionFilter.lent:
        filtered = filtered.where((l) => l.type == 'lent').toList();
        break;
      case LoanTransactionFilter.borrowed:
        filtered = filtered.where((l) => l.type == 'borrowed').toList();
        break;
      case LoanTransactionFilter.all:
        break;
    }

    // Filter by search query (person name, notes)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((l) =>
        l.person.toLowerCase().contains(q) ||
        (l.notes?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // Filter by status
    if (_statusFilter != 'All') {
      filtered = filtered.where((l) {
        switch (_statusFilter) {
          case 'Active': return l.status == 'pending' || l.remainingAmount > 0;
          case 'Settled': return l.status == 'repaid' || l.remainingAmount <= 0;
          default: return true;
        }
      }).toList();
    }

    _filteredLoansNotifier.value = filtered;
  }

  Future<void> _deleteLoan(Loan loan) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => common_widgets.ConfirmationBottomSheet(
        title: 'Delete Loan',
        message:
            'Are you sure you want to delete "${loan.person}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        icon: Icons.delete_forever,
      ),
    );

    if (confirmed == true) {
      try {
        await LoanService.deleteLoan(loan.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loan deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting loan: $e')),
          );
        }
      }
    }
  }

  void _navigateToLoanDetails(Loan loan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanDetailsScreen(loan: loan),
      ),
    );
  }

  void _showAddPaymentDialog(Loan loan) async {
    final result = await showDialog<LoanPayment>(
      context: context,
      builder: (context) => AddPaymentDialog(loan: loan),
    );

    if (result != null) {
      try {
        await LoanService.addPayment(loan.id, result);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding payment: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoanScreen()),
          );
          if (result == true && mounted) {
            await _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSummarySection(currencyProvider),
          _buildTransactionFilterPills(),
          const SizedBox(height: 16),
          _buildFilterSection(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildLoansList(currencyProvider),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddLoanScreen(),
          ),
        );

        if (result != null && result is bool && result) { // Assuming AddLoanScreen returns true on success
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loan added successfully')),
            );
          }
        }
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildTransactionFilterPills() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterPill('All', LoanTransactionFilter.all, Icons.list),
            const SizedBox(width: 8),
            _buildFilterPill(
              'Lent',
              LoanTransactionFilter.lent,
              Icons.arrow_upward,
            ),
            const SizedBox(width: 8),
            _buildFilterPill(
              'Borrowed',
              LoanTransactionFilter.borrowed,
              Icons.arrow_downward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    String label,
    LoanTransactionFilter filter,
    IconData icon,
  ) {
    final isSelected = _transactionFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionFilter = filter;
          _filterLoans();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search loans...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() { _searchQuery = ''; });
                          _filterLoans();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() { _searchQuery = value; });
                _filterLoans();
              },
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: _statusFilter != 'All'
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter by status',
            onSelected: (value) {
              setState(() { _statusFilter = value; });
              _filterLoans();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Row(children: [
                  const Text('All'),
                  if (_statusFilter == 'All') const Spacer(),
                  if (_statusFilter == 'All') const Icon(Icons.check, size: 16),
                ]),
              ),
              PopupMenuItem(
                value: 'Active',
                child: Row(children: [
                  const Text('Active'),
                  if (_statusFilter == 'Active') const Spacer(),
                  if (_statusFilter == 'Active') const Icon(Icons.check, size: 16),
                ]),
              ),
              PopupMenuItem(
                value: 'Settled',
                child: Row(children: [
                  const Text('Settled'),
                  if (_statusFilter == 'Settled') const Spacer(),
                  if (_statusFilter == 'Settled') const Icon(Icons.check, size: 16),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(CurrencyProvider currencyProvider) {
    final summary = _summaryNotifier.value;
    if (summary.isEmpty) return const SizedBox.shrink();

    final totalLent = summary['totalLent'] ?? 0.0;
    final totalBorrowed = summary['totalBorrowed'] ?? 0.0;
    final netPosition = summary['netPosition'] ?? 0.0;
    final pendingLoans = summary['pendingLoans'] ?? 0; // New field
    final overdueLoans = summary['overdueLoans'] ?? 0; // New field

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Loan Summary', // Changed title
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Lent', // Changed label
                  '${currencyProvider.currencySymbol}${totalLent.toStringAsFixed(2)}',
                  '', // Removed pending lent
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Total Borrowed', // Changed label
                  '${currencyProvider.currencySymbol}${totalBorrowed.toStringAsFixed(2)}',
                  '', // Removed pending borrowed
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Net Position', // Changed label
                  '${currencyProvider.currencySymbol}${netPosition.toStringAsFixed(2)}',
                  '',
                  netPosition >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Pending Loans',
                  pendingLoans.toString(),
                  '',
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Overdue Loans',
                  overdueLoans.toString(),
                  '',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildLoansList(CurrencyProvider currencyProvider) {
    if (_isLoadingNotifier.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final loans = _filteredLoansNotifier.value;

    if (loans.isEmpty) {
      String message;
      IconData icon;
      
      switch (_transactionFilter) {
        case LoanTransactionFilter.lent:
          message = 'No money lent yet';
          icon = Icons.arrow_upward;
          break;
        case LoanTransactionFilter.borrowed:
          message = 'No money borrowed yet';
          icon = Icons.arrow_downward;
          break;
        case LoanTransactionFilter.all:
          message = 'No loans yet';
          icon = Icons.list;
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first loan',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          return _buildLoanItem(loan, currencyProvider);
        },
      ),
    );
  }

  Widget _buildLoanItem(Loan loan, CurrencyProvider currencyProvider) {
    final accountName = _getAccountName(loan.accountId);
    final hasInterest = loan.interestRate != null && loan.interestRate! > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: loan.type == 'lent'
              ? (loan.status == 'repaid' ? Colors.green : Colors.blue)
              : (loan.status == 'repaid' ? Colors.green : Colors.orange),
          child: Icon(
            loan.type == 'lent' ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(
          loan.person,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: loan.status == 'repaid' ? Colors.green : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currencyProvider.currencySymbol}${loan.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (loan.remainingAmount > 0) ...[
              Text(
                'Remaining: ${currencyProvider.currencySymbol}${loan.remainingAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              DateFormat('MMM dd, yyyy').format(loan.date),
              style: const TextStyle(color: Colors.grey),
            ),
            if (loan.accountId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Account: $accountName',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (hasInterest) ...[
              const SizedBox(height: 4),
              Text(
                'Interest Rate: ${loan.interestRate}% ',
                style: const TextStyle(color: Colors.blue),
              ),
              if (loan.monthlyPayment != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Monthly Payment: ${currencyProvider.currencySymbol}${loan.monthlyPayment!.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ],
            if (loan.notes != null && loan.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                loan.notes!,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: loan.status == 'repaid' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loan.status == 'repaid' ? 'Repaid' : 'Pending',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            if (loan.status != 'repaid' && loan.remainingAmount > 0) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showAddPaymentDialog(loan),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('Pay', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
        onTap: () => _navigateToLoanDetails(loan),
        onLongPress: () => _showDeleteConfirmation(loan),
      ),
    );
  }

  String _getAccountName(String? accountId) {
    if (accountId == null) return 'N/A'; // Changed from 'Unknown' to 'N/A' for consistency
    final account = _accountsNotifier.value.firstWhere(
      (account) => account.id == accountId,
      orElse: () => Account(
        id: accountId,
        name: accountId,
        balance: 0,
        type: 'unknown',
        createdAt: DateTime.now(),
      ),
    );
    return account.name;
  }

  void _showDeleteConfirmation(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text(
          'Are you sure you want to delete this loan for ${loan.person}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLoan(loan);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
