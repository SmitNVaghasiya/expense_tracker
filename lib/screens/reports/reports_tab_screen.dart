import 'package:flutter/material.dart';
import 'package:spendwise/screens/reports/widgets/reports_summary_card.dart';
import 'package:spendwise/screens/reports/widgets/reports_charts.dart';
import 'package:spendwise/screens/reports/widgets/reports_analytics.dart';
import 'package:spendwise/screens/reports/widgets/reports_spending_patterns.dart';
import 'package:spendwise/screens/reports/widgets/reports_budget_adherence.dart';
import 'package:spendwise/screens/reports/widgets/reports_date_filter.dart';
import 'package:spendwise/services/reports/reports_data_service.dart';
import 'package:spendwise/screens/transactions/calculator_transaction_screen.dart';
import 'package:intl/intl.dart';

class ReportsTabScreen extends StatefulWidget {
  const ReportsTabScreen({super.key});

  @override
  State<ReportsTabScreen> createState() => _ReportsTabScreenState();
}

class _ReportsTabScreenState extends State<ReportsTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReportsDataService _dataService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dataService = ReportsDataService();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _dataService.loadData();

    setState(() {
      _isLoading = false;
    });
  }

  void _onDateRangeOptionChanged(String option) {
    setState(() {
      _dataService.selectedDateRangeOption = option;
      _dataService.selectedDateRange = null;
    });
    _loadData();
  }

  void _onCustomDateRangeRequested() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
      initialDateRange: _dataService.selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataService.selectedDateRange = picked;
        _dataService.selectedDateRangeOption = 'Custom Range';
      });
      _loadData();
    }
  }

  void _onBudgetPeriodChanged(String period) {
    setState(() {
      _dataService.budgetAdherencePeriod = period;
    });
    _loadData();
  }

  Future<void> _handleAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalculatorTransactionScreen(initialType: 'expense'),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Budget', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            tooltip: 'Select Date Range',
            onSelected: (value) {
              if (value == 'Custom Range') {
                _onCustomDateRangeRequested();
              } else {
                _onDateRangeOptionChanged(value);
              }
            },
            itemBuilder: (context) => ReportsDataService.dateRangeOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    Text(option),
                    if (option == _dataService.selectedDateRangeOption)
                      const Icon(Icons.check, size: 16),
                  ],
                ),
                  );
                }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildAnalyticsTab(),
                  _buildBudgetTab(),
                  _buildTrendsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter
            ReportsDateFilter(
              selectedDateRangeOption: _dataService.selectedDateRangeOption,
              selectedDateRange: _dataService.selectedDateRange,
              onDateRangeOptionChanged: _onDateRangeOptionChanged,
              onCustomDateRangeRequested: _onCustomDateRangeRequested,
            ),

            // Summary Card
            ReportsSummaryCard(
              balance: _dataService.balance,
              totalIncome: _dataService.totalIncome,
              totalExpenses: _dataService.totalExpenses,
            ),
            const SizedBox(height: 24),

            // Summary Metrics for Selected Date Range
            if (_dataService.filteredTransactions.isNotEmpty) ...[
              const Text(
                'Summary for Selected Period',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Transactions',
                      _dataService.filteredTransactions.length.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Expense Transactions',
                      _dataService.filteredTransactions
                          .where((t) => t.type == 'expense')
                          .length
                          .toString(),
                      Icons.trending_down,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Income Transactions',
                      _dataService.filteredTransactions
                          .where((t) => t.type == 'income')
                          .length
                          .toString(),
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Charts
            ReportsCharts(
              expenseCategories: _dataService.expenseCategories,
              incomeCategories: _dataService.incomeCategories,
              monthlyData: _dataService.monthlyData,
              totalExpenses: _dataService.totalExpenses,
              totalIncome: _dataService.totalIncome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics
            ReportsAnalytics(
              analytics: _dataService.analytics,
              topExpenses: _dataService.topExpenses,
              spendingInsights: _dataService.spendingInsights,
            ),

            // Spending Patterns
            if (_dataService.expenseCategories.isNotEmpty) ...[
              const SizedBox(height: 24),
              ReportsSpendingPatterns(
                filteredTransactions: _dataService.filteredTransactions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportsBudgetAdherence(
              monthlyBudgetAdherence: _dataService.monthlyBudgetAdherence,
              yearlyBudgetAdherence: _dataService.yearlyBudgetAdherence,
              budgetAdherencePeriod: _dataService.budgetAdherencePeriod,
              onPeriodChanged: _onBudgetPeriodChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Trends (already in Overview, but can be expanded here)
            if (_dataService.monthlyData.isNotEmpty) ...[
              const Text(
                'Monthly Trends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // You can add more trend analysis here
              Text(
                'Showing ${_dataService.monthlyData.length} months of data',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Additional trend analysis can be added here
            const Text(
              'Trend Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'More trend analysis features coming soon...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
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
