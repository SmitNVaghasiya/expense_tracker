import 'package:flutter/material.dart';

class DisplayOptionsDialog extends StatefulWidget {
  final String selectedViewMode;
  final bool showTotal;
  final bool carryOver;
  final Function(String) onViewModeChanged;
  final Function(bool) onShowTotalChanged;
  final Function(bool) onCarryOverChanged;

  const DisplayOptionsDialog({
    super.key,
    required this.selectedViewMode,
    required this.showTotal,
    required this.carryOver,
    required this.onViewModeChanged,
    required this.onShowTotalChanged,
    required this.onCarryOverChanged,
  });

  @override
  State<DisplayOptionsDialog> createState() => _DisplayOptionsDialogState();
}

class _DisplayOptionsDialogState extends State<DisplayOptionsDialog> {
  late String _selectedViewMode;
  late bool _showTotal;
  late bool _carryOver;

  @override
  void initState() {
    super.initState();
    _selectedViewMode = widget.selectedViewMode;
    _showTotal = widget.showTotal;
    _carryOver = widget.carryOver;
  }

  @override
  Widget build(BuildContext context) {
    final viewModes = [
      'DAILY',
      'WEEKLY',
      'MONTHLY',
      '3 MONTHS ★',
      '6 MONTHS ★',
      'YEARLY ★',
    ];

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                'Display options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // View mode section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'View mode:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: viewModes.map((mode) {
                      final isSelected = _selectedViewMode == mode;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedViewMode = mode;
                            });
                            widget.onViewModeChanged(mode);
                          },
                          child: Row(
                            children: [
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 6),
                              Text(
                                mode,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Show total section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Show total:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showTotal = true;
                          });
                          widget.onShowTotalChanged(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              if (_showTotal)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 6),
                              Text(
                                'YES',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _showTotal
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: _showTotal
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showTotal = false;
                          });
                          widget.onShowTotalChanged(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              if (!_showTotal)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 6),
                              Text(
                                'NO',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: !_showTotal
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: !_showTotal
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Carry over section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Carry over:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _carryOver = true;
                          });
                          widget.onCarryOverChanged(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              if (_carryOver)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ON',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _carryOver
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: _carryOver
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _carryOver = false;
                          });
                          widget.onCarryOverChanged(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              if (!_carryOver)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 6),
                              Text(
                                'OFF',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: !_carryOver
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: !_carryOver
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Info text for carry over
            if (_carryOver) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'With Carry over enabled, monthly surplus will be added to the next month.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Close button
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the display options dialog
Future<void> showDisplayOptionsDialog(
  BuildContext context, {
  required String selectedViewMode,
  required bool showTotal,
  required bool carryOver,
  required Function(String) onViewModeChanged,
  required Function(bool) onShowTotalChanged,
  required Function(bool) onCarryOverChanged,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => DisplayOptionsDialog(
      selectedViewMode: selectedViewMode,
      showTotal: showTotal,
      carryOver: carryOver,
      onViewModeChanged: onViewModeChanged,
      onShowTotalChanged: onShowTotalChanged,
      onCarryOverChanged: onCarryOverChanged,
    ),
  );
}
