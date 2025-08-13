import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.error;
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: effectiveColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error Title
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            
            // Error Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBar extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final Color? backgroundColor;

  const ErrorSnackBar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? Colors.red[600],
      duration: duration,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel!,
              textColor: Colors.white,
              onPressed: onAction!,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final bool showCancel;
  final String? cancelText;
  final VoidCallback? onCancel;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
    this.showCancel = true,
    this.cancelText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
      actions: [
        if (showCancel)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(
              cancelText ?? 'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText ?? 'OK'),
        ),
      ],
    );
  }
}
