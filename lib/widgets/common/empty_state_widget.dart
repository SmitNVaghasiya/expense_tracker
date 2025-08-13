import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.onAction,
    this.actionText,
    this.customAction,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurface.withOpacity(0.4);
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (showIcon) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: 64,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Action Button
            if (onAction != null || customAction != null) ...[
              const SizedBox(height: 32),
              customAction ??
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionText ?? 'Add New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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

class EmptyStateWithImage extends StatelessWidget {
  final String title;
  final String? message;
  final String imagePath;
  final double imageHeight;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;

  const EmptyStateWithImage({
    super.key,
    required this.title,
    this.message,
    required this.imagePath,
    this.imageHeight = 200,
    this.onAction,
    this.actionText,
    this.customAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Image.asset(
              imagePath,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Action Button
            if (onAction != null || customAction != null) ...[
              const SizedBox(height: 32),
              customAction ??
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionText ?? 'Get Started'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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

class EmptyStateWithAnimation extends StatelessWidget {
  final String title;
  final String? message;
  final Widget animation;
  final double animationHeight;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;

  const EmptyStateWithAnimation({
    super.key,
    required this.title,
    this.message,
    required this.animation,
    this.animationHeight = 200,
    this.onAction,
    this.actionText,
    this.customAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation
            SizedBox(
              height: animationHeight,
              child: animation,
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Action Button
            if (onAction != null || customAction != null) ...[
              const SizedBox(height: 32),
              customAction ??
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionText ?? 'Create New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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
