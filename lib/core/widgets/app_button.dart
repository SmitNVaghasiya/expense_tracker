import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';

/// Full-width primary action button — accent bg, white text.
class AppButtonPrimary extends StatelessWidget {
  const AppButtonPrimary({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.danger = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool danger;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = danger ? AppColors.danger : context.cAccent;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          color: (loading || onTap == null) ? bg.withValues(alpha: 0.5) : bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: loading
          ? Center(child: SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.s8),
                ],
                Text(label, style: AppText.bodyStyle(Colors.white).copyWith(
                  fontWeight: AppText.bold, fontSize: 13,
                )),
              ],
            ),
      ),
    );
  }
}

/// Ghost button — text only, accent color.
class AppButtonGhost extends StatelessWidget {
  const AppButtonGhost({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : context.cAccent;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s8,
        ),
        child: Text(label, style: AppText.bodyStyle(color).copyWith(
          fontWeight: AppText.semibold,
        )),
      ),
    );
  }
}
