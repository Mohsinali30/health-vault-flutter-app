import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// ⚠️ TOP LEVEL FUNCTION (Class ke bahar)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Background Notification Tapped: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones(); // Timezone init

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Foreground Tap: ${response.payload}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android 13+ Permission Request
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // SCHEDULE NOTIFICATION FUNCTION
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_vault_channel_v2',
          'Health Vault Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,

        ),
      ),
      // ✅ Yahan comma aur placement check karein
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
     // uiLocalNotificationDateInterpretation:
      //UILocalNotificationDateInterpretation.absoluteTime, // ✅ Bilkul Sahi hai
    );
  }

  // Cancel function
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}