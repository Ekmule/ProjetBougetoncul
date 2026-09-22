/// Abstraction des notifications système (ADR-013).
abstract class NotificationService {
  Future<void> initialize();

  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime when,
  });

  Future<void> cancelReminder(String taskId);

  /// Notification immédiate (aide, info système).
  Future<void> showInfo({
    required String title,
    required String body,
  });
}
