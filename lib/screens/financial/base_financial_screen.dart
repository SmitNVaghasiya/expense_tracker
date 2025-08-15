import 'package:flutter/material.dart';
import 'package:spendwise/core/performance_mixins.dart';
import 'package:spendwise/widgets/common/index.dart' as common_widgets;

/// Base class for financial screens (Accounts, Budgets, Loans)
abstract class BaseFinancialScreen extends StatefulWidget {
  final String screenTitle;
  final IconData screenIcon;
  final Color primaryColor;
  final bool showFloatingActionButton;
  final String? floatingActionButtonTooltip;

  const BaseFinancialScreen({
    super.key,
    required this.screenTitle,
    required this.screenIcon,
    required this.primaryColor,
    this.showFloatingActionButton = true,
    this.floatingActionButtonTooltip,
  });

  @override
  State<BaseFinancialScreen> createState() => _BaseFinancialScreenState();
}

class _BaseFinancialScreenState extends State<BaseFinancialScreen>
    with ValueNotifierMixin, EfficientListMixin, ScrollPerformanceMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
  }

  void _initializeNotifiers() {
    // Override in subclasses
  }

  Future<void> _loadData() async {
    // Override in subclasses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: widget.showFloatingActionButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.screenTitle),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    // Override in subclasses to add custom actions
    return [];
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ValueListenableBuilder<bool>(
        valueListenable: getNotifier('isLoading', false),
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    // Override in subclasses
    return const Center(child: Text('Content not implemented'));
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _onFloatingActionButtonPressed,
      backgroundColor: widget.primaryColor,
      foregroundColor: Colors.white,
      tooltip:
          widget.floatingActionButtonTooltip ??
          'Add ${widget.screenTitle.toLowerCase()}',
      child: Icon(widget.screenIcon),
    );
  }

  void _onFloatingActionButtonPressed() {
    // Override in subclasses
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Base class for list-based financial screens
abstract class BaseListFinancialScreen extends BaseFinancialScreen {
  const BaseListFinancialScreen({
    super.key,
    required super.screenTitle,
    required super.screenIcon,
    required super.primaryColor,
    super.showFloatingActionButton,
    super.floatingActionButtonTooltip,
  });

  @override
  State<BaseListFinancialScreen> createState() =>
      _BaseListFinancialScreenState();
}

class _BaseListFinancialScreenState extends State<BaseListFinancialScreen>
    with ValueNotifierMixin, EfficientListMixin, ScrollPerformanceMixin {
  late final ValueNotifier<List<dynamic>> _itemsNotifier;
  late final ValueNotifier<List<dynamic>> _filteredItemsNotifier;
  late final ValueNotifier<String> _searchQueryNotifier;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _loadData();
  }

  void _initializeNotifiers() {
    _itemsNotifier = getNotifier('items', []);
    _filteredItemsNotifier = getNotifier('filteredItems', []);
    _searchQueryNotifier = getNotifier('searchQuery', '');
  }



  Future<void> _loadData() async {
    // Override in subclasses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.screenTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ValueListenableBuilder<List<dynamic>>(
          valueListenable: _filteredItemsNotifier,
          builder: (context, items, child) {
            if (items.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Summary section
                _buildSummarySection(),

                // List section
                Expanded(child: _buildListSection(items)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: widget.showFloatingActionButton
          ? FloatingActionButton(
              onPressed: _onFloatingActionButtonPressed,
              backgroundColor: widget.primaryColor,
              foregroundColor: Colors.white,
              tooltip:
                  widget.floatingActionButtonTooltip ??
                  'Add ${widget.screenTitle.toLowerCase()}',
              child: Icon(widget.screenIcon),
            )
          : null,
    );
  }

  Widget _buildSummarySection() {
    // Override in subclasses
    return const SizedBox.shrink();
  }

  Widget _buildListSection(List<dynamic> items) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItem(item, index);
      },
    );
  }

  Widget _buildListItem(dynamic item, int index) {
    // Override in subclasses
    return ListTile(
      title: Text(item.toString()),
      onTap: () => _onItemTap(item),
    );
  }

  Widget _buildEmptyState() {
    return common_widgets.EmptyStateWidget(
      icon: widget.screenIcon,
      title: 'No ${widget.screenTitle.toLowerCase()} yet',
      message:
          'Add your first ${widget.screenTitle.toLowerCase()} to start tracking',
    );
  }

  void _onItemTap(dynamic item) {
    // Override in subclasses
  }

  void _onFloatingActionButtonPressed() {
    // Override in subclasses
  }

  void _applySearch(String query) {
    _searchQueryNotifier.value = query;
    _filterItems();
  }

  void _filterItems() {
    if (_searchQueryNotifier.value.isEmpty) {
      _filteredItemsNotifier.value = _itemsNotifier.value;
    } else {
      final filtered = _itemsNotifier.value.where((item) {
        return _itemMatchesSearch(item, _searchQueryNotifier.value);
      }).toList();
      _filteredItemsNotifier.value = filtered;
    }
  }

  bool _itemMatchesSearch(dynamic item, String query) {
    // Override in subclasses for custom search logic
    return item.toString().toLowerCase().contains(query.toLowerCase());
  }



  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search ${widget.screenTitle}'),
        content: common_widgets.SearchBar(
          hintText: 'Search ${widget.screenTitle.toLowerCase()}',
          initialQuery: _searchQueryNotifier.value,
          onSearchChanged: _applySearch,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _searchQueryNotifier.value = '';
              _filterItems();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
