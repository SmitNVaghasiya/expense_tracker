import 'package:flutter/material.dart';
import 'package:spendwise/models/personal_transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PersonalTransactionDetailsScreen extends StatefulWidget {
  final PersonalTransaction transaction;

  const PersonalTransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<PersonalTransactionDetailsScreen> createState() => _PersonalTransactionDetailsScreenState();
}

class _PersonalTransactionDetailsScreenState extends State<PersonalTransactionDetailsScreen> {
  Account? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  Future<void> _loadAccountDetails() async {
    if (widget.transaction.accountId != null) {
      try {
        final accounts = await DataService.getAccounts();
        final account = accounts.firstWhere(
          (acc) => acc.id == widget.transaction.accountId,
          orElse: () => Account(
            id: 'unknown',
            name: 'Unknown Account',
            balance: 0,
            type: 'unknown',
            createdAt: DateTime.now(),
          ),
        );
        setState(() {
          _account = account;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final transaction = widget.transaction;

    return Scaffold(
      appBar: AppBar(
        title: Text('${transaction.type == 'lent' ? 'Lent' : 'Borrowed'} Details'),
        backgroundColor: transaction.type == 'lent' ? Colors.green : Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _buildHeaderCard(currencyProvider, transaction),
                  const SizedBox(height: 20),

                  // Basic details
                  _buildBasicDetailsCard(currencyProvider, transaction),
                  const SizedBox(height: 20),

                  // Interest details (if applicable)
                  if (transaction.interestRate != null) ...[
                    _buildInterestDetailsCard(currencyProvider, transaction),
                    const SizedBox(height: 20),
                  ],

                  // Account details (if applicable)
                  if (transaction.accountId != null && _account != null) ...[
                    _buildAccountDetailsCard(currencyProvider, _account!),
                    const SizedBox(height: 20),
                  ],

                  // Notes (if applicable)
                  if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                    _buildNotesCard(transaction.notes!),
                    const SizedBox(height: 20),
                  ],

                  // Payment history
                  if (transaction.paymentHistory.isNotEmpty) ...[
                    _buildPaymentHistoryCard(currencyProvider, transaction),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(CurrencyProvider currencyProvider, PersonalTransaction transaction) {
    final isLent = transaction.type == 'lent';
    final color = isLent ? Colors.green : Colors.orange;
    final icon = isLent ? Icons.arrow_upward : Icons.arrow_downward;
    final title = isLent ? 'Money Lent' : 'Money Borrowed';

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                transaction.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetailsCard(CurrencyProvider currencyProvider, PersonalTransaction transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Person', transaction.personName),
            _buildDetailRow('Amount', '${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(transaction.date)),
            if (transaction.remainingAmount > 0) ...[
              _buildDetailRow('Remaining', '${currencyProvider.currencySymbol}${transaction.remainingAmount.toStringAsFixed(2)}'),
            ],
            if (transaction.paidAmount > 0) ...[
              _buildDetailRow('Paid', '${currencyProvider.currencySymbol}${transaction.paidAmount.toStringAsFixed(2)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInterestDetailsCard(CurrencyProvider currencyProvider, PersonalTransaction transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interest Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Interest Rate', '${transaction.interestRate}%'),
            _buildDetailRow('Calculation', transaction.interestCalculation?.toUpperCase() ?? ''),
            _buildDetailRow('Duration', '${transaction.durationMonths} months'),
            const Divider(),
            _buildDetailRow('Principal', '${currencyProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Interest Amount', '${currencyProvider.currencySymbol}${transaction.interestAmount.toStringAsFixed(2)}'),
            _buildDetailRow(
              'Total Amount',
              '${currencyProvider.currencySymbol}${transaction.totalAmount.toStringAsFixed(2)}',
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsCard(CurrencyProvider currencyProvider, Account account) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Account Name', account.name),
            _buildDetailRow('Account Type', account.type.toUpperCase()),
            _buildDetailRow('Current Balance', '${currencyProvider.currencySymbol}${account.balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              notes,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard(CurrencyProvider currencyProvider, PersonalTransaction transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...transaction.paymentHistory.map((payment) => _buildPaymentItem(currencyProvider, payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(CurrencyProvider currencyProvider, PersonalPayment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currencyProvider.currencySymbol}${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(payment.date),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty)
                  Text(
                    payment.notes!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
