import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String channelId = 'hillguard_emergency_alerts';
  static const String channelName = 'HillGuard Emergency Mesh Alerts';
  static const String channelDesc = 'High-priority life-safety alerts received offline over P2P mesh';

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Create High-Priority Notification Channel for Android 8.0+
    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 600, 250, 600, 250, 600]),
      ledColor: const Color(0xFFDC2626),
      enableLights: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Request Android 13+ Notification Runtime Permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  static Future<void> showEmergencyNotification({
    required String title,
    required String body,
    int id = 1,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Emergency Hazard Alert',
      fullScreenIntent: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 600, 250, 600, 250, 600]),
      color: const Color(0xFFDC2626),
      ledColor: const Color(0xFFDC2626),
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'HillGuard Offline Mesh',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
