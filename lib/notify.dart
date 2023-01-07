import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifier {
  FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  late DarwinInitializationSettings initializationSettingsDarwin;
  late InitializationSettings initializationSettings;
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("onDidReceiveLocalNotification, $id, $title, $body, $payload");
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    print("onDidReceiveLocalNotification, $details");
  }

  static final Notifier _singleton = Notifier._internal();
  factory Notifier() {
    return _singleton;
  }
  Future<bool?> _reqPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> ShowNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    print("ShowNotification: $title, $body, $payload");
    const DarwinNotificationDetails androidNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
            subtitle: "subtitle");
    const NotificationDetails notificationDetails = NotificationDetails(
        macOS: androidNotificationDetails, iOS: androidNotificationDetails);
    await _plugin.show(0, title, body, notificationDetails, payload: payload);
  }

  Future<bool?> _initPlugin() async {
    await _plugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  Notifier._internal() {
    print("Notifier created!");
    initializationSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        iOS: initializationSettingsDarwin, macOS: initializationSettingsDarwin);
    _initPlugin().then((value) {
      print("Notifier _initPlugin over: $value");
      _reqPermission().then((value) {
        print("Notifier _reqPermission over: $value");
      });
    });
  }
}
