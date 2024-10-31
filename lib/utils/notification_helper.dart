import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationHelper(this._notificationsPlugin) {
    initializeNotifications();
  }

  // 알림 초기화
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  // 알림 전송
  Future<void> showNotification({
    required String title,
    required String body,
    required bool isPushNotificationEnabled,
  }) async {
    if (!isPushNotificationEnabled) return; // 알림 비활성화 상태면 알림 전송하지 않음

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'auto_delete_channel', // 고정된 채널 ID
      'Auto Delete Notifications', // 채널 이름
      channelDescription: 'Notifications for scheduled auto delete actions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
