import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const String _channelId = 'medicine_reminders';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDescription =
      'Notifications for medicine reminders';

  // =====================================================
  // INITIALIZE NOTIFICATIONS
  // =====================================================

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Get device timezone
      // flutter_timezone ^4.1.0 returns String
      final String timeZoneName =
          await FlutterTimezone.getLocalTimezone();

      // Set device local timezone
      try {
        tz.setLocalLocation(
          tz.getLocation(timeZoneName),
        );

        debugPrint(
          'Device Timezone: $timeZoneName',
        );
      } catch (e) {
        debugPrint(
          'Could not set device timezone: $e',
        );
      }

      // Android initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
      );

      // Get Android plugin
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Create notification channel
      const AndroidNotificationChannel channel =
          AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin?.createNotificationChannel(channel);

      // Request notification permission
      final bool? notificationPermission =
          await androidPlugin?.requestNotificationsPermission();

      debugPrint(
        'Notification permission: $notificationPermission',
      );

      // Request exact alarm permission
      final bool? exactAlarmPermission =
          await androidPlugin?.requestExactAlarmsPermission();

      debugPrint(
        'Exact alarm permission: $exactAlarmPermission',
      );

      _initialized = true;

      debugPrint(
        'Notification Service Initialized Successfully',
      );
    } catch (e) {
      debugPrint(
        'Notification initialization error: $e',
      );
    }
  }

  // =====================================================
  // SCHEDULE DAILY MEDICINE REMINDER
  // =====================================================

  static Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If selected time has passed, schedule tomorrow
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    debugPrint('=================================');
    debugPrint('SCHEDULING MEDICINE NOTIFICATION');
    debugPrint('Current Time: $now');
    debugPrint('Scheduled Time: $scheduledDate');
    debugPrint('Notification ID: $id');
    debugPrint('Medicine: $medicineName');
    debugPrint('Dosage: $dosage');
    debugPrint('=================================');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      'Medicine Reminder 💊',
      'Time to take $medicineName ($dosage)',
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );

    debugPrint(
      'Medicine notification successfully scheduled',
    );

    // Print pending notifications for debugging
    await printPendingNotifications();
  }

  // =====================================================
  // SHOW TEST NOTIFICATION
  // =====================================================

  static Future<void> showTestNotification() async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      999999,
      'Test Notification 🔔',
      'Your notification system is working!',
      notificationDetails,
    );

    debugPrint(
      'Test notification shown successfully',
    );
  }

  // =====================================================
  // PRINT PENDING NOTIFICATIONS
  // =====================================================

  static Future<void> printPendingNotifications() async {
    try {
      final List<PendingNotificationRequest>
          pendingNotifications =
          await _notificationsPlugin
              .pendingNotificationRequests();

      debugPrint(
        '=================================',
      );

      debugPrint(
        'TOTAL PENDING NOTIFICATIONS: '
        '${pendingNotifications.length}',
      );

      if (pendingNotifications.isEmpty) {
        debugPrint(
          'NO PENDING NOTIFICATIONS FOUND',
        );
      } else {
        for (final notification
            in pendingNotifications) {
          debugPrint(
            'ID: ${notification.id}',
          );

          debugPrint(
            'TITLE: ${notification.title}',
          );

          debugPrint(
            'BODY: ${notification.body}',
          );

          debugPrint(
            'PAYLOAD: ${notification.payload}',
          );

          debugPrint(
            '---------------------------------',
          );
        }
      }

      debugPrint(
        '=================================',
      );
    } catch (e) {
      debugPrint(
        'Error getting pending notifications: $e',
      );
    }
  }

  // =====================================================
  // CANCEL ONE MEDICINE REMINDER
  // =====================================================

  static Future<void> cancelMedicineReminder(
    int id,
  ) async {
    try {
      await _notificationsPlugin.cancel(id);

      debugPrint(
        'Notification cancelled: $id',
      );

      await printPendingNotifications();
    } catch (e) {
      debugPrint(
        'Notification cancel error: $e',
      );
    }
  }

  // =====================================================
  // CANCEL ALL REMINDERS
  // =====================================================

  static Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();

      debugPrint(
        'All notifications cancelled',
      );
    } catch (e) {
      debugPrint(
        'Cancel all notifications error: $e',
      );
    }
  }
}