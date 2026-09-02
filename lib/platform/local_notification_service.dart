import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mya/core/utils/app_logger.dart';
import 'package:mya/platform/notification_id.dart';
import 'package:mya/platform/notification_service.dart';
import 'package:mya/platform/timezone_config.dart';

/// Notifications locales via flutter_local_notifications (ADR-013).
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  static const _channelId = 'mya_reminders';
  static const _channelName = 'Rappels MYA';
  static const _channelDescription = 'Notifications de rappel pour vos tâches';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const windowsSettings = WindowsInitializationSettings(
      appName: 'MYA',
      appUserModelId: 'com.mya.app',
      guid: 'A8C22B55-049E-422F-B30F-863694DE08C8',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        windows: windowsSettings,
      ),
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
            ),
          );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (!kIsWeb && Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;
  }

  @override
  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    _assertInitialized();

    final id = notificationIdForTask(taskId);
    await cancelReminder(taskId);

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: toLocalTzDateTime(when),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
          windows: WindowsNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: taskId,
      );
    } catch (error, stackTrace) {
      appLogger.w(
        'Impossible de programmer le rappel $taskId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cancelReminder(String taskId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: notificationIdForTask(taskId));
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('LocalNotificationService.initialize() requis.');
    }
  }
}
