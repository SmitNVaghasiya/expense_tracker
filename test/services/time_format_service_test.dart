import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/services/time_format_service.dart';

void main() {
  group('TimeFormatService Tests', () {
    setUp(() {
      // Reset the service state before each test
      TimeFormatService.reset();
    });

    test('should initialize with default 24-hour format', () {
      // Force reset to default state
      TimeFormatService.reset();
      expect(TimeFormatService.is24HourFormat, true);
    });

    test('should toggle between formats', () {
      // Ensure we start with 24-hour format
      TimeFormatService.reset();
      expect(TimeFormatService.is24HourFormat, true);

      TimeFormatService.toggleFormat();
      expect(TimeFormatService.is24HourFormat, false);

      TimeFormatService.toggleFormat();
      expect(TimeFormatService.is24HourFormat, true);
    });

    test('should set time format preference', () {
      TimeFormatService.setTimeFormat(false);
      expect(TimeFormatService.is24HourFormat, false);

      TimeFormatService.setTimeFormat(true);
      expect(TimeFormatService.is24HourFormat, true);
    });

    test('should format time in 24-hour format', () {
      TimeFormatService.setTimeFormat(true);
      final time = const TimeOfDay(hour: 14, minute: 30);
      final formatted = TimeFormatService.formatTime(time);
      expect(formatted, '14:30');
    });

    test('should format time in 12-hour format', () {
      TimeFormatService.setTimeFormat(false);
      final time = const TimeOfDay(hour: 14, minute: 30);
      final formatted = TimeFormatService.formatTime(time);
      expect(formatted, '02:30');
    });

    test('should handle midnight in 12-hour format', () {
      TimeFormatService.setTimeFormat(false);
      final time = const TimeOfDay(hour: 0, minute: 0);
      final formatted = TimeFormatService.formatTime(time);
      expect(formatted, '12:00');
    });

    test('should handle noon in 12-hour format', () {
      TimeFormatService.setTimeFormat(false);
      final time = const TimeOfDay(hour: 12, minute: 0);
      final formatted = TimeFormatService.formatTime(time);
      expect(formatted, '12:00');
    });

    test('should convert 12-hour to 24-hour format', () {
      final time = TimeFormatService.convert12To24Hour(2, 30, false); // 2:30 PM
      expect(time.hour, 14);
      expect(time.minute, 30);
    });

    test('should convert 12-hour to 24-hour format for AM', () {
      final time = TimeFormatService.convert12To24Hour(2, 30, true); // 2:30 AM
      expect(time.hour, 2);
      expect(time.minute, 30);
    });

    test('should convert 12-hour to 24-hour format for noon', () {
      final time = TimeFormatService.convert12To24Hour(
        12,
        0,
        false,
      ); // 12:00 PM
      expect(time.hour, 12);
      expect(time.minute, 0);
    });

    test('should convert 12-hour to 24-hour format for midnight', () {
      final time = TimeFormatService.convert12To24Hour(12, 0, true); // 12:00 AM
      expect(time.hour, 0);
      expect(time.minute, 0);
    });

    test('should convert 24-hour to 12-hour format', () {
      final time = const TimeOfDay(hour: 14, minute: 30);
      final result = TimeFormatService.convert24To12Hour(time);
      expect(result['hour'], 2);
      expect(result['minute'], 30);
      expect(result['isAM'], false);
    });

    test('should convert 24-hour to 12-hour format for AM', () {
      final time = const TimeOfDay(hour: 2, minute: 30);
      final result = TimeFormatService.convert24To12Hour(time);
      expect(result['hour'], 2);
      expect(result['minute'], 30);
      expect(result['isAM'], true);
    });

    test('should get correct time format hint', () {
      TimeFormatService.setTimeFormat(true);
      expect(TimeFormatService.getTimeFormatHint(), 'HH:MM (00:00-23:59)');

      TimeFormatService.setTimeFormat(false);
      expect(TimeFormatService.getTimeFormatHint(), 'HH:MM (01:00-12:59)');
    });

    test('should get correct time format description', () {
      TimeFormatService.setTimeFormat(true);
      expect(
        TimeFormatService.getTimeFormatDescription(),
        'Hours: 00-23 | Minutes: 00-59',
      );

      TimeFormatService.setTimeFormat(false);
      expect(
        TimeFormatService.getTimeFormatDescription(),
        'Hours: 01-12 | Minutes: 00-59',
      );
    });

    test('should get correct error message', () {
      TimeFormatService.setTimeFormat(true);
      expect(
        TimeFormatService.getErrorMessage(),
        'Please enter time in HH:MM format (e.g., 14:30)',
      );

      TimeFormatService.setTimeFormat(false);
      expect(
        TimeFormatService.getErrorMessage(),
        'Please enter time in HH:MM format (e.g., 02:30)',
      );
    });
  });
}
