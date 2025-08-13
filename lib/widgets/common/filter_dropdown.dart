import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? hintText;
  final bool isRequired;
  final IconData? icon;
  final double? width;
  final bool showLabel;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.isRequired = false,
    this.icon,
    this.width,
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
        Container(
          width: width,
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
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText ?? 'Select $label',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            icon: const SizedBox.shrink(),
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }
}
