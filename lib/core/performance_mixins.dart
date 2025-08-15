import 'package:flutter/material.dart';
import 'dart:async';

/// Mixin for efficient filtering with computed properties
mixin EfficientFilteringMixin<T> on StatefulWidget {
  List<T> filterItems(
    List<T> items,
    String searchQuery,
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
    String Function(T) getTitle,
    String Function(T) getCategory,
    DateTime Function(T) getDate,
  ) {
    if (searchQuery.isEmpty &&
        selectedCategory == null &&
        startDate == null &&
        endDate == null) {
      return items;
    }

    return items.where((item) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final title = getTitle(item).toLowerCase();
        final category = getCategory(item).toLowerCase();

        if (!title.contains(query) && !category.contains(query)) {
          return false;
        }
      }

      // Category filter
      if (selectedCategory != null && selectedCategory != 'All') {
        if (getCategory(item) != selectedCategory) {
          return false;
        }
      }

      // Date range filter
      if (startDate != null && getDate(item).isBefore(startDate)) {
        return false;
      }
      if (endDate != null && getDate(item).isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }
}

/// Mixin for automatic keep alive functionality in tabs
mixin AutomaticKeepAliveMixin<T extends StatefulWidget> on State<T> {
  bool get wantKeepAlive => true;
}

/// Mixin for efficient state management with ValueNotifier
mixin ValueNotifierMixin<T extends StatefulWidget> on State<T> {
  final Map<String, ValueNotifier> _notifiers = {};

  ValueNotifier<R> getNotifier<R>(String key, R initialValue) {
    if (!_notifiers.containsKey(key)) {
      _notifiers[key] = ValueNotifier<R>(initialValue);
    }
    return _notifiers[key] as ValueNotifier<R>;
  }

  void updateNotifier<R>(String key, R value) {
    final notifier = _notifiers[key] as ValueNotifier<R>?;
    if (notifier != null) {
      notifier.value = value;
    }
  }

  @override
  void dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    super.dispose();
  }
}

/// Mixin for debounced search functionality
mixin DebouncedSearchMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;
  String _lastSearchQuery = '';

  void debouncedSearch(
    String query,
    VoidCallback onSearch, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (query == _lastSearchQuery) return;

    _lastSearchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, onSearch);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Mixin for efficient list management
mixin EfficientListMixin<T extends StatefulWidget> on State<T> {
  final Map<String, List> _cachedLists = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  List<R> getCachedList<R>(
    String key,
    Future<List<R>> Function() fetchFunction, {
    Duration cacheDuration = const Duration(minutes: 5),
  }) {
    final now = DateTime.now();
    final timestamp = _cacheTimestamps[key];

    if (timestamp != null && now.difference(timestamp) < cacheDuration) {
      return _cachedLists[key] as List<R>;
    }

    // Fetch and cache
    fetchFunction().then((list) {
      _cachedLists[key] = list;
      _cacheTimestamps[key] = now;
      if (mounted) setState(() {});
    });

    return _cachedLists[key] as List<R>? ?? [];
  }

  void clearCache(String key) {
    _cachedLists.remove(key);
    _cacheTimestamps.remove(key);
  }

  void clearAllCache() {
    _cachedLists.clear();
    _cacheTimestamps.clear();
  }
}

/// Mixin for scroll performance optimization
mixin ScrollPerformanceMixin<T extends StatefulWidget> on State<T> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  ScrollController get scrollController => _scrollController;

  void onScrollStart() {
    _isScrolling = true;
  }

  void onScrollEnd() {
    _isScrolling = false;
    if (mounted) setState(() {});
  }

  bool get isScrolling => _isScrolling;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      if (!_isScrolling) onScrollStart();
    } else {
      if (_isScrolling) onScrollEnd();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Mixin for image loading optimization
mixin ImageOptimizationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, ImageProvider> _imageCache = {};

  ImageProvider getOptimizedImage(String key, String url) {
    if (!_imageCache.containsKey(key)) {
      _imageCache[key] = NetworkImage(url);
    }
    return _imageCache[key]!;
  }

  void preloadImage(String url) {
    precacheImage(NetworkImage(url), context);
  }

  void clearImageCache() {
    _imageCache.clear();
  }
}
