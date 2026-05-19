import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/services/optimized_data_service.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  bool _loading = true;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final buds = await OptimizedDataService.getBudgets();
      final txns = await OptimizedDataService.getTransactions();
      if (mounted) {
        setState(() {
          _budgets      = buds;
          _transactions = txns;
          _loading      = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Budget> get _monthBudgets => _budgets.where((b) {
    return b.startDate.year == _month.year &&
           b.startDate.month == _month.month;
  }).toList();

  double _spent(Budget b) => _transactions
      .where((t) =>
          t.type == 'expense' &&
          t.category.toLowerCase() == b.category.toLowerCase() &&
          t.date.month == _month.month &&
          t.date.year == _month.year)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalLimit  => _monthBudgets.fold(0.0, (s, b) => s + b.limit);
  double get _totalSpent  => _monthBudgets.fold(0.0, (s, b) => s + _spent(b));
  double get _totalPct    => _totalLimit > 0
      ? (_totalSpent / _totalLimit).clamp(0.0, 1.0)
      : 0.0;

  Color _barColor(double pct) {
    if (pct >= 1.0) return AppColors.danger;
    if (pct >= 0.8) return AppColors.warn;
    return AppColors.ok;
  }

  String _fmt(double v, String currency) {
    if (v >= 10000000) return '$currency${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '$currency${(v / 100000).toStringAsFixed(1)}L';
    return '$currency${NumberFormat('#,##,###').format(v.round())}';
  }

  void _prevMonth() => setState(() =>
      _month = DateTime(_month.year, _month.month - 1));

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime.now())) {
      setState(() => _month = next);
    }
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budgets', style: AppText.heading(context.cInk)),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              DateFormat('MMMM y').format(_month),
                              style: AppText.monoCaption(context.cInk3),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showBudgetSheet(context, currency),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: context.cSurface,
                            borderRadius: BorderRadius.circular(AppRadius.r8),
                            border: Border.all(color: context.cBorder, width: 1),
                          ),
                          child: Icon(Icons.add, size: 16, color: context.cInk2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Month navigator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
                  ),
                  child: Row(
                    children: [
                      _NavArrow(
                        icon: Icons.chevron_left,
                        onTap: _prevMonth,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat('MMMM yyyy').format(_month),
                            style: AppText.bodyStyle(context.cInk).copyWith(
                              fontWeight: AppText.semibold, fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      _NavArrow(
                        icon: Icons.chevron_right,
                        onTap: _nextMonth,
                        disabled: DateTime(_month.year, _month.month + 1)
                            .isAfter(DateTime.now()),
                      ),
                    ],
                  ),
                ),
              ),

              // Overall summary card
              if (_monthBudgets.isNotEmpty)
                SliverToBoxAdapter(
                  child: AppCard(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, 0,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    radius: AppRadius.r12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Overall · ${DateFormat('MMMM').format(_month)}',
                                style: AppText.bodyStyle(context.cInk).copyWith(
                                  fontWeight: AppText.semibold, fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${(_totalPct * 100).toStringAsFixed(0)}%',
                              style: AppText.monoCaption(context.cInk3),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        AppProgressBar(
                          value: _totalPct,
                          color: _barColor(_totalPct),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          '${_fmt(_totalSpent, currency)} spent · '
                          '${_fmt(_totalLimit - _totalSpent, currency)} left',
                          style: AppText.monoCaption(context.cInk3),
                        ),
                      ],
                    ),
                  ),
                ),

              // Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Categories',
                  action: '',
                  onAction: null,
                ),
              ),

              // Budget cards
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else if (_monthBudgets.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    title: 'No budgets for ${DateFormat('MMMM').format(_month)}',
                    subtitle: 'Add one to track spending',
                    icon: Icons.pie_chart_outline,
                    ctaLabel: 'Add Budget',
                    onCta: () => _showBudgetSheet(context, currency),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= _monthBudgets.length) return null;
                      final b = _monthBudgets[i];
                      final spent = _spent(b);
                      final pct   = b.limit > 0
                          ? (spent / b.limit).clamp(0.0, 1.0)
                          : 0.0;
                      return _BudgetCard(
                        budget: b,
                        spent: spent,
                        pct: pct,
                        currency: currency,
                        barColor: _barColor(pct),
                        fmt: _fmt,
                        onEdit: () => _showBudgetSheet(context, currency, editing: b),
                        onDelete: () => _confirmDelete(b),
                      );
                    },
                    childCount: _monthBudgets.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetSheet(
    BuildContext context,
    String currency, {
    Budget? editing,
  }) async {
    final nameCtrl  = TextEditingController(text: editing?.name ?? '');
    final limitCtrl = TextEditingController(
      text: editing != null ? editing.limit.toStringAsFixed(0) : '',
    );
    String category = editing?.category ?? 'food';

    const categories = [
      'food', 'transport', 'shopping', 'bills',
      'entertainment', 'health', 'travel', 'education', 'other',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.cCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.r16),
              ),
              border: Border.all(color: context.cBorder, width: 1),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20, AppSpacing.s20, AppSpacing.s20, AppSpacing.s24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 3,
                    decoration: BoxDecoration(
                      color: context.cBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  editing == null ? 'New Budget' : 'Edit Budget',
                  style: AppText.title(context.cInk),
                ),
                const SizedBox(height: AppSpacing.s16),

                _SheetField(controller: nameCtrl, hint: 'Budget name', label: 'Name'),
                const SizedBox(height: AppSpacing.s12),
                _SheetField(
                  controller: limitCtrl,
                  hint: '0',
                  label: 'Monthly Limit ($currency)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.s14),

                LabelText('Category'),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s6,
                  runSpacing: AppSpacing.s6,
                  children: categories.map((c) {
                    final sel = c == category;
                    return GestureDetector(
                      onTap: () => setS(() => category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s10, vertical: AppSpacing.s6,
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
                          c[0].toUpperCase() + c.substring(1),
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
                const SizedBox(height: AppSpacing.s20),

                AppButtonPrimary(
                  label: editing == null ? 'Add Budget' : 'Save Changes',
                  onTap: () async {
                    final name  = nameCtrl.text.trim();
                    final limit = double.tryParse(limitCtrl.text) ?? 0.0;
                    if (name.isEmpty || limit <= 0) return;

                    final start = DateTime(_month.year, _month.month);
                    final end   = DateTime(_month.year, _month.month + 1, 0);

                    if (editing == null) {
                      final b = Budget(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        limit: limit,
                        category: category,
                        startDate: start,
                        endDate: end,
                      );
                      await OptimizedDataService.addBudget(b);
                    } else {
                      await OptimizedDataService.updateBudget(
                        editing.copyWith(
                          name: name, limit: limit, category: category,
                          startDate: start, endDate: end,
                        ),
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      _load();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Budget b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          side: BorderSide(color: context.cBorder, width: 1),
        ),
        title: Text('Delete budget?', style: AppText.title(context.cInk)),
        content: Text('This cannot be undone.', style: AppText.bodyStyle(context.cInk2)),
        actions: [
          AppButtonGhost(label: 'Cancel', onTap: () => Navigator.pop(context, false)),
          AppButtonGhost(label: 'Delete', onTap: () => Navigator.pop(context, true), danger: true),
        ],
      ),
    );
    if (confirmed == true) {
      await OptimizedDataService.deleteBudget(b.id);
      if (mounted) _load();
    }
  }
}

// ── Budget Card ────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.pct,
    required this.currency,
    required this.barColor,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final double spent;
  final double pct;
  final String currency;
  final Color barColor;
  final String Function(double, String) fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _emoji(String cat) {
    const map = {
      'food': '🍕', 'transport': '🚗', 'shopping': '🛒',
      'bills': '📱', 'entertainment': '🎬', 'health': '💊',
      'travel': '✈️', 'education': '📚',
    };
    return map[cat.toLowerCase()] ?? '💰';
  }

  @override
  Widget build(BuildContext context) {
    final left = budget.limit - spent;
    final over = left < 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s8,
      ),
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: over ? AppColors.danger.withValues(alpha: 0.3) : context.cBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Center(
                  child: Text(_emoji(budget.category),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name,
                        style: AppText.cardTitleStyle(context.cInk),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(budget.category,
                        style: AppText.monoCaption(context.cInk3)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${fmt(spent, currency)} / ${fmt(budget.limit, currency)}',
                    style: AppText.mono(AppText.tinier, AppText.medium, context.cInk2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    over ? 'Over ${fmt(-left, currency)}' : '${fmt(left, currency)} left',
                    style: AppText.mono(AppText.tinier, AppText.regular,
                        over ? AppColors.danger : context.cInk3),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.s4),
              GestureDetector(
                onTap: () => _showOptions(context),
                child: Icon(Icons.more_vert, size: 18, color: context.cInk3),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          AppProgressBar(value: pct, color: barColor),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.r16),
          ),
          border: Border.all(color: context.cBorder, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 3,
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            Text(budget.name, style: AppText.title(context.cInk)),
            const SizedBox(height: AppSpacing.s16),
            _OptionRow(
              icon: Icons.edit_outlined,
              label: 'Edit Budget',
              onTap: () { Navigator.pop(context); onEdit(); },
            ),
            _OptionRow(
              icon: Icons.delete_outline,
              label: 'Delete Budget',
              danger: true,
              onTap: () { Navigator.pop(context); onDelete(); },
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          border: Border.all(color: context.cBorder, width: 1),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? context.cInk3 : context.cInk2,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(label),
        const SizedBox(height: AppSpacing.s6),
        Container(
          decoration: BoxDecoration(
            color: context.cSurface,
            borderRadius: BorderRadius.circular(AppRadius.r10),
            border: Border.all(color: context.cBorder, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppText.bodyStyle(context.cInk),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.bodyStyle(context.cInk3),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12, vertical: AppSpacing.s10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : context.cInk;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.s12),
            Text(label, style: AppText.bodyStyle(color)),
          ],
        ),
      ),
    );
  }
}
