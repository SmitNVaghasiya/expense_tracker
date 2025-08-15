import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportsBudgetAdherence extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyBudgetAdherence;
  final List<Map<String, dynamic>> yearlyBudgetAdherence;
  final String budgetAdherencePeriod;
  final Function(String) onPeriodChanged;

  const ReportsBudgetAdherence({
    super.key,
    required this.monthlyBudgetAdherence,
    required this.yearlyBudgetAdherence,
    required this.budgetAdherencePeriod,
    required this.onPeriodChanged,
  });

  @override
  State<ReportsBudgetAdherence> createState() => _ReportsBudgetAdherenceState();
}

class _ReportsBudgetAdherenceState extends State<ReportsBudgetAdherence> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Adherence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: widget.budgetAdherencePeriod,
              items: ['Monthly', 'Yearly'].map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onPeriodChanged(value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        FutureBuilder(
          future: Future.value(), // Just to trigger rebuild
          builder: (context, snapshot) {
            final adherenceData = widget.budgetAdherencePeriod == 'Monthly'
                ? widget.monthlyBudgetAdherence
                : widget.yearlyBudgetAdherence;

            if (adherenceData.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 12),
                    Text(
                      'No budget data available for the selected period.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Budget Adherence Chart
                SizedBox(
                  height: 200,
                  child: _buildBudgetAdherenceChart(adherenceData),
                ),
                const SizedBox(height: 16),

                // Budget Adherence Summary
                _buildBudgetAdherenceSummary(adherenceData),
                const SizedBox(height: 16),

                // Budget Adherence Details
                _buildBudgetAdherenceDetails(adherenceData),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetAdherenceChart(List<Map<String, dynamic>> adherenceData) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < adherenceData.length) {
                  final data = adherenceData[value.toInt()];
                  return Text(
                    widget.budgetAdherencePeriod == 'Monthly'
                        ? data['monthName']
                        : data['year'].toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: adherenceData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['categoryBudgetAdherence'],
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: adherenceData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['overallBudgetAdherence'],
              );
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildBudgetAdherenceSummary(List<Map<String, dynamic>> adherenceData) {
    final latestData = adherenceData.isNotEmpty ? adherenceData.last : null;
    if (latestData == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Category Adherence',
            '${latestData['categoryBudgetAdherence'].toStringAsFixed(1)}%',
            Icons.category,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Overall Adherence',
            '${latestData['overallBudgetAdherence'].toStringAsFixed(1)}%',
            Icons.pie_chart,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Budget Utilization',
            '${latestData['budgetUtilization'].toStringAsFixed(1)}%',
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetAdherenceDetails(List<Map<String, dynamic>> adherenceData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Breakdown',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adherenceData.length,
          itemBuilder: (context, index) {
            final data = adherenceData[index];
            final adherence = data['categoryBudgetAdherence'];
            final overallAdherence = data['overallBudgetAdherence'];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.budgetAdherencePeriod == 'Monthly'
                              ? data['monthName']
                              : 'Year ${data['year']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: adherence >= 80
                                    ? Colors.green
                                    : adherence >= 60
                                    ? Colors.orange
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${adherence.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories: ${data['categoriesWithBudgets']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Under Budget: ${data['categoriesUnderBudget']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Over Budget: ${data['categoriesOverBudget']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Overall: ${overallAdherence.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Spent: ${NumberFormat.currency(symbol: '₹').format(data['totalSpent'])}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (data['overallBudgetLimit'] > 0)
                                Text(
                                  'Limit: ${NumberFormat.currency(symbol: '₹').format(data['overallBudgetLimit'])}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
}
