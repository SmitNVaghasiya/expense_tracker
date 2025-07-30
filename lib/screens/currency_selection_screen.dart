import 'package:flutter/material.dart';
import 'package:expense_tracker/services/currency_provider.dart';
import 'package:provider/provider.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  late String _selectedCurrency;
  
  @override
  void initState() {
    super.initState();
    _selectedCurrency = context.read<CurrencyProvider>().selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        actions: [
          TextButton(
            onPressed: () {
              currencyProvider.setCurrency(_selectedCurrency);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your preferred currency:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: CurrencyProvider.currencies.length,
                itemBuilder: (context, index) {
                  final currency = CurrencyProvider.currencies[index];
                  
                  return RadioListTile<String>(
                    title: Text('${currency['name']} (${currency['code']})'),
                    subtitle: Text(currency['symbol']!),
                    value: currency['code']!,
                    groupValue: _selectedCurrency,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}