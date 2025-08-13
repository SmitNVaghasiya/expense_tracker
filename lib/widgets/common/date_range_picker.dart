import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final bool isRequired;
  final String? startDateHint;
  final String? endDateHint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showLabel;

  const DateRangePicker({
    super.key,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.isRequired = false,
    this.startDateHint,
    this.endDateHint,
    this.firstDate,
    this.lastDate,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              if (isRequired)
                Text(
                  '* ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                label: startDateHint ?? 'Start Date',
                value: startDate,
                onChanged: onStartDateChanged,
                firstDate: firstDate,
                lastDate: lastDate ?? endDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                context,
                label: endDateHint ?? 'End Date',
                value: endDate,
                onChanged: onEndDateChanged,
                firstDate: startDate ?? firstDate,
                lastDate: lastDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2020),
            lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value != null
                      ? DateFormat('MMM dd, yyyy').format(value)
                      : label,
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: value != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
