import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendwise/models/loan.dart'; // Changed from PersonalTransaction
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';

class AddPaymentDialog extends StatefulWidget {
  final Loan loan; // Changed from PersonalTransaction

  const AddPaymentDialog({super.key, required this.loan}); // Changed from transaction

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _paymentAmount;
  String? _selectedAccountId;
  String? _notes;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _paymentAmount = widget.loan.remainingAmount; // Changed from transaction
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await DataService.getAccounts();
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _addPayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final payment = LoanPayment( // Changed from PersonalPayment
        amount: _paymentAmount,
        date: DateTime.now(),
        notes: _notes,
        accountId: _selectedAccountId,
      );

      Navigator.pop(context, payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return AlertDialog(
      title: Text('Add Payment for ${widget.loan.person}'), // Changed from transaction.personName
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remaining Amount: ${currencyProvider.currencySymbol}${widget.loan.remainingAmount.toStringAsFixed(2)}', // Changed from transaction.remainingAmount
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '${currencyProvider.currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
              initialValue: _paymentAmount.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > widget.loan.remainingAmount) { // Changed from transaction.remainingAmount
                  return 'Amount cannot exceed remaining amount';
                }
                return null;
              },
              onSaved: (value) => _paymentAmount = double.parse(value ?? '0'),
            ),
            const SizedBox(height: 16),
            if (_accounts.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Account (Optional)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedAccountId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No Account'),
                  ),
                  ..._accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSaved: (value) => _notes = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addPayment,
          child: const Text('Add Payment'),
        ),
      ],
    );
  }
}