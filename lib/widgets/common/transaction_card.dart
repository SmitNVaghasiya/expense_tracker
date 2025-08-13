import 'package:flutter/material.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String? accountName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;
  final Color? customColor;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.accountName,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final isIncome = transaction.type == 'income';
    final isTransfer = transaction.type == 'transfer';

    Color getTransactionColor() {
      if (customColor != null) return customColor!;
      if (isExpense) return Colors.red;
      if (isIncome) return Colors.green;
      if (isTransfer) return Colors.blue;
      return Theme.of(context).colorScheme.primary;
    }

    IconData getTransactionIcon() {
      if (isExpense) return Icons.remove_circle_outline;
      if (isIncome) return Icons.add_circle_outline;
      if (isTransfer) return Icons.swap_horiz;
      return Icons.account_balance_wallet;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            children: [
              Row(
                children: [
                  // Transaction Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getTransactionColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getTransactionIcon(),
                      color: getTransactionColor(),
                      size: isCompact ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: TextStyle(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isCompact) ...[
                          const SizedBox(height: 4),
                          Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                        if (accountName != null && !isCompact) ...[
                          const SizedBox(height: 2),
                          Text(
                            accountName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Amount and Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense
                            ? '-'
                            : isIncome
                            ? '+'
                            : ''}${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(transaction.amount)}',
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: getTransactionColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd').format(transaction.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}
