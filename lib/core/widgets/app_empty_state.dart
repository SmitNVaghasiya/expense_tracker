import 'package:flutter/material.dart';
import 'package:spendwise/core/design_system.dart';
import 'package:spendwise/core/widgets/app_button.dart';

/// Centered empty state: icon + title + subtitle + optional CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s32, vertical: AppSpacing.s48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  border: Border.all(color: context.cBorder, width: 1),
                ),
                child: Icon(icon, size: 24, color: context.cInk3),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
            Text(
              title,
              style: AppText.bodyStyle(context.cInk).copyWith(
                fontWeight: AppText.semibold, fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s6),
              Text(
                subtitle!,
                style: AppText.bodyStyle(context.cInk3),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.s20),
              AppButtonPrimary(label: ctaLabel!, onTap: onCta),
            ],
          ],
        ),
      ),
    );
  }
}
