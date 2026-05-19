import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Search input field — card bg, r10, border, search icon prefix.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
    this.margin,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(AppRadius.r10),
        border: Border.all(color: context.cBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: context.cInk3),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.bodyStyle(context.cInk),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppText.bodyStyle(context.cInk3),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onClear?.call();
                onChanged?.call('');
              },
              child: Icon(Icons.close, size: 14, color: context.cInk3),
            ),
        ],
      ),
    );
  }
}
