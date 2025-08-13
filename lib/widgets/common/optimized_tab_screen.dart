import 'package:flutter/material.dart';

/// Optimized tab screen that uses IndexedStack for better performance
/// and implements lazy loading for tab content
class OptimizedTabScreen extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final int initialIndex;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final double indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;
  final bool automaticKeepAlive;

  const OptimizedTabScreen({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.initialIndex = 0,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicatorWeight = 2.0,
    this.labelPadding,
    this.automaticKeepAlive = true,
  });

  @override
  State<OptimizedTabScreen> createState() => _OptimizedTabScreenState();
}

class _OptimizedTabScreenState extends State<OptimizedTabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs,
            isScrollable: widget.isScrollable,
            indicatorColor: widget.indicatorColor,
            labelColor: widget.labelColor,
            unselectedLabelColor: widget.unselectedLabelColor,
            labelStyle: widget.labelStyle,
            unselectedLabelStyle: widget.unselectedLabelStyle,
            indicatorWeight: widget.indicatorWeight,
            labelPadding: widget.labelPadding,
          ),
        ),

        // Tab Content with IndexedStack for better performance
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: widget.tabViews.map((tabView) {
              if (widget.automaticKeepAlive) {
                return _OptimizedTabContent(child: tabView);
              }
              return tabView;
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Tab content wrapper that implements AutomaticKeepAliveClientMixin
class _OptimizedTabContent extends StatefulWidget {
  final Widget child;

  const _OptimizedTabContent({required this.child});

  @override
  State<_OptimizedTabContent> createState() => _OptimizedTabContentState();
}

class _OptimizedTabContentState extends State<_OptimizedTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.child;
  }
}

/// Optimized tab view that uses IndexedStack internally
class OptimizedTabView extends StatelessWidget {
  final List<Widget> children;
  final int initialIndex;
  final bool automaticKeepAlive;

  const OptimizedTabView({
    super.key,
    required this.children,
    this.initialIndex = 0,
    this.automaticKeepAlive = true,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: initialIndex,
      children: children.map((child) {
        if (automaticKeepAlive) {
          return _OptimizedTabContent(child: child);
        }
        return child;
      }).toList(),
    );
  }
}

/// Optimized tab with custom styling
class OptimizedTab extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final bool useRepaintBoundary;

  const OptimizedTab({
    super.key,
    required this.child,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.padding,
    this.useRepaintBoundary = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget tab = Tab(
      key: key,
      icon: icon != null ? Icon(icon, size: iconSize, color: iconColor) : null,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );

    if (useRepaintBoundary) {
      tab = RepaintBoundary(child: tab);
    }

    return tab;
  }
}

/// Optimized tab content with performance optimizations
class OptimizedTabContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useRepaintBoundary;
  final bool useRepaintBoundaryForChild;

  const OptimizedTabContent({
    super.key,
    required this.child,
    this.padding,
    this.useRepaintBoundary = true,
    this.useRepaintBoundaryForChild = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      key: key,
      padding: padding,
      child: useRepaintBoundaryForChild ? RepaintBoundary(child: child) : child,
    );

    if (useRepaintBoundary) {
      content = RepaintBoundary(child: content);
    }

    return content;
  }
}

/// Mixin for tab performance optimization
mixin TabPerformanceMixin<T extends StatefulWidget> on State<T> {
  final Map<int, bool> _tabVisibility = {};
  final Map<int, Widget> _tabCache = {};

  bool isTabVisible(int index) => _tabVisibility[index] ?? false;

  void setTabVisibility(int index, bool visible) {
    _tabVisibility[index] = visible;
  }

  Widget getCachedTab(int index, Widget Function() builder) {
    if (!_tabCache.containsKey(index)) {
      _tabCache[index] = builder();
    }
    return _tabCache[index]!;
  }

  void clearTabCache(int index) {
    _tabCache.remove(index);
  }

  void clearAllTabCache() {
    _tabCache.clear();
  }

  @override
  void dispose() {
    _tabCache.clear();
    super.dispose();
  }
}
