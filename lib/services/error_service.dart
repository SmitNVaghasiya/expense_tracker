import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class ErrorService {
  static const String _tag = 'ErrorService';

  // Error types
  static const String databaseError = 'database_error';
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';
  static const String permissionError = 'permission_error';
  static const String unknownError = 'unknown_error';

  // Log error with context
  static void logError(
    String error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    developer.log(
      error,
      name: _tag,
      error: context != null ? '$context: $error' : error,
      stackTrace: stackTrace,
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle async operations with error handling
  static Future<T?> handleAsyncOperation<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    String? errorMessage,
    String? successMessage,
    bool showSuccessMessage = false,
  }) async {
    try {
      final result = await operation();

      if (showSuccessMessage && successMessage != null) {
        showSuccessSnackBar(context, successMessage);
      }

      return result;
    } catch (e, stackTrace) {
      logError(
        e.toString(),
        context: 'handleAsyncOperation',
        stackTrace: stackTrace,
      );

      final message = errorMessage ?? 'An error occurred. Please try again.';
      showErrorSnackBar(context, message);

      return null;
    }
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(
    String errorType, [
    String? specificError,
  ]) {
    switch (errorType) {
      case databaseError:
        return 'Database error occurred. Please restart the app.';
      case networkError:
        return 'Network connection error. Please check your internet connection.';
      case validationError:
        return specificError ?? 'Please check your input and try again.';
      case permissionError:
        return 'Permission denied. Please check app permissions.';
      case unknownError:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                child: Text(actionLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
              ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(cancelLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(confirmLabel),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
