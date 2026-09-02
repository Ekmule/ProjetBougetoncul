import 'package:mya/domain/entities/task.dart';

/// Logique métier des rappels notification (D9) — distincte des dates planifiées.
class TaskReminderService {
  const TaskReminderService();

  /// Vrai si la tâche doit avoir une notification locale programmée.
  bool shouldSchedule(Task task, DateTime now) {
    if (!task.isActive || task.reminderAt == null) return false;
    return task.reminderAt!.isAfter(now);
  }

  /// Assigne un rappel (date + heure) sur une tâche active.
  Task setReminder(Task task, DateTime when, {DateTime? now}) {
    _assertActive(task);

    final timestamp = now ?? DateTime.now();
    if (!when.isAfter(timestamp)) {
      throw ArgumentError.value(
        when,
        'when',
        'Le rappel doit être dans le futur.',
      );
    }

    return task.touch(reminderAt: when, now: timestamp);
  }

  /// Retire le rappel d'une tâche active.
  Task clearReminder(Task task, {DateTime? now}) {
    _assertActive(task);
    if (task.reminderAt == null) return task;
    return task.touch(clearReminderAt: true, now: now);
  }

  void _assertActive(Task task) {
    if (!task.isActive) {
      throw StateError(
        'Impossible de modifier le rappel d\'une tâche inactive (${task.id}).',
      );
    }
  }
}
