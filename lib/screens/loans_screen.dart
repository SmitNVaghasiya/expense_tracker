import 'package:flutter/material.dart';
import 'package:expense_tracker/models/loan.dart';
import 'package:expense_tracker/models/account.dart';
import 'package:expense_tracker/services/loan_service.dart';
import 'package:expense_tracker/services/data_service.dart';
import 'package:expense_tracker/screens/add_loan_screen.dart';
import 'package:expense_tracker/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Loan> _loans = [];
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loans = await LoanService.getLoans();
      final accounts = await DataService.getAccounts();
      setState(() {
        _loans = loans;
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading loans: $e')),
        );
      }
    }
  }

  Future<void> _addLoan(Loan loan) async {
    try {
      await LoanService.addLoan(loan);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding loan: $e')),
        );
      }
    }
  }

  Future<void> _updateLoan(Loan loan) async {
    try {
      await LoanService.updateLoan(loan);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating loan: $e')),
        );
      }
    }
  }

  Future<void> _deleteLoan(String id) async {
    try {
      await LoanService.deleteLoan(id);
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

  void _navigateToAddLoan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLoanScreen(),
      ),
    );

    if (result != null && result is Loan) {
      await _addLoan(result);
    }
  }

  void _navigateToEditLoan(Loan loan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(loan: loan),
      ),
    );

    if (result != null && result is Loan) {
      await _updateLoan(result);
    }
  }

  void _showDeleteConfirmation(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text(
            'Are you sure you want to delete this loan record for ${loan.person}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLoan(loan.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(Loan loan) {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    double paymentAmount = loan.nextPaymentAmount;
    String? selectedAccountId = loan.accountId;
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment for ${loan.person}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remaining Amount: ${currencyProvider.currencySymbol}${loan.remainingAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '${currencyProvider.currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
              initialValue: paymentAmount.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                paymentAmount = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            if (_accounts.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                value: selectedAccountId,
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedAccountId = value;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              controller: notesController,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (paymentAmount > 0 && paymentAmount <= loan.remainingAmount) {
                final payment = LoanPayment(
                  amount: paymentAmount,
                  date: DateTime.now(),
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                  accountId: selectedAccountId,
                );
                
                await LoanService.addPayment(loan.id, payment);
                Navigator.pop(context);
                await _loadData();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment added successfully')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid payment amount')),
                );
              }
            },
            child: const Text('Add Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Money Lent'),
            Tab(text: 'Money Borrowed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary section
          _buildSummarySection(currencyProvider),
          
          // Loans list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoansList('lent', currencyProvider),
                _buildLoansList('borrowed', currencyProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLoan,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummarySection(CurrencyProvider currencyProvider) {
    final lentLoans = _loans.where((loan) => loan.type == 'lent').toList();
    final borrowedLoans = _loans.where((loan) => loan.type == 'borrowed').toList();
    
    final totalLent = lentLoans.fold(0.0, (sum, loan) => sum + loan.amount);
    final totalBorrowed = borrowedLoans.fold(0.0, (sum, loan) => sum + loan.amount);
    final totalPaidLent = lentLoans.fold(0.0, (sum, loan) => sum + loan.paidAmount);
    final totalPaidBorrowed = borrowedLoans.fold(0.0, (sum, loan) => sum + loan.paidAmount);
    final netPosition = totalLent - totalBorrowed;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Loan Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Lent',
                  '${currencyProvider.currencySymbol}${totalLent.toStringAsFixed(2)}',
                  'Paid: ${currencyProvider.currencySymbol}${totalPaidLent.toStringAsFixed(2)}',
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Borrowed',
                  '${currencyProvider.currencySymbol}${totalBorrowed.toStringAsFixed(2)}',
                  'Paid: ${currencyProvider.currencySymbol}${totalPaidBorrowed.toStringAsFixed(2)}',
                  Colors.red,
                ),
                _buildSummaryItem(
                  'Net',
                  '${currencyProvider.currencySymbol}${netPosition.toStringAsFixed(2)}',
                  '',
                  netPosition >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String subtitle, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
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

  Widget _buildLoansList(String type, CurrencyProvider currencyProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loans = _loans.where((loan) => loan.type == type).toList();
    
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'lent' ? Icons.arrow_upward : Icons.arrow_downward,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'lent' 
                  ? 'No money lent yet' 
                  : 'No money borrowed yet',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
    final isOverdue = loan.isOverdue;
    final isNextPaymentDue = loan.isNextPaymentDue;
    final accountName = _getAccountName(loan.accountId);
        
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: loan.type == 'lent' 
              ? (isOverdue ? Colors.red : Colors.green) 
              : (isOverdue ? Colors.red : Colors.orange),
          child: Icon(
            loan.type == 'lent' ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(
          loan.person,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red : null,
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
            Text(
              'Remaining: ${currencyProvider.currencySymbol}${loan.remainingAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: loan.remainingAmount > 0 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
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
            if (loan.paymentFrequency != null && loan.paymentFrequency != 'one-time') ...[
              const SizedBox(height: 4),
              Text(
                'Payment: ${loan.paymentFrequency!.replaceAll('-', ' ').toUpperCase()}',
                style: const TextStyle(color: Colors.blue),
              ),
              if (loan.nextPaymentDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Next: ${DateFormat('MMM dd, yyyy').format(loan.nextPaymentDate!)}',
                  style: TextStyle(
                    color: isNextPaymentDue ? Colors.red : Colors.blue,
                    fontWeight: isNextPaymentDue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ],
            if (loan.dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(loan.dueDate!)}',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.blue,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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
                color: loan.status == 'repaid' 
                    ? Colors.green 
                    : (isOverdue ? Colors.red : Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loan.status == 'repaid' 
                    ? 'Repaid' 
                    : (isOverdue ? 'Overdue' : 'Pending'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            if (loan.status == 'pending' && loan.remainingAmount > 0) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showAddPaymentDialog(loan),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('Pay', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
        onTap: () => _navigateToEditLoan(loan),
        onLongPress: () => _showDeleteConfirmation(loan),
      ),
    );
  }

  String _getAccountName(String? accountId) {
    if (accountId == null) return 'Unknown';
    final account = _accounts.firstWhere(
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
}