import 'package:flutter/material.dart';

/// Navigation cache system for preserving page states and improving performance
class NavigationCache {
  static final NavigationCache _instance = NavigationCache._internal();
  factory NavigationCache() => _instance;
  NavigationCache._internal();

  // Cache for storing page states
  final Map<String, Widget> _pageCache = {};
  final Map<String, dynamic> _pageState = {};
  final Map<String, DateTime> _lastAccess = {};

  // Configuration
  static const int _maxCacheSize = 10;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Get a cached page or create a new one
  Widget getCachedPage<T extends Widget>({
    required String key,
    required T Function() builder,
    bool forceRefresh = false,
  }) {
    // Check if we need to clear expired cache
    _cleanupExpiredCache();

    // Return cached page if available and not forcing refresh
    if (!forceRefresh && _pageCache.containsKey(key)) {
      _lastAccess[key] = DateTime.now();
      return _pageCache[key]!;
    }

    // Create new page and cache it
    final page = builder();
    _cachePage(key, page);
    return page;
  }

  /// Cache a page with its key
  void _cachePage(String key, Widget page) {
    // Remove oldest entry if cache is full
    if (_pageCache.length >= _maxCacheSize) {
      _removeOldestEntry();
    }

    _pageCache[key] = page;
    _lastAccess[key] = DateTime.now();
  }

  /// Remove the oldest cache entry
  void _removeOldestEntry() {
    if (_pageCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _lastAccess.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _pageCache.remove(oldestKey);
      _lastAccess.remove(oldestKey);
      _pageState.remove(oldestKey);
    }
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _lastAccess.entries) {
      if (now.difference(entry.value) > _cacheExpiry) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _pageCache.remove(key);
      _lastAccess.remove(key);
      _pageState.remove(key);
    }
  }

  /// Save page state
  void savePageState(String key, dynamic state) {
    _pageState[key] = state;
    _lastAccess[key] = DateTime.now();
  }

  /// Get page state
  T? getPageState<T>(String key) {
    if (_pageState.containsKey(key)) {
      _lastAccess[key] = DateTime.now();
      return _pageState[key] as T?;
    }
    return null;
  }

  /// Clear specific page cache
  void clearPageCache(String key) {
    _pageCache.remove(key);
    _lastAccess.remove(key);
    _pageState.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    _pageCache.clear();
    _lastAccess.clear();
    _pageState.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalPages': _pageCache.length,
      'totalStates': _pageState.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiry': _cacheExpiry.inMinutes,
    };
  }

  /// Check if a page is cached
  bool isPageCached(String key) {
    return _pageCache.containsKey(key);
  }

  /// Get cache size
  int get cacheSize => _pageCache.length;
}

/// Mixin for screens that need navigation caching
mixin NavigationCacheMixin<T extends StatefulWidget> on State<T> {
  NavigationCache get _navigationCache => NavigationCache();

  /// Get cached page with automatic key generation
  Widget getCachedPage<W extends Widget>({
    required W Function() builder,
    String? customKey,
    bool forceRefresh = false,
  }) {
    final key = customKey ?? _generatePageKey();
    return _navigationCache.getCachedPage(
      key: key,
      builder: builder,
      forceRefresh: forceRefresh,
    );
  }

  /// Save page state
  void savePageState(dynamic state, {String? customKey}) {
    final key = customKey ?? _generatePageKey();
    _navigationCache.savePageState(key, state);
  }

  /// Get page state
  R? getPageState<R>({String? customKey}) {
    final key = customKey ?? _generatePageKey();
    return _navigationCache.getPageState<R>(key);
  }

  /// Generate a unique key for this page
  String _generatePageKey() {
    return '${widget.runtimeType}_${widget.hashCode}';
  }

  /// Clear this page's cache
  void clearPageCache({String? customKey}) {
    final key = customKey ?? _generatePageKey();
    _navigationCache.clearPageCache(key);
  }
}

/// Optimized page route that supports caching
class CachedPageRoute<T> extends PageRoute<T> {
  CachedPageRoute({
    required this.builder,
    this.routeSettings,
    this.maintainStateValue = true,
    this.fullscreenDialogValue = false,
    this.opaqueValue = true,
    this.barrierDismissibleValue = false,
    this.barrierColorValue,
    this.barrierLabelValue,
    this.transitionDurationValue = const Duration(milliseconds: 300),
    this.reverseTransitionDurationValue = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  final WidgetBuilder builder;
  final RouteSettings? routeSettings;
  final bool maintainStateValue;
  final bool fullscreenDialogValue;
  final bool opaqueValue;
  final bool barrierDismissibleValue;
  final Color? barrierColorValue;
  final String? barrierLabelValue;
  final Duration transitionDurationValue;
  final Duration reverseTransitionDurationValue;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )?
  transitionBuilder;

  @override
  bool get opaque => opaqueValue;

  @override
  bool get barrierDismissible => barrierDismissibleValue;

  @override
  Color? get barrierColor => barrierColorValue;

  @override
  String? get barrierLabel => barrierLabelValue;

  @override
  bool get maintainState => maintainStateValue;

  @override
  Duration get transitionDuration => transitionDurationValue;

  @override
  Duration get reverseTransitionDuration => reverseTransitionDurationValue;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (transitionBuilder != null) {
      return transitionBuilder!(context, animation, secondaryAnimation, child);
    }

    // Default slide transition
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}

/// Optimized navigator that supports caching
class CachedNavigator {
  /// Push a cached route
  static Future<T?> pushCached<T extends Object?>(
    BuildContext context,
    WidgetBuilder builder, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CachedPageRoute<T>(
        builder: builder,
        routeSettings: settings,
        maintainStateValue: maintainState,
        fullscreenDialogValue: fullscreenDialog,
        opaqueValue: opaque,
        transitionDurationValue: transitionDuration,
        reverseTransitionDurationValue: reverseTransitionDuration,
      ),
    );
  }

  /// Push and replace a cached route
  static Future<T?>
  pushReplacementCached<T extends Object?, TO extends Object?>(
    BuildContext context,
    WidgetBuilder builder, {
    RouteSettings? settings,
    Object? result,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool opaque = true,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      CachedPageRoute<T>(
        builder: builder,
        routeSettings: settings,
        maintainStateValue: maintainState,
        fullscreenDialogValue: fullscreenDialog,
        opaqueValue: opaque,
        transitionDurationValue: transitionDuration,
        reverseTransitionDurationValue: reverseTransitionDuration,
      ),
      result: result as TO?,
    );
  }
}
