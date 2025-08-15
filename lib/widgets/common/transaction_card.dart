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
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (accountName != null)
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                accountName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        if (!isCompact)
                          Text(
                            DateFormat('MMM dd, yyyy').format(transaction.date),
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

                  // Transaction Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense
                            ? '-'
                            : isIncome
                            ? '+'
                            : ''}${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(transaction.amount)}',
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: getTransactionColor(),
                        ),
                      ),
                      if (!isCompact)
                        Text(
                          transaction.notes?.isNotEmpty == true
                              ? transaction.notes!
                              : 'No notes',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
