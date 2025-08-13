import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderService with ChangeNotifier {
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderTimeKey = 'reminder_time';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  ReminderService() {
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initializationSettings);
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_reminderEnabledKey) ?? false;

    final timeString = prefs.getString(_reminderTimeKey);
    if (timeString != null) {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    notifyListeners();
  }

  Future<void> setReminderEnabled(bool enabled) async {
    _isEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);

    if (enabled) {
      await _scheduleReminder();
    } else {
      await _cancelReminder();
    }

    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');

    if (_isEnabled) {
      await _scheduleReminder();
    }

    notifyListeners();
  }

  Future<void> _scheduleReminder() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Calculate next reminder time
      final now = DateTime.now();
      var reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderTime.hour,
        _reminderTime.minute,
      );

      // If reminder time has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reminders',
        'Daily Reminders',
        channelDescription: 'Daily reminders to track expenses',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        1001, // Unique ID for daily reminder
        'Daily Expense Reminder',
        'Time to track your expenses for today!',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Failed to schedule reminder: $e');
    }
  }

  Future<void> _cancelReminder() async {
    try {
      await _notifications.cancel(1001);
    } catch (e) {
      print('Failed to cancel reminder: $e');
    }
  }

  String getReminderTimeString() {
    return '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
  }

  // This method would be called by the notification system
  Future<void> showReminderNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_reminders',
        'Daily Reminders',
        channelDescription: 'Daily reminders to track expenses',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1002, // Different ID for immediate notification
        'Daily Expense Reminder',
        'Time to track your expenses for today!',
        notificationDetails,
      );
    } catch (e) {
      print('Failed to show reminder notification: $e');
    }
  }
}
