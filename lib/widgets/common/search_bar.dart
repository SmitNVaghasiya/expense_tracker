import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String? initialQuery;
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final bool showClearButton;
  final bool autofocus;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SearchBar({
    super.key,
    this.initialQuery,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.onClear,
    this.showClearButton = true,
    this.autofocus = false,
    this.margin,
    this.padding,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? '';
    _controller = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Search Transactions',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              widget.onSearchChanged(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _controller.clear();
                });
                widget.onClear?.call();
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _controller.clear();
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showSearchDialog,
              child: Container(
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _searchQuery.isEmpty ? widget.hintText : _searchQuery,
                        style: TextStyle(
                          color: _searchQuery.isEmpty 
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.showClearButton && _searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _clearSearch,
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Inline search bar variant for compact use
class InlineSearchBar extends StatelessWidget {
  final String? initialQuery;
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const InlineSearchBar({
    super.key,
    this.initialQuery,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Search Transactions',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: TextField(
                autofocus: true,
                controller: TextEditingController(text: initialQuery ?? ''),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                onChanged: onSearchChanged,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onClear?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
