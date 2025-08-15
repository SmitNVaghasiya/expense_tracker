import 'package:flutter/material.dart';
import 'dart:io';

class TimeFormatService {
  static bool _is24HourFormat = true;
  static bool _isInitialized = false;

  /// Initialize the time format service by detecting system preference
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to detect system locale for time format
      final locale = Platform.localeName;

      // Countries that typically use 12-hour format
      final twelveHourCountries = [
        'US',
        'CA',
        'GB',
        'AU',
        'NZ',
        'IN',
        'PH',
        'MY',
        'SG',
        'HK',
      ];

      // Check if current locale suggests 12-hour format
      final countryCode = locale.split('_').lastOrNull;
      if (countryCode != null && twelveHourCountries.contains(countryCode)) {
        _is24HourFormat = false;
      } else {
        _is24HourFormat = true;
      }
    } catch (e) {
      // Default to 24-hour format if detection fails
      _is24HourFormat = true;
    }

    _isInitialized = true;
  }

  /// Get the current time format preference
  static bool get is24HourFormat {
    // Don't auto-initialize to avoid test issues
    return _is24HourFormat;
  }

  /// Set the time format preference
  static void setTimeFormat(bool use24Hour) {
    _is24HourFormat = use24Hour;
  }

  /// Toggle between 24-hour and 12-hour format
  static void toggleFormat() {
    _is24HourFormat = !_is24HourFormat;
  }

  /// Reset the service to default state (for testing purposes)
  static void reset() {
    _is24HourFormat = true;
    _isInitialized = false;
  }

  /// Format time based on current preference
  static String formatTime(TimeOfDay time) {
    if (_is24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      int hour12 = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Convert 12-hour time to 24-hour format
  static TimeOfDay convert12To24Hour(int hour12, int minute, bool isAM) {
    int hour24 = hour12;

    if (hour12 == 12) {
      hour24 = isAM ? 0 : 12;
    } else if (!isAM) {
      hour24 = hour12 + 12;
    }

    return TimeOfDay(hour: hour24, minute: minute);
  }

  /// Convert 24-hour time to 12-hour format
  static Map<String, dynamic> convert24To12Hour(TimeOfDay time) {
    int hour12 = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    bool isAM = time.hour < 12;

    return {'hour': hour12, 'minute': time.minute, 'isAM': isAM};
  }

  /// Get time format hint text
  static String getTimeFormatHint() {
    return _is24HourFormat ? 'HH:MM (00:00-23:59)' : 'HH:MM (01:00-12:59)';
  }

  /// Get time format description
  static String getTimeFormatDescription() {
    return _is24HourFormat
        ? 'Hours: 00-23 | Minutes: 00-59'
        : 'Hours: 01-12 | Minutes: 00-59';
  }

  /// Get error message for invalid time input
  static String getErrorMessage() {
    return _is24HourFormat
        ? 'Please enter time in HH:MM format (e.g., 14:30)'
        : 'Please enter time in HH:MM format (e.g., 02:30)';
  }
}
