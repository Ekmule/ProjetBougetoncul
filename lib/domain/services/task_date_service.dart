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
    return task.touch(
      plannedDate: date.dateOnly,
      clearSuperAlertAcknowledgedAt: true,
      now: now,
    );
  }

  /// Retire la date planifiée.
  Task clearPlannedDate(Task task, {DateTime? now}) {
    _assertActive(task);
    if (task.plannedDate == null) return task;
    return task.touch(
      clearPlannedDate: true,
      superAlertEnabled: false,
      clearSuperAlertAcknowledgedAt: true,
      now: now,
    );
  }

  Task setSuperAlert(Task task, bool enabled, {DateTime? now}) {
    _assertActive(task);
    if (task.superAlertEnabled == enabled) return task;
    return task.touch(
      superAlertEnabled: enabled,
      clearSuperAlertAcknowledgedAt: true,
      now: now,
    );
  }

  /// Une alerte est présentée une fois le jour prévu, puis une seconde fois
  /// lorsque la tâche devient en retard.
  bool isSuperAlertDue(Task task, DateTime now) {
    if (!task.isActive || !task.superAlertEnabled || task.plannedDate == null) {
      return false;
    }

    final planned = task.plannedDate!.dateOnly;
    final today = now.dateOnly;
    if (planned.isAfter(today)) return false;

    final acknowledged = task.superAlertAcknowledgedAt?.dateOnly;
    if (acknowledged == null) return true;
    if (planned == today) return acknowledged.isBefore(planned);

    // En retard : un acquittement postérieur au jour prévu clôt ce second
    // déclenchement, sans répéter l'alerte chaque jour.
    return !acknowledged.isAfter(planned);
  }

  Task acknowledgeSuperAlert(Task task, {DateTime? now}) {
    _assertActive(task);
    if (!task.superAlertEnabled) return task;
    final timestamp = now ?? DateTime.now();
    return task.touch(superAlertAcknowledgedAt: timestamp, now: timestamp);
  }

  void _assertActive(Task task) {
    if (!task.isActive) {
      throw StateError(
        'Impossible de modifier la date d\'une tâche inactive (${task.id}).',
      );
    }
  }
}
