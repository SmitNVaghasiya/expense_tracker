import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    this.showMessage = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: size * 0.1,
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
            if (showMessage && message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withOpacity(opacity),
            child: LoadingIndicator(
              message: loadingMessage,
              showMessage: true,
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48.0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.onPrimary;
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
