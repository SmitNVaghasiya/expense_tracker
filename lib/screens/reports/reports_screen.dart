import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/services/optimized_data_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  bool _loading = true;
  String _range = 'This Month';
  int _tab = 0; // 0=Overview 1=Spending 2=Budget

  static const _ranges = [
    'This Month', 'Last Month', 'Last 3 Months', 'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final txns = await OptimizedDataService.getTransactions();
      final buds = await OptimizedDataService.getBudgets();
      if (mounted) {
        setState(() {
          _transactions = txns;
          _budgets      = buds;
          _loading      = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Transaction> get _filtered {
    final now = DateTime.now();
    return _transactions.where((t) {
      switch (_range) {
        case 'This Month':
          return t.date.month == now.month && t.date.year == now.year;
        case 'Last Month':
          final lm = DateTime(now.year, now.month - 1);
          return t.date.month == lm.month && t.date.year == lm.year;
        case 'Last 3 Months':
          return t.date.isAfter(DateTime(now.year, now.month - 3, now.day));
        case 'This Year':
          return t.date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  double get _income  => _filtered.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
  double get _expense => _filtered.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
  double get _balance => _income - _expense;

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final t in _filtered.where((t) => t.type == 'expense')) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(6));
  }

  // Monthly breakdown: last 6 months in/out
  List<_MonthData> get _monthly {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      final inc = _transactions
          .where((t) => t.type == 'income' && t.date.month == m.month && t.date.year == m.year)
          .fold(0.0, (s, t) => s + t.amount);
      final exp = _transactions
          .where((t) => t.type == 'expense' && t.date.month == m.month && t.date.year == m.year)
          .fold(0.0, (s, t) => s + t.amount);
      return _MonthData(label: DateFormat('MMM').format(m), income: inc, expense: exp);
    });
  }

  String _fmt(double v, String currency) {
    if (v.abs() >= 10000000) return '$currency${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v.abs() >= 100000)   return '$currency${(v / 100000).toStringAsFixed(1)}L';
    return '$currency${NumberFormat('#,##,###').format(v.abs().round())}';
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currencySymbol;

    return Scaffold(
      backgroundColor: context.cBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: context.cAccent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports', style: AppText.heading(context.cInk)),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        DateFormat('MMMM y').format(DateTime.now()),
                        style: AppText.monoCaption(context.cInk3),
                      ),
                    ],
                  ),
                ),
              ),

              // Range pills
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
                  ),
                  child: Row(
                    children: _ranges.map((r) {
                      final sel = r == _range;
                      return GestureDetector(
                        onTap: () => setState(() => _range = r),
                        child: Container(
                          margin: const EdgeInsets.only(right: AppSpacing.s6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12, vertical: AppSpacing.s6,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? (context.isDark ? AppColors.accentBgDark : AppColors.accentBg)
                                : context.cSurface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: sel ? context.cAccent : context.cBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            r,
                            style: AppText.mono(
                              AppText.tinier + 1,
                              sel ? AppText.semibold : AppText.regular,
                              sel ? context.cAccent : context.cInk3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else ...[
                // Summary row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, 0,
                    ),
                    child: Row(
                      children: [
                        _SummaryTile(
                          label: 'Income',
                          value: _fmt(_income, currency),
                          color: AppColors.ok,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        _SummaryTile(
                          label: 'Expense',
                          value: _fmt(_expense, currency),
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        _SummaryTile(
                          label: 'Balance',
                          value: _fmt(_balance, currency),
                          color: _balance >= 0 ? AppColors.ok : AppColors.danger,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.s12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.cBorder, width: 1),
                      ),
                    ),
                    child: Row(
                      children: ['Overview', 'Spending', 'Budget'].asMap().entries.map((e) {
                        final active = e.key == _tab;
                        return GestureDetector(
                          onTap: () => setState(() => _tab = e.key),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: active ? context.cAccent : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              e.value,
                              style: AppText.bodyStyle(
                                active ? context.cInk : context.cInk3,
                              ).copyWith(
                                fontWeight: active ? AppText.bold : AppText.medium,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Tab content
                SliverToBoxAdapter(
                  child: _buildTabContent(context, currency),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String currency) {
    switch (_tab) {
      case 0:
        return _buildOverview(context, currency);
      case 1:
        return _buildSpending(context, currency);
      case 2:
        return _buildBudget(context, currency);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Overview ────────────────────────────────────────────────────────────────

  Widget _buildOverview(BuildContext context, String currency) {
    final monthly = _monthly;
    final maxVal  = monthly.fold(0.0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s4),
          SectionHeader(title: '6-Month Trend', action: '', onAction: null),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            padding: const EdgeInsets.all(AppSpacing.s16),
            radius: AppRadius.r12,
            child: Column(
              children: [
                // Bar chart
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: monthly.map((d) {
                      final incH = maxVal > 0 ? (d.income / maxVal) * 100 : 0.0;
                      final expH = maxVal > 0 ? (d.expense / maxVal) * 100 : 0.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _Bar(height: incH, color: AppColors.ok),
                                  const SizedBox(width: 2),
                                  _Bar(height: expH, color: AppColors.danger),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(d.label,
                                  style: AppText.mono(7, AppText.regular, context.cInk3)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: AppColors.ok, label: 'Income'),
                    const SizedBox(width: AppSpacing.s16),
                    _Legend(color: AppColors.danger, label: 'Expense'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Spending Breakdown ──────────────────────────────────────────────────────

  Widget _buildSpending(BuildContext context, String currency) {
    final cats = _byCategory;
    if (cats.isEmpty) {
      return const AppEmptyState(
        title: 'No expense data',
        subtitle: 'Add expenses to see breakdown',
        icon: Icons.pie_chart_outline,
      );
    }

    final total = cats.values.fold(0.0, (s, v) => s + v);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s4),
          SectionHeader(title: 'By Category', action: '', onAction: null),
          ...cats.entries.map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            return Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s8,
              ),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: context.cCard,
                borderRadius: BorderRadius.circular(AppRadius.r10),
                border: Border.all(color: context.cBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key[0].toUpperCase() + e.key.substring(1),
                          style: AppText.cardTitleStyle(context.cInk),
                        ),
                      ),
                      Text(
                        _fmt(e.value, currency),
                        style: AppText.monoAmount(AppColors.danger),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        style: AppText.monoCaption(context.cInk3),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppProgressBar(value: pct, color: context.cAccent),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Budget Adherence ────────────────────────────────────────────────────────

  Widget _buildBudget(BuildContext context, String currency) {
    final now = DateTime.now();
    final monthBudgets = _budgets.where((b) =>
        b.startDate.year == now.year && b.startDate.month == now.month).toList();

    if (monthBudgets.isEmpty) {
      return const AppEmptyState(
        title: 'No budgets this month',
        subtitle: 'Set budgets in the Budgets tab',
        icon: Icons.pie_chart_outline,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s4),
          SectionHeader(title: 'Budget vs Spent', action: '', onAction: null),
          ...monthBudgets.map((b) {
            final spent = _transactions
                .where((t) =>
                    t.type == 'expense' &&
                    t.category.toLowerCase() == b.category.toLowerCase() &&
                    t.date.month == now.month &&
                    t.date.year == now.year)
                .fold(0.0, (s, t) => s + t.amount);
            final pct   = b.limit > 0 ? (spent / b.limit).clamp(0.0, 1.0) : 0.0;
            final color = pct >= 1.0
                ? AppColors.danger
                : pct >= 0.8
                    ? AppColors.warn
                    : AppColors.ok;

            return Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s8,
              ),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: context.cCard,
                borderRadius: BorderRadius.circular(AppRadius.r10),
                border: Border.all(color: context.cBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(b.name,
                            style: AppText.cardTitleStyle(context.cInk)),
                      ),
                      Text(
                        '${_fmt(spent, currency)} / ${_fmt(b.limit, currency)}',
                        style: AppText.mono(AppText.tinier, AppText.medium, context.cInk2),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppProgressBar(value: pct, color: color),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────────────

class _MonthData {
  _MonthData({required this.label, required this.income, required this.expense});
  final String label;
  final double income;
  final double expense;
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10, vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(AppRadius.r10),
          border: Border.all(color: context.cBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelText(label),
            const SizedBox(height: AppSpacing.s4),
            Text(value, style: AppText.mono(10, AppText.semibold, color)),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height.clamp(2.0, 100.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppText.monoCaption(context.cInk3)),
      ],
    );
  }
}
