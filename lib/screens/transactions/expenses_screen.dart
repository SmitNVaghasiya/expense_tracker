import 'package:flutter/material.dart';
import 'package:spendwise/screens/transactions/base_transaction_screen.dart';

class ExpensesScreen extends BaseTransactionScreen {
  const ExpensesScreen({super.key}) : super(transactionType: 'expense');
}
