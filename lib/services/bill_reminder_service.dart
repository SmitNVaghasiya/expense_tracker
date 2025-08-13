import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:spendwise/models/bill_reminder.dart';
import 'database_service.dart';

class BillReminderService {
  static const _uuid = Uuid();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  // Get all bill reminders
  static Future<List<BillReminder>> getBillReminders() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('bill_reminders');
    return List.generate(maps.length, (i) => BillReminder.fromJson(maps[i]));
  }

  // Add a new bill reminder
  static Future<void> addBillReminder(BillReminder billReminder) async {
    final db = await DatabaseService.database;
    await db.insert('bill_reminders', billReminder.toJson());

    // Schedule notification if active
    if (billReminder.isActive) {
      await scheduleBillReminderNotification(billReminder);
    }
  }

  // Update a bill reminder
  static Future<void> updateBillReminder(BillReminder billReminder) async {
    final db = await DatabaseService.database;
    await db.update(
      'bill_reminders',
      billReminder.toJson(),
      where: 'id = ?',
      whereArgs: [billReminder.id],
    );

    // Reschedule notification
    await cancelBillReminderNotification(billReminder.id);
    if (billReminder.isActive) {
      await scheduleBillReminderNotification(billReminder);
    }
  }

  // Delete a bill reminder
  static Future<void> deleteBillReminder(String id) async {
    final db = await DatabaseService.database;
    await db.delete('bill_reminders', where: 'id = ?', whereArgs: [id]);

    // Cancel notification
    await cancelBillReminderNotification(id);
  }

  // Get bill reminder by ID
  static Future<BillReminder?> getBillReminderById(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BillReminder.fromJson(maps.first);
    }
    return null;
  }

  // Schedule notification for a bill reminder
  static Future<void> scheduleBillReminderNotification(
    BillReminder billReminder,
  ) async {
    if (!billReminder.isActive || billReminder.isPaid) return;

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
        billReminder.id.hashCode,
        'Bill Reminder: ${billReminder.title}',
        'Due in ${billReminder.reminderDays} days - \$${billReminder.amount.toStringAsFixed(2)}',
        tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancel notification for a bill reminder
  static Future<void> cancelBillReminderNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  // Mark bill as paid
  static Future<void> markBillAsPaid(String id) async {
    final billReminder = await getBillReminderById(id);
    if (billReminder != null) {
      final updated = billReminder.copyWith(
        isPaid: true,
        paidDate: DateTime.now(),
      );
      await updateBillReminder(updated);

      // Cancel notification
      await cancelBillReminderNotification(id);
    }
  }

  // Mark bill as unpaid
  static Future<void> markBillAsUnpaid(String id) async {
    final billReminder = await getBillReminderById(id);
    if (billReminder != null) {
      final updated = billReminder.copyWith(isPaid: false, paidDate: null);
      await updateBillReminder(updated);
    }
  }

  // Get overdue bills
  static Future<List<BillReminder>> getOverdueBills() async {
    final allBills = await getBillReminders();
    return allBills.where((bill) => bill.isOverdue).toList();
  }

  // Get bills due today
  static Future<List<BillReminder>> getBillsDueToday() async {
    final allBills = await getBillReminders();
    return allBills.where((bill) => bill.isDueToday).toList();
  }

  // Get upcoming bills (within next 7 days)
  static Future<List<BillReminder>> getUpcomingBills({int days = 7}) async {
    final allBills = await getBillReminders();
    final today = DateTime.now();
    final endDate = today.add(Duration(days: days));

    return allBills.where((bill) {
      return !bill.isPaid &&
          bill.dueDate.isAfter(today) &&
          bill.dueDate.isBefore(endDate);
    }).toList();
  }

  // Get bills that need reminders today
  static Future<List<BillReminder>> getBillsNeedingRemindersToday() async {
    final allBills = await getBillReminders();
    return allBills.where((bill) => bill.shouldSendReminderToday()).toList();
  }

  // Get bill reminders by category
  static Future<List<BillReminder>> getBillRemindersByCategory(
    String category,
  ) async {
    final allBills = await getBillReminders();
    return allBills.where((bill) => bill.category == category).toList();
  }

  // Get total monthly bill amount
  static Future<double> getTotalMonthlyBillAmount() async {
    final allBills = await getBillReminders();
    double total = 0.0;

    for (final bill in allBills) {
      if (bill.isActive && !bill.isPaid) {
        total += bill.amount;
      }
    }

    return total;
  }

  // Get bill reminders summary
  static Future<Map<String, dynamic>> getBillRemindersSummary() async {
    final allBills = await getBillReminders();
    final unpaidBills = allBills.where((b) => !b.isPaid).toList();
    final overdueBills = allBills.where((b) => b.isOverdue).toList();
    final dueTodayBills = allBills.where((b) => b.isDueToday).toList();

    double totalUnpaid = 0.0;
    double totalOverdue = 0.0;

    for (final bill in unpaidBills) {
      totalUnpaid += bill.amount;
    }

    for (final bill in overdueBills) {
      totalOverdue += bill.amount;
    }

    return {
      'totalBills': allBills.length,
      'unpaidBills': unpaidBills.length,
      'overdueBills': overdueBills.length,
      'dueTodayBills': dueTodayBills.length,
      'totalUnpaidAmount': totalUnpaid,
      'totalOverdueAmount': totalOverdue,
    };
  }

  // Reschedule all notifications (useful after app restart)
  static Future<void> rescheduleAllNotifications() async {
    final allBills = await getBillReminders();

    for (final bill in allBills) {
      if (bill.isActive && !bill.isPaid) {
        await scheduleBillReminderNotification(bill);
      }
    }
  }

  // Check and send reminders for today
  static Future<void> checkAndSendRemindersForToday() async {
    final billsNeedingReminders = await getBillsNeedingRemindersToday();

    for (final bill in billsNeedingReminders) {
      // Send immediate notification
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

      await _notifications.show(
        int.parse(bill.id.replaceAll('-', '')),
        'Bill Reminder: ${bill.title}',
        'Due in ${bill.reminderDays} days - \$${bill.amount.toStringAsFixed(2)}',
        notificationDetails,
      );
    }
  }
}
