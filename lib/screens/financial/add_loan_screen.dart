import 'package:flutter/material.dart';
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:flutter/services.dart'; // Added for FilteringTextInputFormatter
import 'package:spendwise/services/data_service.dart'; // Added for DataService.getAccounts()
import 'package:spendwise/models/account.dart'; // Added for Account model
import 'package:provider/provider.dart'; // Added for Provider
import 'package:spendwise/services/currency_provider.dart'; // Added for CurrencyProvider


class AddLoanScreen extends StatefulWidget {
  final Loan? loan;

  const AddLoanScreen({super.key, this.loan});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type; // lent or borrowed
  late String _personName; // person or bank name
  late double _amount;
  late DateTime _date;
  String? _notes;
  String? _selectedAccountId;

  // New fields for enhanced Loan model
  late String _loanCategory; // personal or formal
  double? _interestRate; // APR
  int? _termInMonths; // total duration
  String? _paymentFrequency; // monthly, weekly, one-time
  double? _monthlyPayment; // EMI

  List<Account> _accounts = [];

  final List<String> _types = ['lent', 'borrowed'];
  final List<String> _loanCategories = ['personal', 'formal'];
  final List<String> _paymentFrequencies = ['monthly', 'weekly', 'one-time'];

  // Controllers for text fields to add listeners
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _termInMonthsController = TextEditingController();
  final TextEditingController _monthlyPaymentDisplayController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    if (widget.loan != null) {
      _type = widget.loan!.type;
      _personName = widget.loan!.person;
      _amount = widget.loan!.amount;
      _date = widget.loan!.date;
      _notes = widget.loan!.notes;
      _selectedAccountId = widget.loan!.accountId;
      _loanCategory = widget.loan!.loanCategory;
      _interestRate = widget.loan!.interestRate;
      _termInMonths = widget.loan!.termInMonths;
      _paymentFrequency = widget.loan!.paymentFrequency;
      _monthlyPayment = widget.loan!.monthlyPayment;

      // Initialize controllers with existing loan data
      _personController.text = _personName;
      _amountController.text = _amount.toString();
      _interestRateController.text = _interestRate?.toString() ?? '';
      _termInMonthsController.text = _termInMonths?.toString() ?? '';
      _monthlyPaymentDisplayController.text = _monthlyPayment?.toStringAsFixed(2) ?? '';
      _notesController.text = _notes ?? '';

    } else {
      _type = 'lent';
      _personName = '';
      _amount = 0.0;
      _date = DateTime.now();
      _loanCategory = 'personal';
    }

    // Add listeners for EMI calculation
    _amountController.addListener(_calculateEMI);
    _interestRateController.addListener(_calculateEMI);
    _termInMonthsController.addListener(_calculateEMI);
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.removeListener(_calculateEMI);
    _amountController.dispose();
    _interestRateController.removeListener(_calculateEMI);
    _interestRateController.dispose();
    _termInMonthsController.removeListener(_calculateEMI);
    _termInMonthsController.dispose();
    _monthlyPaymentDisplayController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateEMI() {
    if (_loanCategory == 'formal') {
      final principal = double.tryParse(_amountController.text) ?? 0.0;
      final annualInterestRate = double.tryParse(_interestRateController.text) ?? 0.0;
      final termInMonths = int.tryParse(_termInMonthsController.text) ?? 0;

      if (principal > 0 && annualInterestRate >= 0 && termInMonths > 0) {
        final emi = LoanService.calculateMonthlyPayment(
          principal: principal,
          annualInterestRate: annualInterestRate,
          termInMonths: termInMonths,
        );
        setState(() {
          _monthlyPayment = emi;
          _monthlyPaymentDisplayController.text = emi.toStringAsFixed(2);
        });
      } else {
        setState(() {
          _monthlyPayment = null;
          _monthlyPaymentDisplayController.text = '';
        });
      }
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await DataService.getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1800),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final loan = Loan(
        id: widget.loan?.id,
        type: _type,
        person: _personName,
        amount: _amount,
        date: _date,
        notes: _notes,
        accountId: _selectedAccountId,
        loanCategory: _loanCategory,
        interestRate: _interestRate,
        termInMonths: _termInMonths,
        paymentFrequency: _paymentFrequency,
        monthlyPayment: _monthlyPayment, // Use the calculated EMI
      );

      if (widget.loan != null) {
        await LoanService.updateLoan(loan);
      } else {
        await LoanService.addLoan(loan);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan == null ? 'Add Loan' : 'Edit Loan'),
        actions: [
          IconButton(onPressed: _saveLoan, icon: const Icon(Icons.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Category (Personal vs Formal)
              const Text(
                'Loan Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: _loanCategories.map((category) {
                  return Expanded(
                    child: Card(
                      color: _loanCategory == category
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      child: ListTile(
                        title: Text(
                          category == 'personal' ? 'Personal' : 'Formal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _loanCategory == category
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _loanCategory = category;
                            _calculateEMI(); // Recalculate EMI if category changes
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Loan Type (Lent vs Borrowed)
              const Text(
                'Loan Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: _types.map((type) {
                  return Expanded(
                    child: Card(
                      color: _type == type
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      child: ListTile(
                        title: Text(
                          type == 'lent' ? 'Money Lent' : 'Money Borrowed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _type == type
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _type = type;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Person/Bank Name
              TextFormField(
                controller: _personController,
                decoration: InputDecoration(
                  labelText: _loanCategory == 'personal'
                      ? 'Person Name'
                      : 'Bank/Institution Name',
                  hintText: _loanCategory == 'personal'
                      ? 'Enter person name'
                      : 'Enter bank name',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
                onSaved: (value) => _personName = value ?? '',
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixText: '${currencyProvider.currencySymbol} ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value ?? '0'),
              ),
              const SizedBox(height: 20),

              // Account selection
              if (_accounts.isNotEmpty) ...[
                const Text(
                  'Account (Optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Account',
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
                const SizedBox(height: 20),
              ],

              // Formal Loan Fields (Conditional)
              if (_loanCategory == 'formal') ...[
                const Text(
                  'Formal Loan Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Interest Rate (APR)
                TextFormField(
                  controller: _interestRateController,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate (APR %)',
                    hintText: 'Annual Percentage Rate',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter interest rate';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) < 0) {
                      return 'Please enter a valid interest rate';
                    }
                    return null;
                  },
                  onSaved: (value) => _interestRate = double.tryParse(value ?? '0'),
                ),
                const SizedBox(height: 20),

                // Loan Term (Months)
                TextFormField(
                  controller: _termInMonthsController,
                  decoration: const InputDecoration(
                    labelText: 'Loan Term (Months)',
                    hintText: 'Total duration in months',
                    suffixText: 'months',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter loan term';
                    }
                    if (int.tryParse(value) == null ||
                        int.parse(value) <= 0) {
                      return 'Please enter a valid number of months';
                    }
                    return null;
                  },
                  onSaved: (value) => _termInMonths = int.tryParse(value ?? '0'),
                ),
                const SizedBox(height: 20),

                // Payment Frequency
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Frequency',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _paymentFrequency,
                  items: _paymentFrequencies.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentFrequency = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select payment frequency';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Monthly Payment (EMI) - Calculated or entered
                TextFormField(
                  controller: _monthlyPaymentDisplayController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Payment (EMI)',
                    hintText: 'Calculated or enter manually',
                    prefixText: '${currencyProvider.currencySymbol} ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  enabled: false, // This field is for display only
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  onSaved: (value) => _monthlyPayment = double.tryParse(value ?? '0'),
                ),
                const SizedBox(height: 20),
              ],

              // Date
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
            ],
          ),
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
