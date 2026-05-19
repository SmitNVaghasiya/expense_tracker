import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/category.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/services/optimized_data_service.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';

class OptimizedHomeScreen extends StatefulWidget {
  const OptimizedHomeScreen({super.key, required this.transactionType});
  final TransactionType transactionType;

  @override
  State<OptimizedHomeScreen> createState() => _OptimizedHomeScreenState();
}

class _OptimizedHomeScreenState extends State<OptimizedHomeScreen> {
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Budget> _budgets = [];
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final txns  = await OptimizedDataService.getTransactions();
      final accs  = await OptimizedDataService.getAccounts();
      final buds  = await OptimizedDataService.getBudgets();
      final cats  = await OptimizedDataService.getCategories();
      if (mounted) {
        setState(() {
          _transactions = txns;
          _accounts     = accs;
          _budgets      = buds;
          _categories   = cats;
          _loading      = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Computed values ─────────────────────────────────────────────────────────

  double get _totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + a.balance);

  double get _thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get _thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get _totalBudget =>
      _budgets.fold(0.0, (s, b) => s + b.limit);

  double get _budgetPct =>
      _totalBudget > 0 ? (_thisMonthExpense / _totalBudget).clamp(0.0, 1.0) : 0;

  List<Transaction> get _recent => _transactions.take(8).toList();

  String _groupLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(d.year, d.month, d.day);
    final diff  = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM').format(d);
  }

  String get _monthLabel => DateFormat('MMMM y').format(DateTime.now()).toUpperCase();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currencySymbol;
    if (_loading) {
      return Scaffold(
        backgroundColor: context.cBg,
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return Scaffold(
      backgroundColor: context.cBg,
      body: RefreshIndicator(
        onRefresh: _load,
        color: context.cAccent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildBody(context, currency)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.cBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      expandedHeight: 0,
      titleSpacing: AppSpacing.s16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText(_monthLabel),
          const SizedBox(height: 2),
          Text(
            _greeting,
            style: AppText.bodyStyle(context.cInk2)
                .copyWith(fontWeight: AppText.medium),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/settings'),
          child: Container(
            width: 34, height: 34,
            margin: const EdgeInsets.only(right: AppSpacing.s16),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(color: context.cBorder, width: 1),
            ),
            child: Icon(Icons.person_outline, size: 16, color: context.cInk2),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, String currency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(context, currency),
          const SizedBox(height: AppSpacing.s10),
          _buildBudgetBar(context, currency),
          const SizedBox(height: AppSpacing.s4),
          _buildRecentSection(context, currency),
        ],
      ),
    );
  }

  // ── Balance Hero Card ──────────────────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context, String currency) {
    return AppHeroCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText('Net Balance'),
          const SizedBox(height: AppSpacing.s6),
          Text(
            '$currency${_formatNumber(_totalBalance)}',
            style: AppText.monoHero(context.cInk),
          ),
          const SizedBox(height: AppSpacing.s14),
          Container(
            height: 1,
            color: context.cBorder,
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelText('Income'),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '+$currency${_formatNumber(_thisMonthIncome)}',
                      style: AppText.monoAmount(AppColors.ok, size: AppText.numMid),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: context.cBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText('Expense'),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        '−$currency${_formatNumber(_thisMonthExpense)}',
                        style: AppText.monoAmount(AppColors.danger, size: AppText.numMid),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Budget Bar ─────────────────────────────────────────────────────────────

  Widget _buildBudgetBar(BuildContext context, String currency) {
    final pctLabel = '${(_budgetPct * 100).toStringAsFixed(0)}%';
    final daysLeft = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
        .day - DateTime.now().day;
    final barColor = _budgetPct >= 1.0
        ? AppColors.danger
        : _budgetPct >= 0.8
            ? AppColors.warn
            : context.cAccent;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s14),
      radius: AppRadius.r12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Budget · ${DateFormat('MMMM').format(DateTime.now())}',
                  style: AppText.bodyStyle(context.cInk).copyWith(
                    fontWeight: AppText.semibold, fontSize: 12,
                  ),
                ),
              ),
              Text(
                pctLabel,
                style: AppText.monoCaption(context.cInk3),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          AppProgressBar(value: _budgetPct, color: barColor),
          const SizedBox(height: AppSpacing.s6),
          Text(
            '$currency${_formatNumber(_thisMonthExpense)} spent · '
            '$currency${_formatNumber(_totalBudget - _thisMonthExpense)} left · '
            '$daysLeft days',
            style: AppText.monoCaption(context.cInk3),
          ),
        ],
      ),
    );
  }

  // ── Recent Transactions ───────────────────────────────────────────────────

  Widget _buildRecentSection(BuildContext context, String currency) {
    if (_recent.isEmpty) {
      return AppEmptyState(
        title: 'No transactions yet',
        subtitle: 'Tap + to add your first one',
        icon: Icons.receipt_long_outlined,
        ctaLabel: 'Add Transaction',
        onCta: () => _openAdd(context),
      );
    }

    // Group by day label
    final Map<String, List<Transaction>> groups = {};
    for (final t in _recent) {
      final label = _groupLabel(t.date);
      groups.putIfAbsent(label, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent',
          action: 'View all',
          onAction: () {},
        ),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s6,
            ),
            child: LabelText(entry.key),
          ),
          for (final txn in entry.value)
            _TxnRow(
              txn: txn,
              currency: currency,
              categories: _categories,
              onTap: () => _openAdd(context, existing: txn),
            ),
        ],
      ],
    );
  }

  void _openAdd(BuildContext context, {Transaction? existing}) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => CalculatorTransactionScreen(
          initialType: existing?.type ?? 'expense',
          editingTransaction: existing,
        ),
      ),
    );
    if (result != null) {
      await OptimizedDataService.addTransaction(result);
      _load();
    }
  }

  String _formatNumber(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    return NumberFormat('#,##,###').format(v.round());
  }
}

// ── Transaction Row ──────────────────────────────────────────────────────────

class _TxnRow extends StatelessWidget {
  const _TxnRow({
    required this.txn,
    required this.currency,
    required this.categories,
    required this.onTap,
  });

  final Transaction txn;
  final String currency;
  final List<Category> categories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpense = txn.type == 'expense';
    final amountColor = isExpense ? AppColors.danger : AppColors.ok;
    final sign = isExpense ? '−' : '+';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(AppRadius.r10),
          border: Border.all(color: context.cBorder, width: 1),
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Center(
                child: Text(
                  _categoryEmoji(txn.category),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            // Title + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.title,
                    style: AppText.cardTitleStyle(context.cInk),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    txn.category,
                    style: AppText.monoCaption(context.cInk3),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '$sign$currency${txn.amount.toStringAsFixed(0)}',
              style: AppText.monoAmount(amountColor),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    const map = {
      'food': '🍕', 'food & dining': '🍕',
      'transport': '🚗', 'transportation': '🚗',
      'shopping': '🛒',
      'bills': '📱', 'bills & utilities': '📱',
      'entertainment': '🎬',
      'health': '💊',
      'salary': '💼', 'income': '💼',
      'savings': '🏦',
      'travel': '✈️',
      'education': '📚',
    };
    return map[category.toLowerCase()] ?? '💰';
  }
}
