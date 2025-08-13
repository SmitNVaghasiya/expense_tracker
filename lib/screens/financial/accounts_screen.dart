import 'package:flutter/material.dart';
import 'package:spendwise/models/account.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Accounts'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
                _buildTotalBalanceSection(),
                const SizedBox(height: 24),

                // Accounts List Section
                _buildAccountsListSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
            color: Colors.green.withOpacity(0.3),
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

  Widget _buildAccountsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Accounts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${_accounts.length} account${_accounts.length != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_accounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No accounts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first account to start tracking your finances',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _accounts
                .map((account) => _buildAccountCard(account))
                .toList(),
          ),
      ],
    );
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
            color: _getAccountColor(account.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getAccountIcon(account.type),
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
            Text(
              account.type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
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
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
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
    String selectedType = 'cash';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
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
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cash'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Bank Account'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'credit',
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Credit Card'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'savings',
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Savings'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
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
              if (nameController.text.isNotEmpty &&
                  balanceController.text.isNotEmpty) {
                final account = Account(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  balance: double.tryParse(balanceController.text) ?? 0,
                  type: selectedType,
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
    String selectedType = account.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
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
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cash'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Bank Account'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'credit',
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Credit Card'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'savings',
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Savings'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
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
              if (nameController.text.isNotEmpty &&
                  balanceController.text.isNotEmpty) {
                final updatedAccount = account.copyWith(
                  name: nameController.text,
                  balance: double.tryParse(balanceController.text) ?? 0,
                  type: selectedType,
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
    switch (type) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'credit':
        return Colors.orange;
      case 'savings':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.account_balance;
    }
  }
}
