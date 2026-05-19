import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Standard raised surface — card bg, 1 px border, r12.
/// Use for all card-like containers replacing Container+BoxDecoration.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadius.r12;
    final bg = color ?? context.cCard;

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: context.cBorder, width: 1),
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}

/// Larger hero card (balance, account) — r16, used for prominent surfaces.
class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    required this.child,
    this.margin,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.r16,
      padding: const EdgeInsets.all(AppSpacing.s18),
      margin: margin,
      onTap: onTap,
      color: color,
      child: child,
    );
  }
}
