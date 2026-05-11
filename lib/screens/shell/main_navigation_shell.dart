import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/core/navigation_state.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/screens/dashboard/optimized_home_screen.dart';
import 'package:spendwise/screens/financial/accounts_screen.dart';
import 'package:spendwise/screens/financial/budgets_screen.dart';
import 'package:spendwise/screens/reports/reports_screen.dart';
import 'package:spendwise/screens/financial/loans_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  static final List<Widget> _screens = [
    const OptimizedHomeScreen(transactionType: TransactionType.all),
    const AccountsScreen(),
    const BudgetsScreen(),
    const ReportsScreen(),
    const LoansScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navState, _) {
        return Scaffold(
          body: IndexedStack(
            index: navState.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navState.currentIndex,
            onTap: (index) => navState.setIndex(index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Accounts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: 'Budgets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.handshake),
                label: 'Loans',
              ),
            ],
          ),
        );
      },
    );
  }
}
