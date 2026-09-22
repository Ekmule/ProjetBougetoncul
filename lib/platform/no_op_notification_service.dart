import 'package:mya/platform/notification_service.dart';

/// Implémentation neutre — utilisée en tests et avant initialisation.
class NoOpNotificationService implements NotificationService {
  const NoOpNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime when,
  }) async {}

  @override
  Future<void> cancelReminder(String taskId) async {}

  @override
  Future<void> showInfo({
    required String title,
    required String body,
  }) async {}
}
