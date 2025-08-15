import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsAnalytics extends StatelessWidget {
  final Map<String, dynamic> analytics;
  final List<Map<String, dynamic>> topExpenses;
  final List<Map<String, dynamic>> spendingInsights;

  const ReportsAnalytics({
    super.key,
    required this.analytics,
    required this.topExpenses,
    required this.spendingInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Analytics Section
        if (analytics.isNotEmpty) ...[
          const Text(
            'Analytics & Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Analytics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              if (analytics['averageDailySpending'] != null)
                _buildAnalyticsCard(
                  'Average Daily Spending',
                  NumberFormat.currency(
                    symbol: '₹',
                  ).format(analytics['averageDailySpending']),
                  Icons.trending_up,
                  Colors.blue,
                ),
              if (analytics['savingsRate'] != null)
                _buildAnalyticsCard(
                  'Savings Rate',
                  '${analytics['savingsRate'].toStringAsFixed(1)}%',
                  Icons.savings,
                  Colors.green,
                ),
              if (analytics['spendingTrend'] != null)
                _buildAnalyticsCard(
                  'Spending Trend',
                  '${analytics['spendingTrend'] > 0 ? '+' : ''}${analytics['spendingTrend'].toStringAsFixed(1)}%',
                  analytics['spendingTrend'] > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  analytics['spendingTrend'] > 0 ? Colors.red : Colors.green,
                ),
              if (analytics['mostExpensiveDay'] != null)
                _buildAnalyticsCard(
                  'Most Expensive Day',
                  NumberFormat.currency(
                    symbol: '₹',
                  ).format(analytics['mostExpensiveDay']['amount']),
                  Icons.calendar_today,
                  Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Top Expenses Section
        if (topExpenses.isNotEmpty) ...[
          const Text(
            'Top 5 Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topExpenses.length,
            itemBuilder: (context, index) {
              final expense = topExpenses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(expense['category']),
                    child: Text(
                      expense['category'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(expense['title']),
                  subtitle: Text(expense['category']),
                  trailing: Text(
                    NumberFormat.currency(
                      symbol: '₹',
                    ).format(expense['amount']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Spending Insights Section
        if (spendingInsights.isNotEmpty) ...[
          const Text(
            'Spending Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: spendingInsights.length,
            itemBuilder: (context, index) {
              final insight = spendingInsights[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    insight['type'] == 'top_category'
                        ? Icons.category
                        : insight['type'] == 'weekly_pattern'
                        ? Icons.calendar_view_week
                        : Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(insight['title']),
                  subtitle: Text(insight['value']),
                  trailing: insight['amount'] != null
                      ? Text(
                          NumberFormat.currency(
                            symbol: '₹',
                          ).format(insight['amount']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
      Colors.grey,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];

    final index = category.hashCode % colors.length;
    return colors[index];
  }
}
