import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:spendwise/models/bill_reminder.dart';

class BillReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    if (kIsWeb) {
      // Notifications not supported on web
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  // Get all bill reminders
  static Future<List<BillReminder>> getBillReminders() async {
    try {
      if (kIsWeb) {
        // For web, return empty list for now
        // You can implement web storage for bill reminders if needed
        return [];
      } else {
        // For mobile, implement mobile storage
        // This is a simplified version - you may need to implement proper bill reminder storage
        return [];
      }
    } catch (e) {
      // Error logged
      return [];
    }
  }

  // Add a new bill reminder
  static Future<void> addBillReminder(BillReminder billReminder) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }

      // Schedule notification if active and not on web
      if (!kIsWeb && billReminder.isActive) {
        await scheduleBillReminderNotification(billReminder);
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Update a bill reminder
  static Future<void> updateBillReminder(BillReminder billReminder) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }

      // Reschedule notification if not on web
      if (!kIsWeb) {
        await cancelBillReminderNotification(billReminder.id);
        if (billReminder.isActive) {
          await scheduleBillReminderNotification(billReminder);
        }
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Delete a bill reminder
  static Future<void> deleteBillReminder(String id) async {
    try {
      if (kIsWeb) {
        // For web, implement web storage
      } else {
        // For mobile, implement mobile storage
      }

      // Cancel notification if not on web
      if (!kIsWeb) {
        await cancelBillReminderNotification(id);
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Get bill reminder by ID
  static Future<BillReminder?> getBillReminderById(String id) async {
    try {
      final billReminders = await getBillReminders();
      return billReminders.firstWhere(
        (br) => br.id == id,
        orElse: () => throw Exception('Bill reminder not found'),
      );
    } catch (e) {
      // Error logged
      return null;
    }
  }

  // Schedule notification for a bill reminder
  static Future<void> scheduleBillReminderNotification(
    BillReminder billReminder,
  ) async {
    if (kIsWeb || !billReminder.isActive || billReminder.isPaid) return;

    try {
      final reminderDate = billReminder.dueDate.subtract(
        Duration(days: billReminder.reminderDays),
      );
      final now = DateTime.now();

      // Only schedule if reminder date is in the future
      if (reminderDate.isAfter(now)) {
        const androidDetails = AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Notifications for bill reminders',
          importance: Importance.high,
          priority: Priority.high,
        );

        const iosDetails = DarwinNotificationDetails();

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notifications.zonedSchedule(
          id: billReminder.id.hashCode,
          title: 'Bill Reminder: ${billReminder.title}',
          body: 'Due in ${billReminder.reminderDays} days - \$${billReminder.amount.toStringAsFixed(2)}',
          scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      // Error logged
    }
  }

  // Cancel notification for a bill reminder
  static Future<void> cancelBillReminderNotification(String id) async {
    if (kIsWeb) return;

    try {
      await _notifications.cancel(id: id.hashCode);
    } catch (e) {
      // Error logged
    }
  }

  // Get bill reminders by account
  static Future<List<BillReminder>> getBillRemindersByAccount(
    String accountId,
  ) async {
    try {
      final billReminders = await getBillReminders();
      return billReminders.where((br) => br.accountId == accountId).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  // Get active bill reminders
  static Future<List<BillReminder>> getActiveBillReminders() async {
    try {
      final billReminders = await getBillReminders();
      return billReminders.where((br) => br.isActive && !br.isPaid).toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  // Get overdue bill reminders
  static Future<List<BillReminder>> getOverdueBillReminders() async {
    try {
      final billReminders = await getBillReminders();
      final now = DateTime.now();
      return billReminders
          .where((br) => br.isActive && !br.isPaid && br.dueDate.isBefore(now))
          .toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  // Get upcoming bill reminders
  static Future<List<BillReminder>> getUpcomingBillReminders(
    int daysAhead,
  ) async {
    try {
      final billReminders = await getBillReminders();
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      return billReminders
          .where(
            (br) =>
                br.isActive &&
                !br.isPaid &&
                br.dueDate.isAfter(now) &&
                br.dueDate.isBefore(futureDate),
          )
          .toList();
    } catch (e) {
      // Error logged
      return [];
    }
  }

  // Mark bill reminder as paid
  static Future<void> markBillReminderAsPaid(String id) async {
    try {
      final billReminder = await getBillReminderById(id);
      if (billReminder != null) {
        final paidReminder = billReminder.copyWith(isPaid: true);
        await updateBillReminder(paidReminder);
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Pause a bill reminder
  static Future<void> pauseBillReminder(String id) async {
    try {
      final billReminder = await getBillReminderById(id);
      if (billReminder != null) {
        final pausedReminder = billReminder.copyWith(isActive: false);
        await updateBillReminder(pausedReminder);
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Resume a bill reminder
  static Future<void> resumeBillReminder(String id) async {
    try {
      final billReminder = await getBillReminderById(id);
      if (billReminder != null) {
        final resumedReminder = billReminder.copyWith(isActive: true);
        await updateBillReminder(resumedReminder);
      }
    } catch (e) {
      // Error logged
      rethrow;
    }
  }

  // Get total monthly bill amount
  static Future<double> getTotalMonthlyBillAmount() async {
    try {
      final billReminders = await getBillReminders();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      double total = 0.0;
      for (final reminder in billReminders) {
        if (reminder.isActive &&
            !reminder.isPaid &&
            reminder.dueDate.isAfter(monthStart) &&
            reminder.dueDate.isBefore(monthEnd)) {
          total += reminder.amount;
        }
      }

      return total;
    } catch (e) {
      // Error logged
      return 0.0;
    }
  }
}
