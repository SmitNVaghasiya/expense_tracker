import 'package:flutter/material.dart';
import 'package:spendwise/models/account.dart';
import 'package:intl/intl.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;
  final Color? customColor;
  final bool showBalance;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
    this.customColor,
    this.showBalance = true,
  });

  @override
  Widget build(BuildContext context) {
    Color getAccountColor() {
      if (customColor != null) return customColor!;
      if (account.balance >= 0) return Colors.green;
      return Colors.red;
    }

    IconData getAccountIcon() {
      switch (account.type.toLowerCase()) {
        case 'savings':
          return Icons.savings;
        case 'checking':
        case 'bank':
          return Icons.account_balance;
        case 'credit':
          return Icons.credit_card;
        case 'debit':
          return Icons.credit_card;
        case 'investment':
          return Icons.trending_up;
        case 'cash':
          return Icons.account_balance_wallet;
        case 'loan':
          return Icons.account_balance_wallet;
        case 'digital':
          return Icons.phone_android;
        case 'crypto':
          return Icons.currency_bitcoin;
        case 'business':
          return Icons.business;
        default:
          return Icons.account_balance_wallet;
      }
    }

    Color getAccountTypeColor() {
      switch (account.type.toLowerCase()) {
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

    String getAccountTypeDisplayName() {
      switch (account.type.toLowerCase()) {
        case 'cash':
          return 'Cash';
        case 'bank':
          return 'Bank';
        case 'credit':
          return 'Credit Card';
        case 'debit':
          return 'Debit Card';
        case 'savings':
          return 'Savings';
        case 'investment':
          return 'Investment';
        case 'loan':
          return 'Loan';
        case 'digital':
          return 'Digital Wallet';
        case 'crypto':
          return 'Crypto';
        case 'business':
          return 'Business';
        default:
          return account.type;
      }
    }

    final isNegativeBalance = account.balance < 0;
    final balanceColor = getAccountColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isNegativeBalance
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isNegativeBalance ? Colors.red.withOpacity(0.02) : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Account Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: getAccountTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        getAccountIcon(),
                        color: getAccountTypeColor(),
                        size: isCompact ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Account Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              fontSize: isCompact ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            account.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          if (!isCompact)
                            Text(
                              'Created ${DateFormat('MMM dd, yyyy').format(account.createdAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Balance and Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(
                            symbol: '₹',
                            decimalDigits: 2,
                          ).format(account.balance),
                          style: TextStyle(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                        if (!isCompact)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: balanceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isNegativeBalance ? 'Negative' : 'Positive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: balanceColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Actions Row
                if (showActions && !isCompact) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: Icon(
                            Icons.edit,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 8),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          label: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
