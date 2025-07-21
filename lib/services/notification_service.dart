import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null) return;

    // Schedule notification 1 hour before due time
    final reminderTime = task.dueDate!.subtract(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Get Nepal's time zone location
    final nepalLocation = tz.getLocation('Asia/Kathmandu');

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      'Don\'t forget: ${task.title}',
      tz.TZDateTime.from(reminderTime, nepalLocation),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  static Future<void> showTaskCompletedNotification(String taskTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'task_completed',
      'Task Completed',
      channelDescription: 'Notifications for completed tasks',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Task Completed! 🎉',
      'Great job completing: $taskTitle',
      notificationDetails,
    );
  }

  static Future<void> showDailyMotivation() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_motivation',
      'Daily Motivation',
      channelDescription: 'Daily motivational messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final motivationalMessages = [
      'Start your day with purpose! 🌟',
      'Small steps lead to big achievements! 💪',
      'Today is a great day to be productive! ✨',
      'Your future self will thank you! 🙏',
      'Progress, not perfection! 🚀',
    ];

    final message =
        motivationalMessages[DateTime.now().day % motivationalMessages.length];

    await _notifications.show(
      0, // Use 0 for daily motivation
      'Good Morning! ☀️',
      message,
      notificationDetails,
    );
  }

  static Future<void> scheduleDailyMotivation() async {
    // Schedule daily motivation at 8:00 AM
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8);

    // If it's past 8 AM today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_motivation',
      'Daily Motivation',
      channelDescription: 'Daily motivational messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    // Get Nepal's time zone location
    final nepalLocation = tz.getLocation('Asia/Kathmandu');

    await _notifications.zonedSchedule(
      1, // Use 1 for daily motivation scheduling
      'Good Morning! ☀️',
      'Start your day with purpose! 🌟',
      tz.TZDateTime.from(scheduledDate, nepalLocation),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }
}
