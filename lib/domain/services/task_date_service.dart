import 'package:mya/core/extensions/datetime_extensions.dart';
import 'package:mya/domain/entities/task.dart';

/// Logique métier des dates planifiées (D7) — distincte des rappels (D9).
class TaskDateService {
  const TaskDateService();

  bool isOverdue(Task task, DateTime now) {
    if (!task.isActive || task.plannedDate == null) return false;
    return task.plannedDate!.dateOnly.isBefore(now.dateOnly);
  }

  bool isDueToday(Task task, DateTime now) {
    if (!task.isActive || task.plannedDate == null) return false;
    return task.plannedDate!.dateOnly == now.dateOnly;
  }

  /// Assigne une date planifiée (jour calendaire, sans heure).
  Task setPlannedDate(Task task, DateTime date, {DateTime? now}) {
    _assertActive(task);
    return task.touch(plannedDate: date.dateOnly, now: now);
  }

  /// Retire la date planifiée.
  Task clearPlannedDate(Task task, {DateTime? now}) {
    _assertActive(task);
    if (task.plannedDate == null) return task;
    return task.touch(clearPlannedDate: true, now: now);
  }

  void _assertActive(Task task) {
    if (!task.isActive) {
      throw StateError(
        'Impossible de modifier la date d\'une tâche inactive (${task.id}).',
      );
    }
  }
}
