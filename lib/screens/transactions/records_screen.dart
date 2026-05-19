import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/services/optimized_data_service.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Transaction> _all = [];
  bool _loading = true;
  String _tab = 'All';
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _tabs = ['All', 'Expenses', 'Income'];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final txns = await OptimizedDataService.getTransactions();
      if (mounted) setState(() { _all = txns; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Transaction> get _filtered {
    return _all.where((t) {
      final matchTab = _tab == 'All' ||
          (_tab == 'Expenses' && t.type == 'expense') ||
          (_tab == 'Income'   && t.type == 'income');
      final matchSearch = _query.isEmpty ||
          t.title.toLowerCase().contains(_query) ||
          t.category.toLowerCase().contains(_query) ||
          (t.notes?.toLowerCase().contains(_query) ?? false);
      return matchTab && matchSearch;
    }).toList();
  }

  // Group by date label
  Map<String, List<Transaction>> get _grouped {
    final map = <String, List<Transaction>>{};
    for (final t in _filtered) {
      final label = _dayLabel(t.date);
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(d.year, d.month, d.day);
    final diff  = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMMM').format(d);
  }

  double _monthTotal(String type) {
    final now = DateTime.now();
    return _all
        .where((t) => t.type == type && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);
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
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Records', style: AppText.heading(context.cInk)),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        DateFormat('MMMM y').format(DateTime.now()),
                        style: AppText.monoCaption(context.cInk3),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Month summary strip ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
                  ),
                  child: Row(
                    children: [
                      _SummaryChip(
                        label: 'Income',
                        amount: _monthTotal('income'),
                        currency: currency,
                        color: AppColors.ok,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      _SummaryChip(
                        label: 'Expense',
                        amount: _monthTotal('expense'),
                        currency: currency,
                        color: AppColors.danger,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.s12, 0, 0,
                  ),
                  child: AppSearchField(
                    controller: _searchCtrl,
                    hint: 'Search transactions...',
                  ),
                ),
              ),

              // ── Tab bar ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.s10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.cBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: _tabs.map((tab) {
                      final active = tab == _tab;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = tab),
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
                            tab,
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

              // ── Transaction list (grouped) ────────────────────────────────
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else if (_filtered.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    title: _query.isNotEmpty ? 'No results for "$_query"' : 'No transactions',
                    subtitle: _query.isEmpty ? 'Add one with the + button' : null,
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final entries = _grouped.entries.toList();
                      if (i >= entries.length) return null;
                      final entry = entries[i];
                      return _DayGroup(
                        label: entry.key,
                        transactions: entry.value,
                        currency: currency,
                        onTap: (txn) => _editTransaction(txn),
                        onDelete: (txn) => _deleteTransaction(txn),
                      );
                    },
                    childCount: _grouped.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction(Transaction txn) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => CalculatorTransactionScreen(
          initialType: txn.type,
          editingTransaction: txn,
        ),
      ),
    );
    if (result != null) {
      await OptimizedDataService.updateTransaction(result);
      _load();
    }
  }

  Future<void> _deleteTransaction(Transaction txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          side: BorderSide(color: context.cBorder, width: 1),
        ),
        title: Text('Delete transaction?', style: AppText.title(context.cInk)),
        content: Text(
          'This cannot be undone.',
          style: AppText.bodyStyle(context.cInk2),
        ),
        actions: [
          AppButtonGhost(label: 'Cancel', onTap: () => Navigator.pop(context, false)),
          AppButtonGhost(label: 'Delete', onTap: () => Navigator.pop(context, true), danger: true),
        ],
      ),
    );
    if (confirmed == true) {
      await OptimizedDataService.deleteTransaction(txn.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${txn.title}"',
                style: AppText.bodyStyle(Colors.white)),
            backgroundColor: context.cInk,
          ),
        );
      }
      _load();
    }
  }
}

// ── Day group ──────────────────────────────────────────────────────────────

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.label,
    required this.transactions,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final List<Transaction> transactions;
  final String currency;
  final ValueChanged<Transaction> onTap;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final dayTotal = transactions.fold<double>(0, (s, t) =>
        t.type == 'expense' ? s - t.amount : s + t.amount);
    final totalColor = dayTotal >= 0 ? AppColors.ok : AppColors.danger;
    final sign = dayTotal >= 0 ? '+' : '−';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16, AppSpacing.s14, AppSpacing.s16, AppSpacing.s6,
          ),
          child: Row(
            children: [
              Expanded(child: LabelText(label)),
              Text(
                '$sign$currency${dayTotal.abs().toStringAsFixed(0)}',
                style: AppText.mono(AppText.tinier, AppText.medium, totalColor),
              ),
            ],
          ),
        ),
        // Rows
        ...transactions.map((txn) => _TxnRow(
              txn: txn,
              currency: currency,
              onTap: () => onTap(txn),
              onLongPress: () => onDelete(txn),
            )),
      ],
    );
  }
}

// ── Transaction row ────────────────────────────────────────────────────────

class _TxnRow extends StatelessWidget {
  const _TxnRow({
    required this.txn,
    required this.currency,
    required this.onTap,
    required this.onLongPress,
  });

  final Transaction txn;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String _emoji(String cat) {
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
    return map[cat.toLowerCase()] ?? '💰';
  }

  @override
  Widget build(BuildContext context) {
    final isExp = txn.type == 'expense';
    final clr   = isExp ? AppColors.danger : AppColors.ok;
    final sign  = isExp ? '−' : '+';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                child: Text(_emoji(txn.category),
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.title,
                      style: AppText.cardTitleStyle(context.cInk),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(txn.category,
                      style: AppText.monoCaption(context.cInk3)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign$currency${txn.amount.toStringAsFixed(0)}',
                  style: AppText.monoAmount(clr),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(txn.date),
                  style: AppText.mono(AppText.tinier, AppText.regular, context.cInk3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary chip ───────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  final String label;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
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
            Text(
              '$currency${amount.toStringAsFixed(0)}',
              style: AppText.monoAmount(color, size: AppText.numMid),
            ),
          ],
        ),
      ),
    );
  }
}
