import 'package:flutter/material.dart';
import 'package:spendwise/screens/dashboard/dashboard_screen.dart';
import 'package:spendwise/screens/financial/budgets_screen.dart';
import 'package:spendwise/screens/reports/reports_screen.dart';
import 'package:spendwise/screens/financial/accounts_screen.dart';
import 'package:spendwise/screens/financial/loans_screen.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:spendwise/screens/financial/add_loan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ReportsScreen(),
    BudgetsScreen(),
    AccountsScreen(),
    LoansScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleFloatingActionButton() async {
    switch (_selectedIndex) {
      case 0: // Dashboard - Add transaction
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CalculatorTransactionScreen(initialType: 'expense'),
          ),
        );
        if (result == true) {
          // Refresh the dashboard
          setState(() {});
        }
        break;
      case 1: // Reports - Add transaction
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CalculatorTransactionScreen(initialType: 'expense'),
          ),
        );
        if (result == true) {
          // Navigate to dashboard after successful transaction
          _navigateToDashboard();
        }
        break;
      case 2: // Budgets - Add budget category
        // This will be handled by the BudgetsScreen itself
        break;
      case 3: // Accounts - Add account
        // This will be handled by the AccountsScreen itself
        break;
      case 4: // Loans - Add loan
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddLoanScreen()),
        );
        if (result == true) {
          // Refresh the loans screen
          setState(() {});
        }
        break;
    }
  }

  void _navigateToDashboard() {
    setState(() {
      _selectedIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _widgetOptions,
      ),
      floatingActionButton:
          _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 4
          ? FloatingActionButton(
              onPressed: _handleFloatingActionButton,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Loans',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
