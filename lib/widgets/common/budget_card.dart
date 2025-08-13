import 'package:flutter/material.dart';
import 'package:spendwise/models/budget.dart';
import 'package:intl/intl.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spentAmount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;
  final Color? customColor;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spentAmount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = budget.limit - spentAmount;
    final progressPercentage = (spentAmount / budget.limit).clamp(0.0, 1.0);
    final isOverBudget = spentAmount > budget.limit;
    final isNearLimit = progressPercentage >= 0.8;

    Color getProgressColor() {
      if (customColor != null) return customColor!;
      if (isOverBudget) return Colors.red;
      if (isNearLimit) return Colors.orange;
      return Colors.green;
    }

    Color getBudgetColor() {
      if (isOverBudget) return Colors.red;
      if (isNearLimit) return Colors.orange;
      return Colors.green;
    }

    IconData getBudgetIcon() {
      if (isOverBudget) return Icons.warning;
      if (isNearLimit) return Icons.info;
      return Icons.check_circle;
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
                  // Budget Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getProgressColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getBudgetIcon(),
                      color: getProgressColor(),
                      size: isCompact ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Budget Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
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
                            budget.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                        if (!isCompact) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd').format(budget.endDate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Budget Amounts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                          decimalDigits: 2,
                        ).format(budget.limit),
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(spentAmount)} spent',
                          style: TextStyle(
                            fontSize: 11,
                            color: getBudgetColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Progress Bar
              if (!isCompact) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${(progressPercentage * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getProgressColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        getProgressColor(),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(remainingAmount)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (isOverBudget)
                          Text(
                            'Over by ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(-remainingAmount)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],

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
