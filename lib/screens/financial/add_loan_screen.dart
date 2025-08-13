import 'package:flutter/material.dart';
import 'package:spendwise/models/loan.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/loan_service.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:intl/intl.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:provider/provider.dart';

class AddLoanScreen extends StatefulWidget {
  final Loan? loan;

  const AddLoanScreen({super.key, this.loan});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _person;
  late double _amount;
  late DateTime _date;
  DateTime? _dueDate;
  late String _status;
  String? _notes;

  // New fields
  String? _selectedAccountId;
  String? _paymentFrequency;
  int? _paymentDay;
  double? _monthlyPayment;
  bool _autoDeduct = false;
  List<Account> _accounts = [];

  final List<String> _types = ['lent', 'borrowed'];
  final List<String> _statuses = ['pending', 'repaid'];
  final List<String> _paymentFrequencies = [
    'one-time',
    'monthly',
    'weekly',
    'biweekly',
    'quarterly',
    'yearly',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    if (widget.loan != null) {
      _type = widget.loan!.type;
      _person = widget.loan!.person;
      _amount = widget.loan!.amount;
      _date = widget.loan!.date;
      _dueDate = widget.loan!.dueDate;
      _status = widget.loan!.status;
      _notes = widget.loan!.notes;
      _selectedAccountId = widget.loan!.accountId;
      _paymentFrequency = widget.loan!.paymentFrequency;
      _paymentDay = widget.loan!.paymentDay;
      _monthlyPayment = widget.loan!.monthlyPayment;
      _autoDeduct = widget.loan!.autoDeduct;
    } else {
      _type = 'lent';
      _person = '';
      _amount = 0.0;
      _date = DateTime.now();
      _status = 'pending';
      _paymentFrequency = 'one-time';
      _paymentDay = DateTime.now().day;
    }
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

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate && _dueDate != null ? _dueDate! : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  void _saveLoan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calculate next payment date if payment frequency is set
      DateTime? nextPaymentDate;
      if (_paymentFrequency != null && _paymentFrequency != 'one-time') {
        nextPaymentDate = _calculateNextPaymentDate();
      }

      final loan = Loan(
        id: widget.loan?.id,
        type: _type,
        person: _person,
        amount: _amount,
        date: _date,
        dueDate: _dueDate,
        status: _status,
        notes: _notes,
        accountId: _selectedAccountId,
        paymentFrequency: _paymentFrequency,
        paymentDay: _paymentDay,
        monthlyPayment: _monthlyPayment,
        autoDeduct: _autoDeduct,
        nextPaymentDate: nextPaymentDate,
      );

      Navigator.pop(context, loan);
    }
  }

  DateTime _calculateNextPaymentDate() {
    final now = DateTime.now();
    DateTime nextDate;

    switch (_paymentFrequency) {
      case 'monthly':
        nextDate = DateTime(now.year, now.month, _paymentDay ?? now.day);
        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year, now.month + 1, _paymentDay ?? now.day);
        }
        break;
      case 'weekly':
        nextDate = now.add(const Duration(days: 7));
        break;
      case 'biweekly':
        nextDate = now.add(const Duration(days: 14));
        break;
      case 'quarterly':
        nextDate = DateTime(now.year, now.month + 3, _paymentDay ?? now.day);
        break;
      case 'yearly':
        nextDate = DateTime(now.year + 1, now.month, _paymentDay ?? now.day);
        break;
      default:
        nextDate = now;
    }

    return nextDate;
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
              // Loan type
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

              // Person name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Person',
                  hintText: 'Enter person name',
                  border: OutlineInputBorder(),
                ),
                initialValue: _person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter person name';
                  }
                  return null;
                },
                onSaved: (value) => _person = value ?? '',
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixText: '${currencyProvider.currencySymbol} ',
                  border: const OutlineInputBorder(),
                ),
                initialValue: _amount > 0 ? _amount.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
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
                  'Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Account',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedAccountId,
                  items: _accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Payment frequency
              const Text(
                'Payment Frequency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'How often will you pay?',
                  border: OutlineInputBorder(),
                ),
                value: _paymentFrequency,
                items: _paymentFrequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency.replaceAll('-', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentFrequency = value;
                    // Reset monthly payment if not monthly frequency
                    if (value != 'monthly') {
                      _monthlyPayment = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Payment day (for monthly payments)
              if (_paymentFrequency == 'monthly') ...[
                const Text(
                  'Payment Day',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Day of month for payment',
                    border: OutlineInputBorder(),
                  ),
                  value: _paymentDay,
                  items: List.generate(31, (index) => index + 1).map((day) {
                    return DropdownMenuItem(value: day, child: Text('$day'));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentDay = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Monthly payment amount
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Monthly Payment Amount',
                    hintText: 'Enter monthly payment amount',
                    prefixText: '${currencyProvider.currencySymbol} ',
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: _monthlyPayment?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter monthly payment amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) =>
                      _monthlyPayment = double.tryParse(value ?? '0'),
                ),
                const SizedBox(height: 20),
              ],

              // Auto deduct option
              if (_selectedAccountId != null &&
                  _paymentFrequency != 'one-time') ...[
                SwitchListTile(
                  title: const Text('Auto Deduct from Account'),
                  subtitle: const Text(
                    'Automatically deduct payments from selected account',
                  ),
                  value: _autoDeduct,
                  onChanged: (value) {
                    setState(() {
                      _autoDeduct = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Date
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 20),

              // Due date
              ListTile(
                title: const Text('Due Date (Optional)'),
                subtitle: Text(
                  _dueDate == null
                      ? 'Not set'
                      : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 20),

              // Status
              const Text(
                'Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: _statuses.map((status) {
                  return Expanded(
                    child: Card(
                      color: _status == status
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      child: ListTile(
                        title: Text(
                          status == 'pending' ? 'Pending' : 'Repaid',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _status == status
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _status = status;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                initialValue: _notes,
                onSaved: (value) => _notes = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
