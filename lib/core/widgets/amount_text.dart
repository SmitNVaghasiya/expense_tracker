import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Monospace amount display with automatic sign coloring.
/// positive → ok green, negative → danger red, neutral → ink.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.currencySymbol = '₹',
    this.size,
    this.neutral = false,
    this.showSign = true,
    this.style,
  });

  final double amount;
  final String currencySymbol;
  final double? size;
  final bool neutral;
  final bool showSign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    Color color;
    if (neutral) {
      color = isDark ? AppColors.inkDark : AppColors.ink;
    } else if (amount >= 0) {
      color = AppColors.ok;
    } else {
      color = AppColors.danger;
    }

    final sign = showSign && !neutral
        ? (amount >= 0 ? '+' : '−')
        : '';
    final absAmount = amount.abs();
    final formatted = _format(absAmount);

    return Text(
      '$sign$currencySymbol$formatted',
      style: style ?? AppText.monoAmount(color, size: size ?? AppText.numSmall),
    );
  }

  String _format(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    // Indian number format with commas
    final parts = v.toStringAsFixed(0).split('');
    final reversed = parts.reversed.toList();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) chunks.add(',');
      chunks.add(reversed[i]);
    }
    return chunks.reversed.join();
  }
}
