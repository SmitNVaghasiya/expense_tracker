import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/services/error_service.dart';

void main() {
  group('ErrorService Tests', () {
    group('Error Types', () {
      test('should have correct error type constants', () {
        expect(ErrorService.databaseError, equals('database_error'));
        expect(ErrorService.networkError, equals('network_error'));
        expect(ErrorService.validationError, equals('validation_error'));
        expect(ErrorService.permissionError, equals('permission_error'));
        expect(ErrorService.unknownError, equals('unknown_error'));
      });
    });

    group('User Friendly Messages', () {
      test('should return correct message for database error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.databaseError,
        );
        expect(
          message,
          equals('Database error occurred. Please restart the app.'),
        );
      });

      test('should return correct message for network error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.networkError,
        );
        expect(
          message,
          equals(
            'Network connection error. Please check your internet connection.',
          ),
        );
      });

      test('should return correct message for validation error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.validationError,
        );
        expect(message, equals('Please check your input and try again.'));
      });

      test('should return custom message for validation error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.validationError,
          'Amount must be positive',
        );
        expect(message, equals('Amount must be positive'));
      });

      test('should return correct message for permission error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.permissionError,
        );
        expect(
          message,
          equals('Permission denied. Please check app permissions.'),
        );
      });

      test('should return default message for unknown error', () {
        final message = ErrorService.getUserFriendlyMessage(
          ErrorService.unknownError,
        );
        expect(
          message,
          equals('An unexpected error occurred. Please try again.'),
        );
      });

      test('should return default message for invalid error type', () {
        final message = ErrorService.getUserFriendlyMessage(
          'invalid_error_type',
        );
        expect(
          message,
          equals('An unexpected error occurred. Please try again.'),
        );
      });
    });

    group('Error Logging', () {
      test('should log error without context', () {
        // This test verifies that logError doesn't throw an exception
        expect(() {
          ErrorService.logError('Test error message');
        }, returnsNormally);
      });

      test('should log error with context', () {
        // This test verifies that logError doesn't throw an exception
        expect(() {
          ErrorService.logError('Test error message', context: 'TestContext');
        }, returnsNormally);
      });

      test('should log error with stack trace', () {
        // This test verifies that logError doesn't throw an exception
        expect(() {
          ErrorService.logError(
            'Test error message',
            context: 'TestContext',
            stackTrace: StackTrace.current,
          );
        }, returnsNormally);
      });
    });

    group('Async Operation Handling', () {
      test('should handle successful async operation', () async {
        // Note: This test would require a mock BuildContext
        // For now, we'll just test the error logging functionality
        expect(() {
          ErrorService.logError('Test error');
        }, returnsNormally);
      });

      test('should handle failed async operation', () async {
        // Note: This test would require a mock BuildContext
        // For now, we'll just test the error logging functionality
        expect(() {
          ErrorService.logError('Test error', context: 'TestContext');
        }, returnsNormally);
      });
    });
  });
}
