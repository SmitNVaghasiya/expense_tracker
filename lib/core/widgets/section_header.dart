import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Section label — 12px bold title + optional right-side "View all" / action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppSpacing.s16, AppSpacing.s14, AppSpacing.s16, AppSpacing.s8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppText.bodyStyle(context.cInk).copyWith(
                fontWeight: AppText.bold, fontSize: 12,
              ),
            ),
          ),
          if (action != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppText.bodyStyle(context.cAccent).copyWith(
                  fontWeight: AppText.semibold, fontSize: 10.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Uppercase mono micro-label (e.g. "MAY 2026", "NET BALANCE").
class LabelText extends StatelessWidget {
  const LabelText(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.monoLabel(color ?? context.cInk3),
    );
  }
}
