import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WarningPreferencesService {
  static const String _hiddenWarningsKey = 'hidden_warnings';
  static const String _lastResetMonthKey = 'last_reset_month';

  // Hide a specific warning
  static Future<void> hideWarning(String warningType, String? category) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenWarnings = _getHiddenWarnings(prefs);
    
    final warningKey = category != null ? '${warningType}_$category' : warningType;
    hiddenWarnings[warningKey] = {
      'type': warningType,
      'category': category,
      'hiddenAt': DateTime.now().toIso8601String(),
      'resetMonthly': true,
    };
    
    await prefs.setString(_hiddenWarningsKey, jsonEncode(hiddenWarnings));
  }

  // Check if a warning is hidden
  static Future<bool> isWarningHidden(String warningType, String? category) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenWarnings = _getHiddenWarnings(prefs);
    
    final warningKey = category != null ? '${warningType}_$category' : warningType;
    return hiddenWarnings.containsKey(warningKey);
  }

  // Get all hidden warnings
  static Future<Map<String, dynamic>> getHiddenWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    return _getHiddenWarnings(prefs);
  }

  // Check and reset monthly warnings
  static Future<void> checkAndResetMonthlyWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateTime.now().month;
    final lastResetMonth = prefs.getInt(_lastResetMonthKey) ?? 0;
    
    // If it's a new month, reset monthly warnings
    if (currentMonth != lastResetMonth) {
      final hiddenWarnings = _getHiddenWarnings(prefs);
      final updatedWarnings = <String, dynamic>{};
      
      // Keep only permanent warnings, remove monthly ones
      for (final entry in hiddenWarnings.entries) {
        if (entry.value['resetMonthly'] != true) {
          updatedWarnings[entry.key] = entry.value;
        }
      }
      
      await prefs.setString(_hiddenWarningsKey, jsonEncode(updatedWarnings));
      await prefs.setInt(_lastResetMonthKey, currentMonth);
    }
  }

  // Clear all hidden warnings
  static Future<void> clearAllHiddenWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hiddenWarningsKey);
  }

  // Get hidden warnings count
  static Future<int> getHiddenWarningsCount() async {
    final hiddenWarnings = await getHiddenWarnings();
    return hiddenWarnings.length;
  }

  // Private method to get hidden warnings from SharedPreferences
  static Map<String, dynamic> _getHiddenWarnings(SharedPreferences prefs) {
    try {
      final String? hiddenWarningsJson = prefs.getString(_hiddenWarningsKey);
      if (hiddenWarningsJson != null) {
        return Map<String, dynamic>.from(jsonDecode(hiddenWarningsJson));
      }
    } catch (e) {
      // If parsing fails, return empty map
      print('Error parsing hidden warnings: $e');
    }
    return <String, dynamic>{};
  }

  // Get warning statistics
  static Future<Map<String, dynamic>> getWarningStatistics() async {
    final hiddenWarnings = await getHiddenWarnings();
    final totalHidden = hiddenWarnings.length;
    
    int monthlyHidden = 0;
    int permanentHidden = 0;
    
    for (final warning in hiddenWarnings.values) {
      if (warning['resetMonthly'] == true) {
        monthlyHidden++;
      } else {
        permanentHidden++;
      }
    }
    
    return {
      'totalHidden': totalHidden,
      'monthlyHidden': monthlyHidden,
      'permanentHidden': permanentHidden,
    };
  }
}
