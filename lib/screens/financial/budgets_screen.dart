import 'package:flutter/material.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/transaction.dart';
import 'package:spendwise/services/data_service.dart';
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
  late final ValueNotifier<List<Transaction>> _transactionsNotifier;
  late final ValueNotifier<DateTime> _selectedMonthNotifier;
  late final ValueNotifier<double> _totalBudgetNotifier;
  late final ValueNotifier<double> _totalSpentNotifier;
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
    _transactionsNotifier = getNotifier('transactions', []);
    _selectedMonthNotifier = getNotifier('selectedMonth', DateTime.now());
    _totalBudgetNotifier = getNotifier('totalBudget', 0.0);
    _totalSpentNotifier = getNotifier('totalSpent', 0.0);
    _budgetAlertsNotifier = getNotifier('budgetAlerts', []);
    _budgetRecommendationsNotifier = getNotifier('budgetRecommendations', []);
    _isLoadingNotifier = getNotifier('isLoading', false);
  }

  @override
  Future<void> _loadData() async {
    _isLoadingNotifier.value = true;

    if (!mounted) return;

    try {
      final budgets = await DataService.getBudgets();
      final transactions = await DataService.getTransactions();

      if (mounted) {
        setState(() {
          _budgetsNotifier.value = budgets;
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

    final monthTransactions = _transactionsNotifier.value
        .where(
          (transaction) =>
              transaction.date.year == _selectedMonthNotifier.value.year &&
              transaction.date.month == _selectedMonthNotifier.value.month &&
              transaction.type == 'expense',
        )
        .toList();

    final totalSpent = monthTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );

    _totalBudgetNotifier.value = totalBudget;
    _totalSpentNotifier.value = totalSpent;
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                'TOTAL BUDGET',
                _totalBudgetNotifier.value,
                Colors.blue,
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
      ],
    );
  }

  Future<void> _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonthNotifier.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Widget _buildBudgetMetricCard(String title, double amount, Color color) {
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

  Widget _buildCategoriesWithBudgetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income Categories
        const Text(
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
        const Text(
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

    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(categoryName),
        subtitle: budget.limit > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${NumberFormat.currency(symbol: '₹').format(spent)} / ${NumberFormat.currency(symbol: '₹').format(budget.limit)}',
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 90 ? Colors.red : color,
                    ),
                  ),
                ],
              )
            : const Text('No budget set'),
        trailing: budget.limit > 0
            ? Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percentage > 90 ? Colors.red : color,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextButton(
                onPressed: () => _showSetBudgetDialog(categoryName),
                child: const Text('SET BUDGET'),
              ),
        onTap: budget.limit > 0 ? () => _showEditBudgetDialog(budget) : null,
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = 'expense';
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Groceries, Travel',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Category Type'),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
            const SizedBox(height: 16),
            const Text('Select Icon and Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildIconOption(
                  Icons.restaurant,
                  Colors.red,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.directions_car,
                  Colors.blue,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.shopping_bag,
                  Colors.purple,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.movie,
                  Colors.pink,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.medical_services,
                  Colors.orange,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.school,
                  Colors.indigo,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.home,
                  Colors.green,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
                _buildIconOption(
                  Icons.devices,
                  Colors.teal,
                  selectedIcon,
                  selectedColor,
                  (icon, color) {
                    selectedIcon = icon;
                    selectedColor = color;
                  },
                ),
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
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newCategory = {
                  'name': nameController.text,
                  'icon': selectedIcon,
                  'color': selectedColor,
                };

                if (selectedType == 'income') {
                  _incomeCategories.add(newCategory);
                } else {
                  _expenseCategories.add(newCategory);
                }

                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOption(
    IconData icon,
    Color color,
    IconData selectedIcon,
    Color selectedColor,
    Function(IconData, Color) onTap,
  ) {
    final isSelected = selectedIcon == icon && selectedColor == color;

    return GestureDetector(
      onTap: () => onTap(icon, color),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Icon(icon, color: color, size: 24),
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
        const Text(
          'Budget Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._budgetAlertsNotifier.value.map(
          (alert) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert['severity'] == 'high'
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: alert['severity'] == 'high' ? Colors.red : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  alert['severity'] == 'high' ? Icons.warning : Icons.info,
                  color: alert['severity'] == 'high'
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: alert['severity'] == 'high'
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                      Text(
                        alert['message'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.blue),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    recommendation['message'],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
