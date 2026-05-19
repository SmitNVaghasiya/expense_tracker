import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/index.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/currency_provider.dart';
import 'package:spendwise/services/optimized_data_service.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final accs  = await OptimizedDataService.getAccounts();
      final txns  = await OptimizedDataService.getTransactions();
      if (mounted) {
        setState(() {
          _accounts     = accs;
          _transactions = txns;
          _loading      = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalBalance =>
      _accounts.fold(0.0, (s, a) => s + a.balance);

  double _monthIn(String accountId) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.accountId == accountId &&
            t.type == 'income' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double _monthOut(String accountId) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.accountId == accountId &&
            t.type == 'expense' &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (s, t) => s + t.amount);
  }

  String _typeEmoji(String type) {
    const map = {
      'cash': '💵',
      'bank': '🏦',
      'credit': '💳',
      'debit': '💳',
      'savings': '🏧',
      'investment': '📈',
      'digital': '📱',
      'loan': '📋',
      'business': '🏢',
    };
    return map[type.toLowerCase()] ?? '💰';
  }

  String _typeLabel(String type) {
    const map = {
      'cash': 'Cash',
      'bank': 'Bank',
      'credit': 'Credit Card',
      'debit': 'Debit Card',
      'savings': 'Savings',
      'investment': 'Investment',
      'digital': 'Digital Wallet',
      'loan': 'Loan',
      'business': 'Business',
    };
    return map[type.toLowerCase()] ?? type;
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accounts', style: AppText.heading(context.cInk)),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              DateFormat('MMMM y').format(DateTime.now()),
                              style: AppText.monoCaption(context.cInk3),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAccountSheet(context, currency),
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

              // Total balance hero
              SliverToBoxAdapter(
                child: AppHeroCard(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText('Total Balance'),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        _fmt(_totalBalance, currency),
                        style: AppText.monoHero(
                          _totalBalance < 0 ? AppColors.danger : context.cInk,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Text(
                        '${_accounts.length} account${_accounts.length != 1 ? 's' : ''}',
                        style: AppText.monoCaption(context.cInk3),
                      ),
                    ],
                  ),
                ),
              ),

              // Section header
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Your Accounts',
                  action: '',
                  onAction: null,
                ),
              ),

              // Account list
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else if (_accounts.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    title: 'No accounts yet',
                    subtitle: 'Add one to start tracking',
                    icon: Icons.account_balance_wallet_outlined,
                    ctaLabel: 'Add Account',
                    onCta: () => _showAccountSheet(context, currency),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= _accounts.length) return null;
                      final acc = _accounts[i];
                      return _AccountCard(
                        account: acc,
                        currency: currency,
                        monthIn: _monthIn(acc.id),
                        monthOut: _monthOut(acc.id),
                        typeEmoji: _typeEmoji(acc.type),
                        typeLabel: _typeLabel(acc.type),
                        fmt: _fmt,
                        onEdit: () => _showAccountSheet(context, currency, editing: acc),
                        onDelete: () => _confirmDelete(acc),
                      );
                    },
                    childCount: _accounts.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAccountSheet(
    BuildContext context,
    String currency, {
    Account? editing,
  }) async {
    final nameCtrl    = TextEditingController(text: editing?.name ?? '');
    final balanceCtrl = TextEditingController(
      text: editing != null ? editing.balance.toStringAsFixed(0) : '',
    );
    String type = editing?.type ?? 'cash';

    const types = [
      'cash', 'bank', 'savings', 'credit', 'debit',
      'investment', 'digital', 'business',
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
                // Handle
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
                  editing == null ? 'New Account' : 'Edit Account',
                  style: AppText.title(context.cInk),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Name field
                _SheetField(
                  controller: nameCtrl,
                  hint: 'Account name',
                  label: 'Name',
                ),
                const SizedBox(height: AppSpacing.s12),

                // Balance field
                _SheetField(
                  controller: balanceCtrl,
                  hint: '0',
                  label: 'Balance ($currency)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.s14),

                // Type pills
                LabelText('Type'),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s6,
                  runSpacing: AppSpacing.s6,
                  children: types.map((t) {
                    final sel = t == type;
                    return GestureDetector(
                      onTap: () => setS(() => type = t),
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
                          t[0].toUpperCase() + t.substring(1),
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

                // Save button
                AppButtonPrimary(
                  label: editing == null ? 'Add Account' : 'Save Changes',
                  onTap: () async {
                    final name    = nameCtrl.text.trim();
                    final balance = double.tryParse(balanceCtrl.text) ?? 0.0;
                    if (name.isEmpty) return;

                    if (editing == null) {
                      final acc = Account(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        balance: balance,
                        type: type,
                        icon: null,
                        limit: null,
                        createdAt: DateTime.now(),
                      );
                      await OptimizedDataService.addAccount(acc);
                    } else {
                      final updated = editing.copyWith(
                        name: name,
                        balance: balance,
                        type: type,
                      );
                      await OptimizedDataService.updateAccount(updated);
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

  Future<void> _confirmDelete(Account acc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          side: BorderSide(color: context.cBorder, width: 1),
        ),
        title: Text('Delete account?', style: AppText.title(context.cInk)),
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
      await OptimizedDataService.deleteAccount(acc.id);
      if (mounted) _load();
    }
  }
}

// ── Account Card ───────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.currency,
    required this.monthIn,
    required this.monthOut,
    required this.typeEmoji,
    required this.typeLabel,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });

  final Account account;
  final String currency;
  final double monthIn;
  final double monthOut;
  final String typeEmoji;
  final String typeLabel;
  final String Function(double, String) fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isNeg = account.balance < 0;
    final balColor = isNeg ? AppColors.danger : context.cInk;

    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s8,
        ),
        padding: const EdgeInsets.all(AppSpacing.s14),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(
            color: isNeg ? AppColors.danger.withValues(alpha: 0.3) : context.cBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emoji tile
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: context.cSurface,
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                  ),
                  child: Center(
                    child: Text(typeEmoji,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name,
                          style: AppText.cardTitleStyle(context.cInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(typeLabel,
                          style: AppText.monoCaption(context.cInk3)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt(account.balance, currency),
                      style: AppText.monoAmount(balColor),
                    ),
                    if (isNeg) ...[
                      const SizedBox(height: 2),
                      Text('Negative',
                          style: AppText.mono(AppText.tinier, AppText.regular, AppColors.danger)),
                    ],
                  ],
                ),
                const SizedBox(width: AppSpacing.s4),
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(Icons.more_vert, size: 18, color: context.cInk3),
                ),
              ],
            ),

            // Month stats
            if (monthIn > 0 || monthOut > 0) ...[
              const SizedBox(height: AppSpacing.s10),
              Container(height: 1, color: context.cBorder),
              const SizedBox(height: AppSpacing.s10),
              Row(
                children: [
                  _MiniStat(
                    label: 'In',
                    value: fmt(monthIn, currency),
                    color: AppColors.ok,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  _MiniStat(
                    label: 'Out',
                    value: fmt(monthOut, currency),
                    color: AppColors.danger,
                  ),
                ],
              ),
            ],
          ],
        ),
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
            Text(account.name, style: AppText.title(context.cInk)),
            const SizedBox(height: AppSpacing.s16),
            _OptionRow(
              icon: Icons.edit_outlined,
              label: 'Edit Account',
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            _OptionRow(
              icon: Icons.delete_outline,
              label: 'Delete Account',
              danger: true,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.monoCaption(context.cInk3)),
        const SizedBox(width: AppSpacing.s4),
        Text(value, style: AppText.mono(AppText.tinier, AppText.medium, color)),
      ],
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
