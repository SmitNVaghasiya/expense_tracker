import 'package:flutter/material.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/overall_budget.dart';
import 'package:spendwise/services/data_service.dart';
import 'package:spendwise/services/category_service.dart';
import 'package:spendwise/services/warning_preferences_service.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;
import 'package:spendwise/models/category.dart';
import 'package:uuid/uuid.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/budget_service.dart';
import 'package:spendwise/screens/financial/base_financial_screen.dart';
import 'package:spendwise/core/performance_mixins.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends BaseFinancialScreen {
  const BudgetsScreen({super.key})
    : super(
        screenTitle: 'Budgets',
        screenIcon: Icons.pie_chart,
        primaryColor: Colors.blue,
        floatingActionButtonTooltip: 'Add Category',
      );

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen>
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
  late final ValueNotifier<List<Map<String, dynamic>>>
  _budgetRecommendationsNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;

  // Predefined categories with expanded icon options
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
    {'name': 'Utilities', 'icon': Icons.electric_bolt, 'color': Colors.amber},
    {
      'name': 'Electricity',
      'icon': Icons.electric_bolt,
      'color': Colors.amber[600]!,
    },
    {'name': 'Water', 'icon': Icons.water_drop, 'color': Colors.blue[400]!},
    {
      'name': 'Gas',
      'icon': Icons.local_fire_department,
      'color': Colors.orange[400]!,
    },
    {'name': 'Internet', 'icon': Icons.wifi, 'color': Colors.blue[500]!},
    {'name': 'Phone Bill', 'icon': Icons.phone, 'color': Colors.blue[600]!},
    {'name': 'Maintenance', 'icon': Icons.build, 'color': Colors.grey[600]!},
    {
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.grey[500]!,
    },
    {'name': 'Furniture', 'icon': Icons.chair, 'color': Colors.brown[600]!},
    {'name': 'Decor', 'icon': Icons.image, 'color': Colors.brown[500]!},

    // Personal Care - Multiple icon options
    {'name': 'Hair Cut', 'icon': Icons.content_cut, 'color': Colors.pink},
    {'name': 'Salon', 'icon': Icons.face, 'color': Colors.pink[400]!},
    {'name': 'Barber', 'icon': Icons.content_cut, 'color': Colors.pink[500]!},
    {'name': 'Nail Care', 'icon': Icons.brush, 'color': Colors.pink[300]!},
    {'name': 'Skincare', 'icon': Icons.face, 'color': Colors.pink[400]!},

    // Business & Professional - Multiple icon options
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.grey[700]!},
    {'name': 'Office Supplies', 'icon': Icons.work, 'color': Colors.grey[600]!},
    {
      'name': 'Professional Development',
      'icon': Icons.trending_up,
      'color': Colors.grey[800]!,
    },
    {'name': 'Networking', 'icon': Icons.people, 'color': Colors.grey[500]!},
    {'name': 'Conferences', 'icon': Icons.event, 'color': Colors.grey[600]!},

    // Financial Services - Multiple icon options
    {
      'name': 'Banking',
      'icon': Icons.account_balance,
      'color': Colors.green[700]!,
    },
    {'name': 'Insurance', 'icon': Icons.security, 'color': Colors.green[600]!},
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Colors.green[500]!,
    },
    {'name': 'Taxes', 'icon': Icons.receipt_long, 'color': Colors.red[600]!},
    {'name': 'Fees', 'icon': Icons.payment, 'color': Colors.red[500]!},

    // Social & Relationships - Multiple icon options
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.green},
    {'name': 'Dating', 'icon': Icons.favorite, 'color': Colors.red[400]!},
    {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Colors.pink[400]!},
    {
      'name': 'Charity',
      'icon': Icons.volunteer_activism,
      'color': Colors.green[500]!,
    },
    {
      'name': 'Donations',
      'icon': Icons.favorite_border,
      'color': Colors.green[400]!,
    },

    // Technology & Digital - Multiple icon options
    {'name': 'Software', 'icon': Icons.computer, 'color': Colors.blue[600]!},
    {'name': 'Apps', 'icon': Icons.phone_android, 'color': Colors.blue[500]!},
    {'name': 'Streaming', 'icon': Icons.play_circle, 'color': Colors.red[500]!},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.purple[600]!},
    {
      'name': 'Digital Services',
      'icon': Icons.cloud,
      'color': Colors.blue[400]!,
    },

    // Pet Care - Multiple icon options
    {'name': 'Pet Food', 'icon': Icons.pets, 'color': Colors.brown[500]!},
    {
      'name': 'Veterinary',
      'icon': Icons.medical_services,
      'color': Colors.orange[600]!,
    },
    {'name': 'Pet Supplies', 'icon': Icons.pets, 'color': Colors.brown[600]!},
    {
      'name': 'Pet Grooming',
      'icon': Icons.content_cut,
      'color': Colors.brown[400]!,
    },

    // Miscellaneous
    {'name': 'Other', 'icon': Icons.circle, 'color': Colors.blue},
    {'name': 'Emergency', 'icon': Icons.emergency, 'color': Colors.red[800]!},
    {'name': 'Legal', 'icon': Icons.gavel, 'color': Colors.grey[800]!},
    {'name': 'Repairs', 'icon': Icons.handyman, 'color': Colors.grey[600]!},
    {'name': 'Storage', 'icon': Icons.inventory, 'color': Colors.grey[500]!},
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
  }

  void _initializeNotifiers() {
    _budgetsNotifier = getNotifier('budgets', []);
    _overallBudgetsNotifier = getNotifier('overallBudgets', []);
    _transactionsNotifier = getNotifier('transactions', []);
    _selectedMonthNotifier = getNotifier('selectedMonth', DateTime.now());
    _totalBudgetNotifier = getNotifier('totalBudget', 0.0);
    _overallBudgetLimitNotifier = getNotifier('overallBudgetLimit', 0.0);
    _totalSpentNotifier = getNotifier('totalSpent', 0.0);
    _totalIncomeNotifier = getNotifier('totalIncome', 0.0);
    _salaryIncomeNotifier = getNotifier('salaryIncome', 0.0);
    _effectiveIncomeNotifier = getNotifier('effectiveIncome', 0.0);
    _budgetAlertsNotifier = getNotifier('budgetAlerts', []);
    _budgetRecommendationsNotifier = getNotifier('budgetRecommendations', []);
    _isLoadingNotifier = getNotifier('isLoading', false);
  }

  Future<void> _loadData() async {
    _isLoadingNotifier.value = true;

    if (!mounted) return;

    try {
      final budgets = await DataService.getBudgets();
      final overallBudgets = await DataService.getOverallBudgets();
      final transactions = await DataService.getTransactions();

      if (mounted) {
        setState(() {
          _budgetsNotifier.value = budgets;
          _overallBudgetsNotifier.value = overallBudgets;
          _transactionsNotifier.value = transactions;
          _calculateTotals();
        });
      }

      // Load budget alerts and recommendations
      if (mounted) {
        final alerts = await BudgetService.getBudgetAlerts();
        final recommendations = await BudgetService.getBudgetRecommendations();

        if (mounted) {
          setState(() {
            _budgetAlertsNotifier.value = alerts;
            _budgetRecommendationsNotifier.value = recommendations;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading budgets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoadingNotifier.value = false;
    }
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
      if (transaction.category.toLowerCase() == 'salary') {
        salaryIncome += transaction.amount;
      }
    }

    // Use salary income if available, otherwise use total income
    final effectiveIncome = salaryIncome > 0 ? salaryIncome : totalIncome;

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
        onRefresh: _loadData,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget Overview Section
                    _buildBudgetOverviewSection(),
                    const SizedBox(height: 24),

                    // Budget Summary Section
                    _buildBudgetSummarySection(),
                    const SizedBox(height: 24),

                    // Budget Alerts Section
                    if (_budgetAlertsNotifier.value.isNotEmpty) ...[
                      _buildBudgetAlertsSection(),
                      const SizedBox(height: 24),
                    ],

                    // Budget Recommendations Section
                    if (_budgetRecommendationsNotifier.value.isNotEmpty) ...[
                      _buildBudgetRecommendationsSection(),
                      const SizedBox(height: 24),
                    ],

                    // Budget Insights Section
                    _buildBudgetInsightsSection(),
                    const SizedBox(height: 24),

                    // Categories with Budgets Section
                    _buildCategoriesWithBudgetsSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetOverviewSection() {
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
                    setState(() {
                      _selectedMonthNotifier.value = DateTime(
                        _selectedMonthNotifier.value.year,
                        _selectedMonthNotifier.value.month - 1,
                      );
                    });
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
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'MMMM yyyy',
                          ).format(_selectedMonthNotifier.value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonthNotifier.value = DateTime(
                        _selectedMonthNotifier.value.year,
                        _selectedMonthNotifier.value.month + 1,
                      );
                    });
                    _calculateTotals();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: 8),
                // Today button
                if (_selectedMonthNotifier.value.year != DateTime.now().year ||
                    _selectedMonthNotifier.value.month != DateTime.now().month)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedMonthNotifier.value = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            1,
                          );
                        });
                        _calculateTotals();
                      },
                      icon: Icon(
                        Icons.today,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      label: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildBudgetMetricCard(
                'CATEGORY BUDGETS',
                _totalBudgetNotifier.value,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetMetricCard(
                'OVERALL BUDGET',
                _overallBudgetLimitNotifier.value,
                Colors.green,
                onTap: _overallBudgetLimitNotifier.value > 0
                    ? _showEditOverallBudgetDialog
                    : _showSetOverallBudgetDialog,
                showSetButton: _overallBudgetLimitNotifier.value == 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetMetricCard(
                'TOTAL SPENT',
                _totalSpentNotifier.value,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBudgetMetricCard(
                'MONTHLY INCOME',
                _effectiveIncomeNotifier.value,
                Colors.green,
                showIncomeSource: true,
                incomeSource: _salaryIncomeNotifier.value > 0
                    ? 'Salary'
                    : 'All Income',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetMetricCard(
                'REMAINING',
                _effectiveIncomeNotifier.value - _totalSpentNotifier.value,
                _effectiveIncomeNotifier.value - _totalSpentNotifier.value < 0
                    ? Colors.red
                    : Colors.green,
                showRemainingStatus: true,
                isOverIncome:
                    _totalSpentNotifier.value > _effectiveIncomeNotifier.value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonthNotifier.value,
      firstDate: DateTime(1800),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newMonth = DateTime(picked.year, picked.month, 1);
      if (newMonth != _selectedMonthNotifier.value) {
        setState(() {
          _selectedMonthNotifier.value = newMonth;
        });
        _calculateTotals();
      }
    }
  }

  Widget _buildBudgetMetricCard(
    String title,
    double amount,
    Color color, {
    Function()? onTap,
    bool showSetButton = false,
    bool showIncomeSource = false,
    String? incomeSource,
    bool showRemainingStatus = false,
    bool isOverIncome = false,
  }) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(symbol: '₹').format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (showIncomeSource && incomeSource != null) ...[
            const SizedBox(height: 4),
            Text(
              incomeSource,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (showRemainingStatus) ...[
            const SizedBox(height: 4),
            Text(
              isOverIncome ? 'Over Income' : 'Within Income',
              style: TextStyle(
                fontSize: 10,
                color: isOverIncome ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (showSetButton)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('SET BUDGET'),
            ),
        ],
      ),
    );
  }

  void _showSetOverallBudgetDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Overall Budget for ${DateFormat('MMMM yyyy').format(_selectedMonthNotifier.value)}',
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Overall Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final overallBudget = OverallBudget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  limit: double.tryParse(amountController.text) ?? 0,
                  startDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month,
                    1,
                  ),
                  endDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month + 1,
                    0,
                  ),
                  isActive: true,
                );
                DataService.addOverallBudget(overallBudget);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Set Overall Budget'),
          ),
        ],
      ),
    );
  }

  void _showEditOverallBudgetDialog() {
    final amountController = TextEditingController(
      text: _overallBudgetLimitNotifier.value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Overall Budget for ${DateFormat('MMMM yyyy').format(_selectedMonthNotifier.value)}',
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Overall Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final updatedOverallBudget = OverallBudget(
                  id: _overallBudgetsNotifier.value
                      .firstWhere(
                        (b) =>
                            b.startDate.year ==
                                _selectedMonthNotifier.value.year &&
                            b.startDate.month ==
                                _selectedMonthNotifier.value.month &&
                            b.isActive,
                        orElse: () => OverallBudget(
                          id: '',
                          limit: 0,
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          isActive: true,
                        ),
                      )
                      .id,
                  limit: double.tryParse(amountController.text) ?? 0,
                  startDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month,
                    1,
                  ),
                  endDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month + 1,
                    0,
                  ),
                  isActive: true,
                );
                DataService.updateOverallBudget(updatedOverallBudget);
                Navigator.pop(context);
                setState(() {});
                _loadData();
              }
            },
            child: const Text('Update Overall Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBudgetSummaryCard(
                'Overall Budget',
                _overallBudgetLimitNotifier.value,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBudgetSummaryCard(
                'Total Spent',
                _totalSpentNotifier.value,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSummaryCard(String title, double amount, Color color) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(symbol: '₹').format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInsightsSection() {
    final effectiveTotalBudget = _overallBudgetLimitNotifier.value > 0
        ? _overallBudgetLimitNotifier.value
        : _totalBudgetNotifier.value;

    final budgetUtilization = effectiveTotalBudget > 0
        ? (_totalSpentNotifier.value / effectiveTotalBudget * 100).clamp(0, 100)
        : 0.0;

    final remainingBudget = effectiveTotalBudget - _totalSpentNotifier.value;
    final isOverBudget = _totalSpentNotifier.value > effectiveTotalBudget;

    final remainingIncome =
        _effectiveIncomeNotifier.value - _totalSpentNotifier.value;
    final isOverIncome =
        _totalSpentNotifier.value > _effectiveIncomeNotifier.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Budget Utilization',
                '${budgetUtilization.toStringAsFixed(1)}%',
                budgetUtilization > 90 ? Colors.red : Colors.green,
                Icons.pie_chart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                'Remaining Budget',
                NumberFormat.currency(symbol: '₹').format(remainingBudget),
                remainingBudget < 0 ? Colors.red : Colors.green,
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Monthly Income',
                NumberFormat.currency(
                  symbol: '₹',
                ).format(_effectiveIncomeNotifier.value),
                Colors.green,
                Icons.attach_money,
                subtitle: _salaryIncomeNotifier.value > 0
                    ? 'Salary'
                    : 'All Income',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                'Income Status',
                isOverIncome ? 'Over Income' : 'Within Income',
                isOverIncome ? Colors.red : Colors.green,
                isOverIncome ? Icons.warning : Icons.check_circle,
                subtitle: isOverIncome
                    ? 'Deficit: ${NumberFormat.currency(symbol: '₹').format(remainingIncome.abs())}'
                    : 'Remaining: ${NumberFormat.currency(symbol: '₹').format(remainingIncome)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOverBudget
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverBudget ? Colors.red : Colors.green,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOverBudget ? Icons.warning : Icons.check_circle,
                color: isOverBudget ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverBudget
                          ? 'You are over budget by ${NumberFormat.currency(symbol: '₹').format(remainingBudget.abs())}'
                          : 'You are within budget with ${NumberFormat.currency(symbol: '₹').format(remainingBudget)} remaining',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : Colors.green,
                      ),
                    ),
                    if (isOverIncome) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⚠️ Your expenses exceed your income by ${NumberFormat.currency(symbol: '₹').format(remainingIncome.abs())}. You might be using your savings.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    Color color,
    IconData icon, {
    String? subtitle,
  }) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesWithBudgetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income Categories
        Text(
          'Income Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        ..._incomeCategories.map(
          (category) => _buildCategoryWithBudgetCard(category, 'income'),
        ),

        const SizedBox(height: 16),

        // Expense Categories
        Text(
          'Expense Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        ..._expenseCategories.map(
          (category) => _buildCategoryWithBudgetCard(category, 'expense'),
        ),
      ],
    );
  }

  Widget _buildCategoryWithBudgetCard(
    Map<String, dynamic> category,
    String type,
  ) {
    final categoryName = category['name'] as String;
    final icon = category['icon'] as IconData;
    final color = category['color'] as Color;

    // Find budget for this category and month
    final budget = _budgetsNotifier.value.firstWhere(
      (b) =>
          b.category == categoryName &&
          b.startDate.year == _selectedMonthNotifier.value.year &&
          b.startDate.month == _selectedMonthNotifier.value.month,
      orElse: () => Budget(
        id: '',
        name: '',
        category: categoryName,
        limit: 0,
        startDate: _selectedMonthNotifier.value,
        endDate: _selectedMonthNotifier.value,
      ),
    );

    // Calculate spent amount for this category
    final spent = _transactionsNotifier.value
        .where(
          (t) =>
              t.type == type &&
              t.category == categoryName &&
              t.date.year == _selectedMonthNotifier.value.year &&
              t.date.month == _selectedMonthNotifier.value.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);

    // Only show budget information if there's actually a budget set
    final hasBudget = budget.limit > 0;
    final percentage = hasBudget ? (spent / budget.limit) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(categoryName),
        subtitle: hasBudget
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${NumberFormat.currency(symbol: '₹').format(spent)} / ${NumberFormat.currency(symbol: '₹').format(budget.limit)}',
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 90 ? Colors.red : color,
                    ),
                  ),
                ],
              )
            : const Text('No budget set'),
        trailing: hasBudget
            ? Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percentage > 90 ? Colors.red : color,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextButton(
                onPressed: () => _showSetBudgetDialog(categoryName),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('SET BUDGET'),
              ),
        onTap: hasBudget ? () => _showEditBudgetDialog(budget) : null,
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = 'expense';
    String? selectedIcon;
    String selectedColor = '#2196F3';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Groceries, Travel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Category Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => common_widgets.IconPicker(
                            selectedIcon: selectedIcon,
                            onIconSelected: (icon) {
                              setState(() {
                                selectedIcon = icon;
                              });
                            },
                            title: 'Select Category Icon',
                          ),
                        );
                      },
                      icon: Icon(
                        selectedIcon != null
                            ? CategoryService.getIconData(selectedIcon!)
                            : Icons.category,
                      ),
                      label: Text(selectedIcon ?? 'Select Icon'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildColorOption('#FF0000', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#FF9800', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#FFEB3B', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#4CAF50', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#2196F3', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#9C27B0', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#E91E63', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                  _buildColorOption('#607D8B', selectedColor, (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedIcon != null) {
                  final newCategory = Category(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    type: selectedType,
                    icon: selectedIcon!,
                    color: selectedColor,
                    createdAt: DateTime.now(),
                  );

                  final success = await CategoryService.addCategory(
                    newCategory,
                  );
                  if (success && mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    // Refresh the screen to show new category
                    _loadData();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    String colorHex,
    String selectedColor,
    Function(String) onTap,
  ) {
    final color = CategoryService.getColorFromHex(colorHex);
    final isSelected = selectedColor == colorHex;

    return GestureDetector(
      onTap: () => onTap(colorHex),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  void _showSetBudgetDialog(String categoryName) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for $categoryName'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final budget = Budget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '$categoryName Budget',
                  category: categoryName,
                  limit: double.tryParse(amountController.text) ?? 0,
                  startDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month,
                    1,
                  ),
                  endDate: DateTime(
                    _selectedMonthNotifier.value.year,
                    _selectedMonthNotifier.value.month + 1,
                    0,
                  ),
                );
                DataService.addBudget(budget);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    final amountController = TextEditingController(
      text: budget.limit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Budget for ${budget.category}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final updatedBudget = budget.copyWith(
                  limit: double.tryParse(amountController.text) ?? 0,
                );
                DataService.updateBudget(updatedBudget);
                Navigator.pop(context);
                setState(() {});
                _loadData();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<int>(
              future: WarningPreferencesService.getHiddenWarningsCount(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return TextButton.icon(
                    onPressed: _showHiddenWarningsDialog,
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: Text('${snapshot.data} Hidden'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getFilteredAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final alerts = snapshot.data ?? [];

            if (alerts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text(
                      'All good! No budget alerts for this month.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: alerts.map((alert) => _buildAlertCard(alert)).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getFilteredAlerts() async {
    final alerts = await BudgetService.getBudgetAlerts();
    final filteredAlerts = <Map<String, dynamic>>[];

    for (final alert in alerts) {
      final isHidden = await WarningPreferencesService.isWarningHidden(
        alert['type'],
        alert['category'],
      );

      if (!isHidden) {
        filteredAlerts.add(alert);
      }
    }

    return filteredAlerts;
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final priority = alert['priority'] ?? 'medium';
    final severity = alert['severity'] ?? 'medium';

    Color priorityColor;
    IconData priorityIcon;

    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.info;
        break;
      case 'low':
        priorityColor = Colors.blue;
        priorityIcon = Icons.lightbulb;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(priorityIcon, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                    fontSize: 14,
                  ),
                ),
              ),
              if (alert['canHide'] == true)
                IconButton(
                  onPressed: () => _hideWarning(alert),
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  color: priorityColor,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(alert['message'], style: const TextStyle(fontSize: 12)),
          if (alert['priority'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (alert['resetMonthly'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'RESETS MONTHLY',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _hideWarning(Map<String, dynamic> alert) async {
    await WarningPreferencesService.hideWarning(
      alert['type'],
      alert['category'],
    );

    // Refresh the alerts
    setState(() {});
  }

  void _showHiddenWarningsDialog() async {
    final hiddenWarnings = await WarningPreferencesService.getHiddenWarnings();
    final stats = await WarningPreferencesService.getWarningStatistics();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hidden Warnings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Hidden: ${stats['totalHidden']}'),
            Text('Monthly (Auto-reset): ${stats['monthlyHidden']}'),
            Text('Permanent: ${stats['permanentHidden']}'),
            const SizedBox(height: 16),
            if (hiddenWarnings.isNotEmpty) ...[
              const Text(
                'Hidden Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...hiddenWarnings.values.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${warning['type']}${warning['category'] != null ? ' (${warning['category']})' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await WarningPreferencesService.clearAllHiddenWarnings();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Recommendations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._budgetRecommendationsNotifier.value.map(
          (recommendation) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation['message'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (recommendation['suggestedAmount'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Suggested Amount:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: '₹',
                        ).format(recommendation['suggestedAmount']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
                if (recommendation['type'] == 'set_overall_budget') ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSetOverallBudgetDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Set Overall Budget'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
