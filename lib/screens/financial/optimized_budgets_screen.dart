import 'package:flutter/material.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/budget_service.dart';
import 'package:spendwise/screens/financial/base_financial_screen.dart';
import 'package:spendwise/core/performance_mixins.dart';
import 'package:intl/intl.dart';

class OptimizedBudgetsScreen extends BaseFinancialScreen {
  const OptimizedBudgetsScreen({super.key})
      : super(
          screenTitle: 'Budgets',
          screenIcon: Icons.pie_chart,
          primaryColor: Colors.blue,
          floatingActionButtonTooltip: 'Add Category',
        );

  @override
  State<OptimizedBudgetsScreen> createState() => _OptimizedBudgetsScreenState();
}

class _OptimizedBudgetsScreenState extends State<OptimizedBudgetsScreen>
    with ValueNotifierMixin, EfficientListMixin, ScrollPerformanceMixin {
  // ValueNotifiers for efficient state management
  late final ValueNotifier<List<Budget>> _budgetsNotifier;
  late final ValueNotifier<List<OverallBudget>> _overallBudgetsNotifier;
  late final ValueNotifier<List<Transaction>> _transactionsNotifier;
  late final ValueNotifier<DateTime> _selectedMonthNotifier;
  late final ValueNotifier<double> _totalBudgetNotifier;
  late final ValueNotifier<double> _overallBudgetLimitNotifier;
  late final ValueNotifier<double> _totalSpentNotifier;
  late final ValueNotifier<double> _totalIncomeNotifier;
  late final ValueNotifier<double> _salaryIncomeNotifier;
  late final ValueNotifier<double> _effectiveIncomeNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _budgetAlertsNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _budgetRecommendationsNotifier;
  
  // Progressive loading states
  late final ValueNotifier<bool> _isLoadingEssentialDataNotifier;
  late final ValueNotifier<bool> _isLoadingBudgetAlertsNotifier;
  late final ValueNotifier<bool> _isLoadingRecommendationsNotifier;
  late final ValueNotifier<bool> _isLoadingInsightsNotifier;
  late final ValueNotifier<bool> _isLoadingCategoriesNotifier;

  // Predefined categories with expanded icon options
  // Note: These categories are defined but not currently used in this implementation
  // They can be used for future features like category suggestions or quick setup
  /*
  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red[700]!,
    },
    {'name': 'Grants', 'icon': Icons.card_giftcard, 'color': Colors.teal},
    {'name': 'Recovery', 'icon': Icons.refresh, 'color': Colors.green},
    {'name': 'Other', 'icon': Icons.people, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _expenseCategories = [
    // Food & Dining - Multiple icon options
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.red},
    {
      'name': 'Restaurant',
      'icon': Icons.restaurant_menu,
      'color': Colors.red[600]!,
    },
    {'name': 'Fast Food', 'icon': Icons.fastfood, 'color': Colors.red[500]!},
    {'name': 'Coffee', 'icon': Icons.coffee, 'color': Colors.brown[600]!},
    {'name': 'Snacks', 'icon': Icons.local_cafe, 'color': Colors.brown},
    {
      'name': 'Groceries',
      'icon': Icons.shopping_cart,
      'color': Colors.orange[600]!,
    },
    {'name': 'Bakery', 'icon': Icons.cake, 'color': Colors.orange[500]!},

    // Transportation - Multiple icon options
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {'name': 'Car', 'icon': Icons.directions_car, 'color': Colors.blue[600]!},
    {'name': 'Bus', 'icon': Icons.directions_bus, 'color': Colors.blue[500]!},
    {'name': 'Train', 'icon': Icons.train, 'color': Colors.blue[700]!},
    {'name': 'Metro', 'icon': Icons.subway, 'color': Colors.blue[800]!},
    {'name': 'Taxi', 'icon': Icons.local_taxi, 'color': Colors.yellow[700]!},
    {
      'name': 'Auto Rickshaw',
      'icon': Icons.directions_bus,
      'color': Colors.blue,
    },
    {'name': 'Bike', 'icon': Icons.motorcycle, 'color': Colors.purple},
    {'name': 'Bicycle', 'icon': Icons.pedal_bike, 'color': Colors.green[600]!},
    {
      'name': 'Walking',
      'icon': Icons.directions_walk,
      'color': Colors.green[500]!,
    },

    // Shopping & Retail - Multiple icon options
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Colors.orange},
    {
      'name': 'Shoes',
      'icon': Icons.sports_soccer,
      'color': Colors.orange[600]!,
    },
    {'name': 'Accessories', 'icon': Icons.watch, 'color': Colors.orange[500]!},
    {'name': 'Jewelry', 'icon': Icons.diamond, 'color': Colors.amber[600]!},
    {'name': 'Cosmetics', 'icon': Icons.face, 'color': Colors.pink[400]!},
    {'name': 'Books', 'icon': Icons.book, 'color': Colors.indigo[600]!},
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.teal},
    {'name': 'Gadgets', 'icon': Icons.phone_iphone, 'color': Colors.teal[600]!},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.purple[600]!},

    // Entertainment & Leisure - Multiple icon options
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.pink},
    {'name': 'Movies', 'icon': Icons.movie, 'color': Colors.pink[500]!},
    {
      'name': 'Theater',
      'icon': Icons.theater_comedy,
      'color': Colors.pink[600]!,
    },
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.purple[400]!},
    {
      'name': 'Concerts',
      'icon': Icons.music_note,
      'color': Colors.purple[500]!,
    },
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
    {'name': 'Gym', 'icon': Icons.fitness_center, 'color': Colors.green[600]!},
    {'name': 'Swimming', 'icon': Icons.pool, 'color': Colors.blue[400]!},
    {'name': 'Hiking', 'icon': Icons.terrain, 'color': Colors.green[700]!},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.blue[600]!},
    {
      'name': 'Vacation',
      'icon': Icons.beach_access,
      'color': Colors.blue[500]!,
    },

    // Health & Wellness - Multiple icon options
    {
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': Colors.orange,
    },
    {
      'name': 'Medicine',
      'icon': Icons.medication,
      'color': Colors.orange[600]!,
    },
    {
      'name': 'Dental',
      'icon': Icons.medical_services,
      'color': Colors.orange[500]!,
    },
    {'name': 'Vision', 'icon': Icons.visibility, 'color': Colors.orange[400]!},
    {
      'name': 'Mental Health',
      'icon': Icons.psychology,
      'color': Colors.orange[700]!,
    },
    {
      'name': 'Fitness',
      'icon': Icons.fitness_center,
      'color': Colors.green[600]!,
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': Colors.green[500]!,
    },
    {'name': 'Spa', 'icon': Icons.spa, 'color': Colors.pink[300]!},

    // Education & Learning - Multiple icon options
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo},
    {
      'name': 'University',
      'icon': Icons.account_balance,
      'color': Colors.indigo[600]!,
    },
    {
      'name': 'Online Courses',
      'icon': Icons.computer,
      'color': Colors.indigo[500]!,
    },
    {'name': 'Workshops', 'icon': Icons.work, 'color': Colors.indigo[400]!},
    {
      'name': 'Certifications',
      'icon': Icons.verified,
      'color': Colors.indigo[700]!,
    },
    {'name': 'Tutoring', 'icon': Icons.person, 'color': Colors.indigo[800]!},

    // Home & Utilities - Multiple icon options
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.green},
    {'name': 'Rent', 'icon': Icons.home_work, 'color': Colors.green[600]!},
    {
      'name': 'Mortgage',
      'icon': Icons.account_balance,
      'color': Colors.green[700]!,
    },
    {'name': 'Utilities', 'icon': Icons.electrical_services, 'color': Colors.blue},
    {'name': 'Electricity', 'icon': Icons.flash_on, 'color': Colors.yellow[600]!},
    {'name': 'Water', 'icon': Icons.water_drop, 'color': Colors.blue[400]!},
    {'name': 'Gas', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'name': 'Internet', 'icon': Icons.wifi, 'color': Colors.blue[500]!},
    {'name': 'Phone', 'icon': Icons.phone, 'color': Colors.green[500]!},
    {'name': 'Maintenance', 'icon': Icons.build, 'color': Colors.grey[600]!},
    {'name': 'Insurance', 'icon': Icons.security, 'color': Colors.indigo[500]!},
    {'name': 'Property Tax', 'icon': Icons.receipt, 'color': Colors.red[600]!},

    // Personal Care - Multiple icon options
    {'name': 'Personal Care', 'icon': Icons.person, 'color': Colors.pink},
    {'name': 'Haircut', 'icon': Icons.content_cut, 'color': Colors.pink[500]!},
    {'name': 'Beauty', 'icon': Icons.face, 'color': Colors.pink[400]!},
    {'name': 'Spa', 'icon': Icons.spa, 'color': Colors.pink[300]!},
    {'name': 'Massage', 'icon': Icons.accessibility, 'color': Colors.pink[600]!},
    {'name': 'Dental Care', 'icon': Icons.medical_services, 'color': Colors.blue[500]!},
    {'name': 'Vision Care', 'icon': Icons.visibility, 'color': Colors.blue[600]!},
    {'name': 'Mental Health', 'icon': Icons.psychology, 'color': Colors.purple[500]!},
    {'name': 'Therapy', 'icon': Icons.psychology, 'color': Colors.purple[600]!},
    {'name': 'Meditation', 'icon': Icons.self_improvement, 'color': Colors.green[500]!},

    // Business & Professional - Multiple icon options
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.indigo},
    {'name': 'Office Supplies', 'icon': Icons.work, 'color': Colors.indigo[500]!},
    {'name': 'Software', 'icon': Icons.computer, 'color': Colors.indigo[600]!},
    {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.indigo[700]!},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.indigo[800]!},
    {'name': 'Meals', 'icon': Icons.restaurant, 'color': Colors.indigo[400]!},
    {'name': 'Equipment', 'icon': Icons.build, 'color': Colors.indigo[900]!},
    {'name': 'Training', 'icon': Icons.school, 'color': Colors.indigo[300]!},
    {'name': 'Networking', 'icon': Icons.people, 'color': Colors.indigo[200]!},
    {'name': 'Subscriptions', 'icon': Icons.subscriptions, 'color': Colors.indigo[100]!},

    // Miscellaneous - Multiple icon options
    {'name': 'Miscellaneous', 'icon': Icons.more_horiz, 'color': Colors.grey},
    {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Colors.pink[300]!},
    {'name': 'Donations', 'icon': Icons.favorite, 'color': Colors.red[400]!},
    {'name': 'Taxes', 'icon': Icons.receipt, 'color': Colors.red[600]!},
    {'name': 'Fees', 'icon': Icons.account_balance, 'color': Colors.blue[600]!},
    {'name': 'Penalties', 'icon': Icons.warning, 'color': Colors.orange[600]!},
    {'name': 'Emergency', 'icon': Icons.emergency, 'color': Colors.red[700]!},
    {'name': 'Repairs', 'icon': Icons.build, 'color': Colors.grey[700]!},
    {'name': 'Replacement', 'icon': Icons.refresh, 'color': Colors.grey[800]!},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey[600]!},
  ];
  */

  @override
  void initState() {
    super.initState();
    
    // Initialize ValueNotifiers
    _budgetsNotifier = ValueNotifier<List<Budget>>([]);
    _overallBudgetsNotifier = ValueNotifier<List<OverallBudget>>([]);
    _transactionsNotifier = ValueNotifier<List<Transaction>>([]);
    _selectedMonthNotifier = ValueNotifier<DateTime>(DateTime.now());
    _totalBudgetNotifier = ValueNotifier<double>(0.0);
    _overallBudgetLimitNotifier = ValueNotifier<double>(0.0);
    _totalSpentNotifier = ValueNotifier<double>(0.0);
    _totalIncomeNotifier = ValueNotifier<double>(0.0);
    _salaryIncomeNotifier = ValueNotifier<double>(0.0);
    _effectiveIncomeNotifier = ValueNotifier<double>(0.0);
    _budgetAlertsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _budgetRecommendationsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    
    // Progressive loading states
    _isLoadingEssentialDataNotifier = ValueNotifier<bool>(true);
    _isLoadingBudgetAlertsNotifier = ValueNotifier<bool>(false);
    _isLoadingRecommendationsNotifier = ValueNotifier<bool>(false);
    _isLoadingInsightsNotifier = ValueNotifier<bool>(false);
    _isLoadingCategoriesNotifier = ValueNotifier<bool>(false);

    // Start progressive loading
    _loadEssentialData();
  }

  @override
  void dispose() {
    _budgetsNotifier.dispose();
    _overallBudgetsNotifier.dispose();
    _transactionsNotifier.dispose();
    _selectedMonthNotifier.dispose();
    _totalBudgetNotifier.dispose();
    _overallBudgetLimitNotifier.dispose();
    _totalSpentNotifier.dispose();
    _totalIncomeNotifier.dispose();
    _salaryIncomeNotifier.dispose();
    _effectiveIncomeNotifier.dispose();
    _budgetAlertsNotifier.dispose();
    _budgetRecommendationsNotifier.dispose();
    _isLoadingEssentialDataNotifier.dispose();
    _isLoadingBudgetAlertsNotifier.dispose();
    _isLoadingRecommendationsNotifier.dispose();
    _isLoadingInsightsNotifier.dispose();
    _isLoadingCategoriesNotifier.dispose();
    super.dispose();
  }

  // Phase 1: Load essential data first (top content)
  Future<void> _loadEssentialData() async {
    _isLoadingEssentialDataNotifier.value = true;

    try {
      // Load core budget data first
      final budgets = await DataService.getBudgets();
      final overallBudgets = await DataService.getOverallBudgets();
      final transactions = await DataService.getTransactions();

      if (mounted) {
        _budgetsNotifier.value = budgets;
        _overallBudgetsNotifier.value = overallBudgets;
        _transactionsNotifier.value = transactions;
        _calculateTotals();
        
        // Start loading other data progressively
        _loadBudgetAlertsInBackground();
        _loadRecommendationsInBackground();
        _loadInsightsInBackground();
        _loadCategoriesInBackground();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading essential budget data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoadingEssentialDataNotifier.value = false;
    }
  }

  // Phase 2: Load budget alerts in background
  void _loadBudgetAlertsInBackground() {
    _isLoadingBudgetAlertsNotifier.value = true;
    
    Future.microtask(() async {
      try {
        final alerts = await BudgetService.getBudgetAlerts();
        if (mounted) {
          _budgetAlertsNotifier.value = alerts;
        }
      } catch (e) {
        // Error logged
      } finally {
        if (mounted) {
          _isLoadingBudgetAlertsNotifier.value = false;
        }
      }
    });
  }

  // Phase 3: Load recommendations in background
  void _loadRecommendationsInBackground() {
    _isLoadingRecommendationsNotifier.value = true;
    
    Future.microtask(() async {
      try {
        final recommendations = await BudgetService.getBudgetRecommendations();
        if (mounted) {
          _budgetRecommendationsNotifier.value = recommendations;
        }
      } catch (e) {
        // Error logged
      } finally {
        if (mounted) {
          _isLoadingRecommendationsNotifier.value = false;
        }
      }
    });
  }

  // Phase 4: Load insights in background
  void _loadInsightsInBackground() {
    _isLoadingInsightsNotifier.value = true;
    
    Future.microtask(() async {
      try {
        // Simulate loading insights (this would be your actual insights logic)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _isLoadingInsightsNotifier.value = false;
        }
      } catch (e) {
        if (mounted) {
          _isLoadingInsightsNotifier.value = false;
        }
      }
    });
  }

  // Phase 5: Load categories in background
  void _loadCategoriesInBackground() {
    _isLoadingCategoriesNotifier.value = true;
    
    Future.microtask(() async {
      try {
        // Simulate loading categories (this would be your actual categories logic)
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _isLoadingCategoriesNotifier.value = false;
        }
      } catch (e) {
        if (mounted) {
          _isLoadingCategoriesNotifier.value = false;
        }
      }
    });
  }

  void _calculateTotals() {
    // Calculate budget and spent for selected month
    final monthBudgets = _budgetsNotifier.value
        .where(
          (budget) =>
              budget.startDate.year == _selectedMonthNotifier.value.year &&
              budget.startDate.month == _selectedMonthNotifier.value.month,
        )
        .toList();

    final totalBudget = monthBudgets.fold(
      0.0,
      (sum, budget) => sum + budget.limit,
    );

    // Get overall budget for the month
    final monthOverallBudgets = _overallBudgetsNotifier.value
        .where(
          (budget) =>
              budget.startDate.year == _selectedMonthNotifier.value.year &&
              budget.startDate.month == _selectedMonthNotifier.value.month &&
              budget.isActive,
        )
        .toList();

    double overallBudgetLimit = 0.0;
    if (monthOverallBudgets.isNotEmpty) {
      overallBudgetLimit = monthOverallBudgets.first.limit;
    }

    final monthTransactions = _transactionsNotifier.value
        .where(
          (transaction) =>
              transaction.date.year == _selectedMonthNotifier.value.year &&
              transaction.date.month == _selectedMonthNotifier.value.month,
        )
        .toList();

    final monthExpenses = monthTransactions
        .where((transaction) => transaction.type == 'expense')
        .toList();

    final monthIncome = monthTransactions
        .where((transaction) => transaction.type == 'income')
        .toList();

    final totalSpent = monthExpenses.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );

    // Calculate income
    double totalIncome = 0.0;
    double salaryIncome = 0.0;

    for (final transaction in monthIncome) {
      totalIncome += transaction.amount;
      if (transaction.category.toLowerCase().contains('salary')) {
        salaryIncome += transaction.amount;
      }
    }

    // Calculate effective income (income - expenses)
    final effectiveIncome = totalIncome - totalSpent;

    // Update notifiers
    _totalBudgetNotifier.value = totalBudget;
    _overallBudgetLimitNotifier.value = overallBudgetLimit;
    _totalSpentNotifier.value = totalSpent;
    _totalIncomeNotifier.value = totalIncome;
    _salaryIncomeNotifier.value = salaryIncome;
    _effectiveIncomeNotifier.value = effectiveIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEssentialData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget Overview Section - Loads first
                _buildBudgetOverviewSection(),
                const SizedBox(height: 24),

                // Budget Summary Section - Loads first
                _buildBudgetSummarySection(),
                const SizedBox(height: 24),

                // Budget Alerts Section - Loads progressively
                _buildBudgetAlertsSection(),
                const SizedBox(height: 24),

                // Budget Recommendations Section - Loads progressively
                _buildBudgetRecommendationsSection(),
                const SizedBox(height: 24),

                // Budget Insights Section - Loads progressively
                _buildBudgetInsightsSection(),
                const SizedBox(height: 24),

                // Categories with Budgets Section - Loads last
                _buildCategoriesWithBudgetsSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetOverviewSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingEssentialDataNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Overview', height: 120);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _selectedMonthNotifier.value = DateTime(
                          _selectedMonthNotifier.value.year,
                          _selectedMonthNotifier.value.month - 1,
                        );
                        _calculateTotals();
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    GestureDetector(
                      onTap: _showMonthPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ValueListenableBuilder<DateTime>(
                          valueListenable: _selectedMonthNotifier,
                          builder: (context, selectedMonth, child) {
                            return Text(
                              DateFormat('MMMM yyyy').format(selectedMonth),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _selectedMonthNotifier.value = DateTime(
                          _selectedMonthNotifier.value.year,
                          _selectedMonthNotifier.value.month + 1,
                        );
                        _calculateTotals();
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOverviewCards(),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCards() {
    return ValueListenableBuilder<double>(
      valueListenable: _totalBudgetNotifier,
      builder: (context, totalBudget, child) {
        return Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Budget',
                totalBudget.toStringAsFixed(2),
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Total Spent',
                _totalSpentNotifier.value.toStringAsFixed(2),
                Icons.shopping_cart,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Remaining',
                (totalBudget - _totalSpentNotifier.value).toStringAsFixed(2),
                Icons.savings,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummarySection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingEssentialDataNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Summary', height: 200);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryCards(),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Overall Budget',
                _overallBudgetLimitNotifier.value.toStringAsFixed(2),
                Icons.pie_chart,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Income',
                _totalIncomeNotifier.value.toStringAsFixed(2),
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Salary Income',
                _salaryIncomeNotifier.value.toStringAsFixed(2),
                Icons.work,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Effective Income',
                _effectiveIncomeNotifier.value.toStringAsFixed(2),
                Icons.account_balance,
                _effectiveIncomeNotifier.value >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAlertsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingBudgetAlertsNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Alerts', height: 150);
        }

        if (_budgetAlertsNotifier.value.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Build your budget alerts UI here
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_budgetAlertsNotifier.value.length} budget alert(s)',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetRecommendationsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingRecommendationsNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Recommendations', height: 150);
        }

        if (_budgetRecommendationsNotifier.value.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Build your budget recommendations UI here
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_budgetRecommendationsNotifier.value.length} recommendation(s)',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetInsightsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingInsightsNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Insights', height: 200);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Build your budget insights UI here
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Budget performance insights and trends',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesWithBudgetsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingCategoriesNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return _buildLoadingPlaceholder('Budget Categories', height: 300);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Build your budget categories UI here
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.purple, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Category-wise budget breakdown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder(String title, {required double height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonthNotifier.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonthNotifier.value) {
      _selectedMonthNotifier.value = DateTime(picked.year, picked.month);
      _calculateTotals();
    }
  }

  void _showAddCategoryDialog() {
    // Implement your add category dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Budget Category'),
          content: const Text('This feature is coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
