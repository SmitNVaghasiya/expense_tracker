import 'package:flutter/material.dart';

class ActionBottomSheet extends StatelessWidget {
  final String title;
  final List<ActionItem> actions;
  final String? cancelText;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;

  const ActionBottomSheet({
    super.key,
    required this.title,
    required this.actions,
    this.cancelText,
    this.onCancel,
    this.showCancelButton = true,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Actions List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionItem(context, action);
              },
            ),
          ),
          
          // Cancel Button
          if (showCancelButton) ...[
            const Divider(height: 1),
            ListTile(
              title: Text(
                cancelText ?? 'Cancel',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: onCancel ?? () => Navigator.of(context).pop(),
            ),
          ],
          
          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, ActionItem action) {
    return ListTile(
      leading: Icon(
        action.icon,
        color: action.iconColor ?? Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(
        action.title,
        style: TextStyle(
          fontSize: 16,
          color: action.titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: action.subtitle != null
          ? Text(
              action.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: action.subtitleColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: action.trailing,
      onTap: () {
        action.onTap?.call();
        Navigator.of(context).pop();
      },
    );
  }
}

class ActionItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ActionItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });
}

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.cancelColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Icon
          if (icon != null) ...[
            const SizedBox(height: 20),
            Icon(
              icon,
              size: 48,
              color: confirmColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
          ],
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Message
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cancelColor ?? Colors.grey[600],
                      side: BorderSide(
                        color: cancelColor ?? Colors.grey[400]!,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
