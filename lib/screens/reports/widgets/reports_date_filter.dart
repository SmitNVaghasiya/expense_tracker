import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/services/reports/reports_data_service.dart';

class ReportsDateFilter extends StatelessWidget {
  final String selectedDateRangeOption;
  final DateTimeRange? selectedDateRange;
  final Function(String) onDateRangeOptionChanged;
  final VoidCallback onCustomDateRangeRequested;

  const ReportsDateFilter({
    super.key,
    required this.selectedDateRangeOption,
    required this.selectedDateRange,
    required this.onDateRangeOptionChanged,
    required this.onCustomDateRangeRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Range Indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range: $selectedDateRangeOption',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (selectedDateRange != null)
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(selectedDateRange!.end)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedDateRangeOption == 'Custom Range') {
                    onCustomDateRangeRequested();
                  } else {
                    _showDateRangeMenu(context);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDateRangeMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: ReportsDataService.dateRangeOptions.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    ).then((value) {
      if (value != null && value != 'Custom Range') {
        onDateRangeOptionChanged(value);
      } else if (value == 'Custom Range') {
        onCustomDateRangeRequested();
      }
    });
  }
}
