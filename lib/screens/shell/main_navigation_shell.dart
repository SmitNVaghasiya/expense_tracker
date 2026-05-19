import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/core/navigation_state.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/screens/dashboard/optimized_home_screen.dart';
import 'package:spendwise/screens/transactions/records_screen.dart';
import 'package:spendwise/screens/financial/accounts_screen.dart';
import 'package:spendwise/screens/reports/reports_screen.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  static final List<Widget> _screens = [
    const OptimizedHomeScreen(transactionType: TransactionType.all),
    const RecordsScreen(),
    const SizedBox.shrink(), // index 2 = FAB action (no screen)
    const AccountsScreen(),
    const ReportsScreen(),
  ];

  void _openAddTransaction(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, a, b) => const CalculatorTransactionScreen(initialType: 'expense'),
        transitionsBuilder: (context, anim, secondaryAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navState, _) {
        // Skip index 2 (FAB placeholder)
        final displayIndex = navState.currentIndex >= 2
            ? navState.currentIndex - 1
            : navState.currentIndex;

        return Scaffold(
          backgroundColor: context.cBg,
          body: IndexedStack(
            index: displayIndex,
            children: [
              _screens[0],
              _screens[1],
              _screens[3],
              _screens[4],
            ],
          ),
          bottomNavigationBar: _SoftMinimalNavBar(
            currentIndex: navState.currentIndex,
            onTap: (i) {
              if (i == 2) {
                _openAddTransaction(context);
              } else {
                navState.setIndex(i);
              }
            },
          ),
        );
      },
    );
  }
}

// ── Soft Minimal Bottom Navigation Bar ────────────────────────────────────────

class _SoftMinimalNavBar extends StatelessWidget {
  const _SoftMinimalNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(id: 0, label: 'Home',    icon: Icons.grid_view_rounded),
    _NavItem(id: 1, label: 'Records', icon: Icons.receipt_long_outlined),
    _NavItem(id: 2, label: '',        icon: Icons.add, isFab: true),
    _NavItem(id: 3, label: 'Accounts',icon: Icons.account_balance_wallet_outlined),
    _NavItem(id: 4, label: 'Reports', icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: context.cCard,
        border: Border(top: BorderSide(color: context.cBorder, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: _items.map((item) {
            if (item.isFab) {
              return Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => onTap(item.id),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accentDark : AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.fab),
                        boxShadow: AppShadow.fab,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: isDark ? AppColors.bgDark : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }

            final isActive = item.id == currentIndex;
            final fg = isActive
                ? (isDark ? AppColors.accentDark : AppColors.accent)
                : context.cInk3;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(item.id),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: isActive
                          ? BoxDecoration(
                              color: isDark
                                  ? AppColors.accentBgDark
                                  : AppColors.accentBg,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            )
                          : null,
                      child: Icon(item.icon, size: 18, color: fg),
                    ),
                    if (item.label.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: AppText.mono(9, AppText.medium, fg),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isFab = false,
  });

  final int id;
  final String label;
  final IconData icon;
  final bool isFab;
}
