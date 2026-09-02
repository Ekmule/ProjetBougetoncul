import 'package:mya/core/extensions/datetime_extensions.dart';
import 'package:mya/domain/entities/task.dart';

/// Déplacement manuel entre catégories persistées (D6, affiné D7).
class TaskCategoryService {
  const TaskCategoryService();

  /// Déplace une tâche active vers une catégorie persistée.
  Task moveToCategory(
    Task task,
    TaskCategoryId target, {
    DateTime? now,
  }) {
    if (!task.isActive) {
      throw StateError(
        'Impossible de déplacer une tâche inactive ou supprimée (${task.id}).',
      );
    }

    final timestamp = now ?? DateTime.now();
    final today = timestamp.dateOnly;

    return switch (target) {
      // AUJOURD'HUI : catégorie + date du jour (spec §17.2, database.md §3.2).
      TaskCategoryId.today => task.touch(
          category: TaskCategoryId.today,
          plannedDate: today,
          now: timestamp,
        ),
      // Urgent manuel : pas de date planifiée.
      TaskCategoryId.mustDo => task.touch(
          category: TaskCategoryId.mustDo,
          clearPlannedDate: task.plannedDate != null,
          now: timestamp,
        ),
      TaskCategoryId.next || TaskCategoryId.someday => task.touch(
          category: target,
          clearPlannedDate: task.plannedDate != null,
          now: timestamp,
        ),
    };
  }
}
