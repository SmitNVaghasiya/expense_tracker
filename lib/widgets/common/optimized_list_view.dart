import 'package:flutter/material.dart';

/// Optimized list view with performance improvements
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? separator;
  final int? itemCount;
  final bool useRepaintBoundary;
  final bool useConstConstructors;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.separator,
    this.itemCount,
    this.useRepaintBoundary = true,
    this.useConstConstructors = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveItemCount = itemCount ?? items.length;

    if (separator != null) {
      return ListView.separated(
        key: key,
        padding: padding,
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        itemCount: effectiveItemCount,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItem(context, item, index);
        },
      );
    }

    return ListView.builder(
      key: key,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      itemCount: effectiveItemCount,
      itemExtent: itemExtent,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItem(context, item, index);
      },
    );
  }

  Widget _buildItem(BuildContext context, T item, int index) {
    Widget itemWidget = itemBuilder(context, item, index);

    if (useRepaintBoundary) {
      itemWidget = RepaintBoundary(child: itemWidget);
    }

    return itemWidget;
  }
}

/// Optimized list view with automatic keep alive
class OptimizedListViewWithKeepAlive<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? separator;
  final bool useRepaintBoundary;

  const OptimizedListViewWithKeepAlive({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.separator,
    this.useRepaintBoundary = true,
  });

  @override
  State<OptimizedListViewWithKeepAlive<T>> createState() =>
      _OptimizedListViewWithKeepAliveState<T>();
}

class _OptimizedListViewWithKeepAliveState<T>
    extends State<OptimizedListViewWithKeepAlive<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return OptimizedListView<T>(
      key: widget.key,
      items: widget.items,
      itemBuilder: widget.itemBuilder,
      padding: widget.padding,
      controller: widget.controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      separator: widget.separator,
      useRepaintBoundary: widget.useRepaintBoundary,
    );
  }
}

/// Optimized list item with performance improvements
class OptimizedListItem extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final bool useRepaintBoundary;
  final bool useConstConstructor;

  const OptimizedListItem({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.useRepaintBoundary = true,
    this.useConstConstructor = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      key: key,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (useRepaintBoundary) {
      item = RepaintBoundary(child: item);
    }

    return item;
  }
}

/// Mixin for list performance optimization
mixin ListPerformanceMixin<T extends StatefulWidget> on State<T> {
  final Map<int, Widget> _itemCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  Widget getCachedItem(int index, Widget Function() builder) {
    final now = DateTime.now();
    final timestamp = _cacheTimestamps[index];

    if (timestamp != null && now.difference(timestamp) < _cacheDuration) {
      return _itemCache[index]!;
    }

    final item = builder();
    _itemCache[index] = item;
    _cacheTimestamps[index] = now;

    return item;
  }

  void clearItemCache(int index) {
    _itemCache.remove(index);
    _cacheTimestamps.remove(index);
  }

  void clearAllItemCache() {
    _itemCache.clear();
    _cacheTimestamps.clear();
  }

  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheDuration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      clearItemCache(key);
    }
  }

  @override
  void dispose() {
    clearAllItemCache();
    super.dispose();
  }
}

/// Optimized scroll view with performance improvements
class OptimizedScrollView extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool useRepaintBoundary;

  const OptimizedScrollView({
    super.key,
    required this.child,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.useRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget scrollView = SingleChildScrollView(
      key: key,
      controller: controller,
      primary: primary,
      physics: physics,
      padding: padding,
      child: child,
    );

    if (useRepaintBoundary) {
      scrollView = RepaintBoundary(child: scrollView);
    }

    return scrollView;
  }
}
