import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// ⚠️ IMPORTANT: Yeh function Class ke BAHAR hona chahiye (Top Level)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Background mein notification par tap karne ka logic
  print('Background Notification Tapped: ${notificationResponse.payload}');
}

class NotificationService {
  // Singleton Pattern (Taake har jagah ek hi instance use ho)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 1. Initialize Function
  Future<void> initNotification() async {
    // Timezone Init
    tz.initializeTimeZones();

    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings (Optional)
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,

      // Jab app khuli ho aur user tap kare
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Foreground Tap: ${response.payload}");
        // Yahan aap Navigator use kar sakte hain
      },

      // Jab app band ho aur user tap kare (Wo upar wala function pass karein)
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // 2. Simple Notification
  Future<void> showNotification({required int id, required String title, required String body}) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  // 3. Scheduled Notification (Date & Time ke saath)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local), // Time conversion
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ New Property

    );
  }

  // 4. Cancel Notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}