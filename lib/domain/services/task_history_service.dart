import 'package:mya/core/extensions/datetime_extensions.dart';
import 'package:mya/domain/entities/history_settings.dart';
import 'package:mya/domain/entities/task.dart';

/// Historique des tâches terminées — filtrage et purge (D8).
class TaskHistoryService {
  const TaskHistoryService();

  int clampRetentionDays(int days) {
    if (days <= 0) return 0;
    return days.clamp(1, HistorySettings.maxRetentionDays);
  }

  /// Vrai si la tâche terminée est encore dans la fenêtre de rétention.
  bool isWithinRetention(Task task, DateTime now, int retentionDays) {
    if (!task.isCompleted || task.completedAt == null) return false;

    final effective = clampRetentionDays(retentionDays);
    if (effective == 0) return false;

    final cutoff = now.dateOnly.subtract(Duration(days: effective - 1));
    return !task.completedAt!.dateOnly.isBefore(cutoff);
  }

  /// Tâches terminées visibles, triées par date de complétion (récentes d'abord).
  List<Task> filterVisibleCompleted(
    List<Task> tasks,
    DateTime now,
    int retentionDays,
  ) {
    final visible = tasks
        .where(
          (task) =>
              task.isCompleted &&
              !task.isDeleted &&
              isWithinRetention(task, now, retentionDays),
        )
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    return visible;
  }

  /// Tâches terminées expirées — candidates à la purge automatique.
  List<Task> findExpiredCompleted(
    List<Task> tasks,
    DateTime now,
    int retentionDays,
  ) {
    return tasks
        .where(
          (task) =>
              task.isCompleted &&
              !task.isDeleted &&
              !isWithinRetention(task, now, retentionDays),
        )
        .toList(growable: false);
  }
}
