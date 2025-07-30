import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderService with ChangeNotifier {
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderTimeKey = 'reminder_time';
  
  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  
  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  
  ReminderService() {
    _loadSettings();
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
      _scheduleReminder();
    } else {
      _cancelReminder();
    }
    
    notifyListeners();
  }
  
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');
    
    if (_isEnabled) {
      _scheduleReminder();
    }
    
    notifyListeners();
  }
  
  void _scheduleReminder() {
    // In a real app, you would use a local notification plugin
    // like flutter_local_notifications to schedule daily reminders
    // For now, we'll just print a message
    print('Daily reminder scheduled for ${_reminderTime.hour}:${_reminderTime.minute}');
  }
  
  void _cancelReminder() {
    // Cancel the scheduled reminder
    print('Daily reminder cancelled');
  }
  
  String getReminderTimeString() {
    return '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
  }
  
  // This method would be called by the notification system
  void showReminderNotification() {
    // Show a notification to remind the user to track expenses
    print('Showing daily reminder notification');
  }
} 