import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Filter chip / segmented option pill.
/// Selected: accent bg, white text.
/// Unselected: surface bg, ink2 text.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final bg    = selected ? context.cAccent  : context.cSurface;
    final fg    = selected ? Colors.white      : context.cInk2;
    final side  = selected ? BorderSide.none   : BorderSide(color: context.cBorder, width: 1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.fromBorderSide(side),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 4)],
            Text(label, style: AppText.labelStyle(fg).copyWith(fontWeight: AppText.semibold)),
          ],
        ),
      ),
    );
  }
}

/// Row of pills, one active at a time.
class AppPillRow extends StatelessWidget {
  const AppPillRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.scrollable = true,
    this.padding,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: options.map((opt) => Padding(
        padding: EdgeInsets.only(right: options.last == opt ? 0 : AppSpacing.s6),
        child: AppPill(
          label: opt,
          selected: opt == selected,
          onTap: () => onSelect(opt),
        ),
      )).toList(),
    );

    if (!scrollable) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: row,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: row,
    );
  }
}
