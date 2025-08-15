import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/services/reports/reports_data_service.dart';

class ReportsCharts extends StatelessWidget {
  final Map<String, double> expenseCategories;
  final Map<String, double> incomeCategories;
  final List<Map<String, dynamic>> monthlyData;
  final double totalExpenses;
  final double totalIncome;

  const ReportsCharts({
    super.key,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.monthlyData,
    required this.totalExpenses,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Breakdown - Side by side pie charts
        if (expenseCategories.isNotEmpty || incomeCategories.isNotEmpty) ...[
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Side by side pie charts for better comparison
          Row(
            children: [
              // Expense Categories Pie Chart
              if (expenseCategories.isNotEmpty) ...[
                Expanded(
                  child: _buildPieChart(
                    title: 'Expense Categories',
                    categories: expenseCategories,
                    total: totalExpenses,
                    isExpense: true,
                  ),
                ),
              ],

              // Income Categories Pie Chart
              if (incomeCategories.isNotEmpty) ...[
                if (expenseCategories.isNotEmpty) const SizedBox(width: 16),
                Expanded(
                  child: _buildPieChart(
                    title: 'Income Categories',
                    categories: incomeCategories,
                    total: totalIncome,
                    isExpense: false,
                  ),
                ),
              ],
            ],
          ),

          // Full category legends below charts for better readability
          const SizedBox(height: 16),
          if (expenseCategories.isNotEmpty) ...[
            _buildCategoryLegend('Expense Categories (Full List)', expenseCategories),
            const SizedBox(height: 16),
          ],

          if (incomeCategories.isNotEmpty) ...[
            _buildCategoryLegend('Income Categories (Full List)', incomeCategories),
            const SizedBox(height: 24),
          ],
        ],

        // Monthly Trends
        if (monthlyData.isNotEmpty) ...[
          const Text(
            'Monthly Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMonthlyTrendsChart(),
        ],
      ],
    );
  }

  Widget _buildPieChart({
    required String title,
    required Map<String, double> categories,
    required double total,
    required bool isExpense,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: categories.entries.map((entry) {
                final percentage = (total > 0) ? (entry.value / total * 100) : 0;
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 50,
                  color: ReportsDataService.getCategoryColor(entry.key),
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Compact category legend
        Wrap(
          spacing: 4,
          runSpacing: 2,
          children: categories.entries.take(4).map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: ReportsDataService.getCategoryColor(entry.key).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.key}: ₹${NumberFormat.compact().format(entry.value)}',
                style: TextStyle(
                  fontSize: 10,
                  color: ReportsDataService.getCategoryColor(entry.key),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryLegend(String title, Map<String, double> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categories.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: ReportsDataService.getCategoryColor(entry.key).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.key}: ${NumberFormat.currency(symbol: '₹').format(entry.value)}',
                style: TextStyle(
                  fontSize: 12,
                  color: ReportsDataService.getCategoryColor(entry.key),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendsChart() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: monthlyData.fold(
                0.0,
                (max, data) => (data['expenses'] + data['income']) > max
                    ? (data['expenses'] + data['income'])
                    : max,
              ) * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthlyData[value.toInt()]['month'],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        NumberFormat.compact().format(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: monthlyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data['expenses'],
                      color: Colors.red,
                      width: 8,
                    ),
                    BarChartRodData(
                      toY: data['income'],
                      color: Colors.green,
                      width: 8,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            const Text('Expenses', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            const Text('Income', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
