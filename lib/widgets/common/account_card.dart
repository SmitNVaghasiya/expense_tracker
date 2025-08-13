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
        case 'investment':
          return Icons.trending_up;
        case 'cash':
          return Icons.money;
        default:
          return Icons.account_balance_wallet;
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
                        color: balanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            getAccountIcon(),
                            color: balanceColor,
                            size: isCompact ? 20 : 24,
                          ),
                          if (isNegativeBalance)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Account Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  account.name,
                                  style: TextStyle(
                                    fontSize: isCompact ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: isNegativeBalance
                                        ? Colors.red[700]
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isNegativeBalance)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Low Balance',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: balanceColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  account.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: balanceColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isNegativeBalance)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 10,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Add Income',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (!isCompact) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Created ${DateFormat('MMM dd, yyyy').format(account.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Balance
                    if (showBalance) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(account.balance),
                            style: TextStyle(
                              fontSize: isCompact ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: balanceColor,
                            ),
                          ),
                          if (!isCompact) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'USD',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                if (isNegativeBalance) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.trending_down,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),

                // Actions Row
                if (showActions && (onEdit != null || onDelete != null)) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 0),
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 8),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 0),
                            foregroundColor: Colors.red,
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
