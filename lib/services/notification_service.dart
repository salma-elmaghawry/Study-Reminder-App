import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static void Function(String? payload)?
  onNotificationClick; // Initialize the notification service
  //  Details for Android notifications
  static const AndroidNotificationDetails
  _androidDetails = AndroidNotificationDetails(
    'study_reminders',
    'Study Reminders', //name shown in the notification settings on the device
    channelDescription:
        'Daily reminders to study', //description shown in the notification settings on the device
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  //<<  ----             init ----- >>
  static Future<void> init() async {
    tz.initializeTimeZones();
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationClick?.call(details.payload);
      },
    );
  }
  // <<---------------------- Request Permisssion ---------->>

  static Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  // <<---------------------- Show Notification now ---------->>

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }

  // <<---------------------- Schedule Notification ---------->>
  static Future<AndroidScheduleMode> _scheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    var canExact = await android?.canScheduleExactNotifications() ?? false;
    if (!canExact) {
      await android?.requestExactAlarmsPermission();
      canExact = await android?.canScheduleExactNotifications() ?? false;
    }
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<void> scheduleAfter({
    required int id,
    required String title,
    required String body,
    String? payload,
    required Duration duration,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(duration),
      notificationDetails: _details,
      androidScheduleMode: await _scheduleMode(),
      payload: payload,
    );
  }

  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Did the chosen time already pass today?
    bool timeAlreadyPassed = scheduledDate.isBefore(now);

    // If yes, move the reminder to tomorrow at the same time
    /*It's now 3:00 PM and the user picks 9:00 AM.
9:00 AM today has already passed, so timeAlreadyPassed = true.
The notification moves to 9:00 AM tomorrow. */
    if (timeAlreadyPassed) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details,
      androidScheduleMode: await _scheduleMode(),
      payload: payload,

      matchDateTimeComponents:
          DateTimeComponents.time, // Daily at the same time
    );
  }

  // <<---------------------- Show Notification Periodically ---------->>
  static Future<void> showPeriodically({
    required int id,
    required String title,
    required String body,
    RepeatInterval interval = RepeatInterval.everyMinute,
    String? payload,
  }) async {
    await _plugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: interval,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  static Future<void> cancel(int id) => _plugin.cancel(id: id);

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<String?> getLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }
}
