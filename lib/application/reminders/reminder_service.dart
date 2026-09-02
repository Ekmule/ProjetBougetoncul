import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/notification_message_service.dart';
import 'package:mya/domain/services/task_reminder_service.dart';
import 'package:mya/platform/notification_service.dart';

/// Orchestre la persistance des rappels et les notifications système (D9).
class ReminderService {
  const ReminderService(
    this._notifications,
    this._messages,
    this._taskReminder,
  );

  final NotificationService _notifications;
  final NotificationMessageService _messages;
  final TaskReminderService _taskReminder;

  /// Synchronise la notification locale avec l'état d'une tâche.
  Future<void> syncForTask(Task task, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();

    if (_taskReminder.shouldSchedule(task, timestamp)) {
      await _notifications.scheduleReminder(
        taskId: task.id,
        title: NotificationMessageService.appTitle,
        body: _messages.reminderBody(task),
        when: task.reminderAt!,
      );
      return;
    }

    await _notifications.cancelReminder(task.id);
  }

  /// Reprogramme tous les rappels actifs (démarrage de l'app).
  Future<void> syncAll(Iterable<Task> tasks, {DateTime? now}) async {
    for (final task in tasks) {
      await syncForTask(task, now: now);
    }
  }

  /// Annule la notification locale d'une tâche (sans lire la base).
  Future<void> cancelForTaskId(String taskId) async {
    await _notifications.cancelReminder(taskId);
  }
}
