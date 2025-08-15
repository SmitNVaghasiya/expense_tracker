import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/models/transaction.dart';

class ReportsSpendingPatterns extends StatelessWidget {
  final List<Transaction> filteredTransactions;

  const ReportsSpendingPatterns({
    super.key,
    required this.filteredTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = filteredTransactions.where((t) => t.type == 'expense').toList();
    
    if (expenses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Patterns',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Day of Week Spending Pattern
        _buildDayOfWeekPattern(expenses),
        const SizedBox(height: 16),

        // Time of Day Spending Pattern
        _buildTimeOfDayPattern(expenses),
      ],
    );
  }

  Widget _buildDayOfWeekPattern(List<Transaction> expenses) {
    final dayOfWeekSpending = <int, double>{};
    for (final expense in expenses) {
      final weekday = expense.date.weekday;
      dayOfWeekSpending[weekday] = (dayOfWeekSpending[weekday] ?? 0) + expense.amount;
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxSpending = dayOfWeekSpending.values.fold(
      0.0,
      (max, value) => value > max ? value : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Day of Week',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final day = index + 1;
              final spending = dayOfWeekSpending[day] ?? 0;
              final height = maxSpending > 0 ? (spending / maxSpending) : 0;

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: height.toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dayNames[index], style: const TextStyle(fontSize: 10)),
                  Text(
                    '₹${NumberFormat.compact().format(spending)}',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOfDayPattern(List<Transaction> expenses) {
    final timeOfDaySpending = <int, double>{};
    for (final expense in expenses) {
      final hour = expense.date.hour;
      final timeSlot = (hour / 6).floor(); // 0-3: 0-5, 6-11, 12-17, 18-23
      timeOfDaySpending[timeSlot] = (timeOfDaySpending[timeSlot] ?? 0) + expense.amount;
    }

    final timeLabels = ['12AM-6AM', '6AM-12PM', '12PM-6PM', '6PM-12AM'];
    final maxSpending = timeOfDaySpending.values.fold(
      0.0,
      (max, value) => value > max ? value : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Time of Day',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final spending = timeOfDaySpending[index] ?? 0;
              final height = maxSpending > 0 ? (spending / maxSpending) : 0;

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: height.toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabels[index],
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '₹${NumberFormat.compact().format(spending)}',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
