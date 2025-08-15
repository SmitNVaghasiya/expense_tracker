import 'package:flutter/material.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:intl/intl.dart';
import 'package:spendwise/services/category_service.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final accounts = await DataService.getAccounts();

    setState(() {
      _accounts = accounts;
      _calculateTotalBalance();
    });
  }

  void _calculateTotalBalance() {
    _totalBalance = _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showAddAccountDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add New Account',
          ),
          IconButton(
            onPressed: () {
              // Show account type filter or sorting options
              _showAccountOptions();
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Section
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAccountTypeStats(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Accounts List Section
                _buildAccountsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '₹').format(_totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_accounts.length} account${_accounts.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAccountOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort by Balance'),
              onTap: () {
                Navigator.pop(context);
                _sortAccountsByBalance();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Name'),
              onTap: () {
                Navigator.pop(context);
                _sortAccountsByName();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Sort by Type'),
              onTap: () {
                Navigator.pop(context);
                _sortAccountsByType();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Sort by Date Created'),
              onTap: () {
                Navigator.pop(context);
                _sortAccountsByDate();
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddAccountDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Add New Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortAccountsByBalance() {
    setState(() {
      _accounts.sort((a, b) => b.balance.compareTo(a.balance));
    });
  }

  void _sortAccountsByName() {
    setState(() {
      _accounts.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _sortAccountsByType() {
    setState(() {
      _accounts.sort((a, b) => a.type.compareTo(b.type));
    });
  }

  void _sortAccountsByDate() {
    setState(() {
      _accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Widget _buildAccountTypeStats() {
    if (_accounts.isEmpty) return const SizedBox.shrink();

    // Group accounts by type and calculate totals
    final Map<String, double> typeTotals = {};
    final Map<String, int> typeCounts = {};
    
    for (final account in _accounts) {
      final type = account.type;
      typeTotals[type] = (typeTotals[type] ?? 0) + account.balance;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Get top 3 account types by balance
    final sortedTypes = typeTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topTypes = sortedTypes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: topTypes.map((typeEntry) {
            final type = typeEntry.key;
            final total = typeEntry.value;
            final count = typeCounts[type] ?? 0;
            final percentage = (_totalBalance > 0) ? (total / _totalBalance * 100) : 0.0;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getAccountColor(type).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getAccountIcon(type),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getAccountTypeDisplayName(type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% • $count account${count > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccountsList() {
    if (_accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.blue[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No accounts yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start by adding your first account to track your finances',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  _buildFeatureCard(
                    icon: Icons.account_balance,
                    title: 'Bank Accounts',
                    description: 'Track your savings and current accounts',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.credit_card,
                    title: 'Cards',
                    description: 'Monitor credit and debit card balances',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Cash & Digital',
                    description: 'Track physical cash and digital wallets',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showAddAccountDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group accounts by type for better organization
    final Map<String, List<Account>> groupedAccounts = {};
    for (final account in _accounts) {
      final type = account.type;
      if (!groupedAccounts.containsKey(type)) {
        groupedAccounts[type] = [];
      }
      groupedAccounts[type]!.add(account);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedAccounts.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '₹${_totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _totalBalance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final type = groupedAccounts.keys.elementAt(index - 1);
        final accountsOfType = groupedAccounts[type]!;
        final totalForType = accountsOfType.fold(0.0, (sum, acc) => sum + acc.balance);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAccountColor(type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAccountIcon(type),
                      color: _getAccountColor(type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAccountTypeDisplayName(type),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${accountsOfType.length} account${accountsOfType.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${totalForType.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: totalForType >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            ...accountsOfType.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: common_widgets.AccountCard(
                account: account,
                onTap: () => _showAccountDetails(account),
                onEdit: () => _showEditAccountDialog(account),
                onDelete: () => _showDeleteAccountDialog(account),
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAccountColor(account.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAccountIcon(account.type),
                color: _getAccountColor(account.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Account Type', _getAccountTypeDisplayName(account.type)),
            _buildDetailRow('Balance', '₹${account.balance.toStringAsFixed(2)}'),
            if (account.limit != null)
              _buildDetailRow('Spending Limit', '₹${account.limit!.toStringAsFixed(2)}'),
            _buildDetailRow('Created', DateFormat('MMM dd, yyyy').format(account.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditAccountDialog(account);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank Accounts';
      case 'credit':
        return 'Credit Cards';
      case 'debit':
        return 'Debit Cards';
      case 'savings':
        return 'Savings';
      case 'investment':
        return 'Investments';
      case 'loan':
        return 'Loans';
      case 'digital':
        return 'Digital Wallets';
      case 'crypto':
        return 'Cryptocurrency';
      case 'business':
        return 'Business';
      default:
        return type;
    }
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getAccountColor(account.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            account.icon != null
                ? CategoryService.getIconData(account.icon!)
                : _getAccountIcon(account.type),
            color: _getAccountColor(account.type),
            size: 28,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAccountColor(account.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAccountColor(account.type).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                account.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: _getAccountColor(account.type),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (account.limit != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 12,
                    color: account.balance > account.limit!
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Limit: ₹${account.limit!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: account.balance > account.limit!
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Created ${DateFormat('MMM dd, yyyy').format(account.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat.currency(symbol: '₹').format(account.balance),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: account.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: account.balance >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.balance >= 0 ? 'Positive' : 'Negative',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleAccountAction(value, account),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Account'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final limitController = TextEditingController();
    final customTypeController = TextEditingController();
    String selectedType = 'cash';
    String? selectedIcon;
    bool isCustomType = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add New Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Cash, HDFC Bank, Credit Card',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Account Type:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildAccountTypeGrid(
                  selectedType: selectedType,
                  isCustomType: isCustomType,
                  onTypeSelected: (type, custom) {
                    setState(() {
                      selectedType = type;
                      isCustomType = custom;
                    });
                  },
                ),
                if (isCustomType) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: customTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Account Type',
                      hintText: 'e.g., Digital Wallet, Crypto, Business',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Icon for Custom Type:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildIconPicker(
                    selectedIcon: selectedIcon,
                    onIconSelected: (icon) {
                      setState(() {
                        selectedIcon = icon;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: limitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Spending Limit (Optional)',
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                          prefixText: '₹',
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => common_widgets.IconPicker(
                              selectedIcon: selectedIcon,
                              onIconSelected: (icon) {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              title: 'Select Account Icon',
                            ),
                          );
                        },
                        icon: Icon(
                          selectedIcon != null
                              ? CategoryService.getIconData(selectedIcon!)
                              : Icons.account_balance_wallet,
                        ),
                        label: Text(selectedIcon ?? 'Select Icon'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    balanceController.text.isNotEmpty) {
                  final accountType =
                      isCustomType && customTypeController.text.isNotEmpty
                      ? customTypeController.text
                      : selectedType;

                  final account = Account(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    balance: double.tryParse(balanceController.text) ?? 0,
                    type: accountType,
                    icon: selectedIcon,
                    limit: limitController.text.isNotEmpty
                        ? double.tryParse(limitController.text)
                        : null,
                    createdAt: DateTime.now(),
                  );
                  DataService.addAccount(account);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeGrid({
    required String selectedType,
    required bool isCustomType,
    required Function(String, bool) onTypeSelected,
  }) {
    // Organized account types by category for better UX
    final accountTypeCategories = [
      {
        'category': 'Basic',
        'types': [
          {
            'type': 'cash',
            'name': 'Cash',
            'icon': Icons.account_balance_wallet,
            'color': Colors.green,
            'description': 'Physical cash on hand',
          },
          {
            'type': 'bank',
            'name': 'Bank Account',
            'icon': Icons.account_balance,
            'color': Colors.blue,
            'description': 'Savings or current account',
          },
        ],
      },
      {
        'category': 'Cards',
        'types': [
          {
            'type': 'credit',
            'name': 'Credit Card',
            'icon': Icons.credit_card,
            'color': Colors.orange,
            'description': 'Credit card account',
          },
          {
            'type': 'debit',
            'name': 'Debit Card',
            'icon': Icons.credit_card,
            'color': Colors.indigo,
            'description': 'Debit card account',
          },
        ],
      },
      {
        'category': 'Savings & Investment',
        'types': [
          {
            'type': 'savings',
            'name': 'Savings',
            'icon': Icons.savings,
            'color': Colors.purple,
            'description': 'High-yield savings',
          },
          {
            'type': 'investment',
            'name': 'Investment',
            'icon': Icons.trending_up,
            'color': Colors.teal,
            'description': 'Stocks, bonds, etc.',
          },
        ],
      },
      {
        'category': 'Digital & Modern',
        'types': [
          {
            'type': 'digital',
            'name': 'Digital Wallet',
            'icon': Icons.phone_android,
            'color': Colors.cyan,
            'description': 'PayPal, Google Pay, etc.',
          },
          {
            'type': 'crypto',
            'name': 'Cryptocurrency',
            'icon': Icons.currency_bitcoin,
            'color': Colors.amber,
            'description': 'Bitcoin, Ethereum, etc.',
          },
        ],
      },
      {
        'category': 'Other',
        'types': [
          {
            'type': 'loan',
            'name': 'Loan',
            'icon': Icons.account_balance_wallet,
            'color': Colors.red,
            'description': 'Personal or business loan',
          },
          {
            'type': 'business',
            'name': 'Business',
            'icon': Icons.business,
            'color': Colors.brown,
            'description': 'Business account',
          },
          {
            'type': 'custom',
            'name': 'Custom Type',
            'icon': Icons.add_circle_outline,
            'color': Colors.grey,
            'description': 'Create your own type',
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: accountTypeCategories.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category['category'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemCount: (category['types'] as List).length,
              itemBuilder: (context, index) {
                final type = (category['types'] as List)[index];
                final isSelected =
                    selectedType == type['type'] ||
                    (isCustomType && type['type'] == 'custom');

                return GestureDetector(
                  onTap: () => onTypeSelected(
                    type['type'] as String,
                    type['type'] == 'custom',
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type['color'] as Color
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? type['color'] as Color
                            : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (type['color'] as Color).withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : (type['color'] as Color).withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : type['color'] as Color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            type['name'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            type['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker({
    required String? selectedIcon,
    required Function(String) onIconSelected,
  }) {
    final availableIcons = [
      {'icon': Icons.account_balance_wallet, 'name': 'wallet'},
      {'icon': Icons.account_balance, 'name': 'bank'},
      {'icon': Icons.credit_card, 'name': 'card'},
      {'icon': Icons.savings, 'name': 'savings'},
      {'icon': Icons.trending_up, 'name': 'investment'},
      {'icon': Icons.phone_android, 'name': 'mobile'},
      {'icon': Icons.currency_bitcoin, 'name': 'crypto'},
      {'icon': Icons.business, 'name': 'business'},
      {'icon': Icons.school, 'name': 'education'},
      {'icon': Icons.medical_services, 'name': 'health'},
      {'icon': Icons.home, 'name': 'home'},
      {'icon': Icons.shopping_cart, 'name': 'shopping'},
      {'icon': Icons.restaurant, 'name': 'food'},
      {'icon': Icons.directions_car, 'name': 'transport'},
      {'icon': Icons.movie, 'name': 'entertainment'},
      {'icon': Icons.work, 'name': 'work'},
      {'icon': Icons.family_restroom, 'name': 'family'},
      {'icon': Icons.sports_soccer, 'name': 'sports'},
      {'icon': Icons.flight, 'name': 'travel'},
      {'icon': Icons.favorite, 'name': 'personal'},
    ];

    return SizedBox(
      height: 120,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: availableIcons.length,
        itemBuilder: (context, index) {
          final iconData = availableIcons[index];
          final isSelected = selectedIcon == iconData['name'];

          return GestureDetector(
            onTap: () => onIconSelected(iconData['name'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                iconData['icon'] as IconData,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAccountAction(String action, Account account) {
    switch (action) {
      case 'edit':
        _showEditAccountDialog(account);
        break;
      case 'delete':
        _showDeleteAccountDialog(account);
        break;
    }
  }

  void _showEditAccountDialog(Account account) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(
      text: account.balance.toString(),
    );
    final limitController = TextEditingController(
      text: account.limit?.toString() ?? '',
    );
    String selectedType = account.type;
    String? selectedIcon = account.icon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Balance',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Spending Limit (Optional)',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Account Type:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildAccountTypeGrid(
                  selectedType: selectedType,
                  isCustomType: false,
                  onTypeSelected: (type, custom) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => common_widgets.IconPicker(
                              selectedIcon: selectedIcon,
                              onIconSelected: (icon) {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              title: 'Select Account Icon',
                            ),
                          );
                        },
                        icon: Icon(
                          selectedIcon != null
                              ? CategoryService.getIconData(selectedIcon!)
                              : _getAccountIcon(selectedType),
                        ),
                        label: Text(selectedIcon ?? 'Change Icon'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    balanceController.text.isNotEmpty) {
                  final updatedAccount = account.copyWith(
                    name: nameController.text,
                    balance: double.tryParse(balanceController.text) ?? 0,
                    type: selectedType,
                    icon: selectedIcon,
                    limit: limitController.text.isNotEmpty
                        ? double.tryParse(limitController.text)
                        : null,
                  );
                  DataService.updateAccount(updatedAccount);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete "${account.name}"?',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              DataService.deleteAccount(account.id);
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getAccountColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'credit':
        return Colors.orange;
      case 'debit':
        return Colors.indigo;
      case 'savings':
        return Colors.purple;
      case 'investment':
        return Colors.teal;
      case 'loan':
        return Colors.red;
      case 'digital':
        return Colors.cyan;
      case 'crypto':
        return Colors.amber;
      case 'business':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
      case 'debit':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'digital':
        return Icons.phone_android;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'business':
        return Icons.business;
      default:
        return Icons.account_balance;
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
