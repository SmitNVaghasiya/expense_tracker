import 'package:flutter/material.dart';
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class LoanDetailsScreen extends StatefulWidget {
  final Loan loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  late Loan _currentLoan;
  List<Map<String, dynamic>> _amortizationSchedule = [];
  Map<String, dynamic> _simulationResult = {};

  final TextEditingController _extraPaymentAmountController = TextEditingController();
  String _extraPaymentFrequency = 'one-time';

  @override
  void initState() {
    super.initState();
    _currentLoan = widget.loan;
    _generateSchedule();
  }

  @override
  void dispose() {
    _extraPaymentAmountController.dispose();
    super.dispose();
  }

  void _generateSchedule() {
    if (_currentLoan.loanCategory == 'formal' &&
        _currentLoan.amount > 0 &&
        _currentLoan.interestRate != null &&
        _currentLoan.termInMonths != null) {
      _amortizationSchedule = LoanService.generateAmortizationSchedule(
        principal: _currentLoan.amount,
        annualInterestRate: _currentLoan.interestRate!,
        termInMonths: _currentLoan.termInMonths!,
        startDate: _currentLoan.date,
      );
    } else {
      _amortizationSchedule = [];
    }
  }

  void _simulateExtraPayment() {
    final extraAmount = double.tryParse(_extraPaymentAmountController.text) ?? 0.0;

    if (extraAmount > 0 &&
        _currentLoan.loanCategory == 'formal' &&
        _currentLoan.amount > 0 &&
        _currentLoan.interestRate != null &&
        _currentLoan.termInMonths != null) {
      _simulationResult = LoanService.simulateExtraPayment(
        principal: _currentLoan.amount,
        annualInterestRate: _currentLoan.interestRate!,
        termInMonths: _currentLoan.termInMonths!,
        extraPaymentAmount: extraAmount,
        extraPaymentFrequency: _extraPaymentFrequency,
      );
      setState(() {}); // Update UI with simulation results
    } else {
      setState(() {
        _simulationResult = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${_currentLoan.person}'s Loan Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Loan Details
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${_currentLoan.type.capitalize()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Category: ${_currentLoan.loanCategory.capitalize()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Amount: ${currencyProvider.currencySymbol}${_currentLoan.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Date: ${DateFormat.yMd().format(_currentLoan.date)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_currentLoan.dueDate != null)
                      Text(
                        'Due Date: ${DateFormat.yMd().format(_currentLoan.dueDate!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    Text(
                      'Status: ${_currentLoan.status.capitalize()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_currentLoan.notes != null && _currentLoan.notes!.isNotEmpty)
                      Text(
                        'Notes: ${_currentLoan.notes}',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),

            // Formal Loan Specific Details
            if (_currentLoan.loanCategory == 'formal') ...[
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Formal Loan Specifics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_currentLoan.interestRate != null)
                        Text(
                          'Interest Rate: ${_currentLoan.interestRate!.toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (_currentLoan.termInMonths != null)
                        Text(
                          'Term: ${_currentLoan.termInMonths} months',
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (_currentLoan.monthlyPayment != null)
                        Text(
                          'Monthly Payment (EMI): ${currencyProvider.currencySymbol}${_currentLoan.monthlyPayment!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),

              // Amortization Schedule
              if (_amortizationSchedule.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amortization Schedule',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300, // Fixed height for scrollable table
                          child: ListView(
                            children: [
                              DataTable(
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(label: Text('Pmt#')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Principal')),
                                  DataColumn(label: Text('Interest')),
                                  DataColumn(label: Text('Balance')),
                                ],
                                rows: _amortizationSchedule.map((entry) {
                                  return DataRow(cells: [
                                    DataCell(Text(entry['paymentNumber'].toString())),
                                    DataCell(Text(DateFormat.yMd().format(DateTime.parse(entry['paymentDate'])))),
                                    DataCell(Text(entry['principalPaid'].toStringAsFixed(2))),
                                    DataCell(Text(entry['interestPaid'].toStringAsFixed(2))),
                                    DataCell(Text(entry['endingBalance'].toStringAsFixed(2))),
                                  ]);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Extra Payment Simulator
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Extra Payment Simulator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _extraPaymentAmountController,
                        decoration: InputDecoration(
                          labelText: 'Extra Payment Amount',
                          prefixText: '${currencyProvider.currencySymbol} ',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _extraPaymentFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'one-time', child: Text('One-time')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _extraPaymentFrequency = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _simulateExtraPayment,
                        child: const Text('Simulate'),
                      ),
                      const SizedBox(height: 20),
                      if (_simulationResult.isNotEmpty) ...[
                        const Text(
                          'Simulation Results:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'New Term: ${_simulationResult['newTermInMonths']} months',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Total Interest Saved: ${currencyProvider.currencySymbol}${_simulationResult['totalInterestSaved']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Original Total Payments: ${currencyProvider.currencySymbol}${_simulationResult['originalTotalPayments']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'New Total Payments: ${currencyProvider.currencySymbol}${_simulationResult['newTotalPayments']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}