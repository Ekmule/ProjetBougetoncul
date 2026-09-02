import 'package:mya/core/extensions/datetime_extensions.dart';
import 'package:mya/domain/entities/task.dart';

/// Calcule dans quelle section afficher une tâche.
///
/// Règles ADR-017 — toute la logique d'affichage est ici,
/// jamais dupliquée dans les widgets.
///
/// Priorité d'affichage (docs/architecture.md §8.3) :
/// 1. Terminée (gérée à part)
/// 2. En retard (plannedDate < today)
/// 3. Urgente manuelle (must_do)
/// 4. Prévue aujourd'hui (plannedDate == today)
/// 5. Catégorie persistée (next, someday, today manuelle)
class TaskDisplayService {
  const TaskDisplayService();

  /// Retourne la catégorie d'affichage d'une tâche active.
  TaskCategoryId displayCategory(Task task, DateTime now) {
    if (!task.isActive) {
      return task.category;
    }

    final today = now.dateOnly;

    if (task.plannedDate != null) {
      final planned = task.plannedDate!.dateOnly;
      if (planned.isBefore(today)) {
        return TaskCategoryId.mustDo;
      }
      if (planned == today) {
        return TaskCategoryId.today;
      }
    }

    if (task.category == TaskCategoryId.mustDo) {
      return TaskCategoryId.mustDo;
    }

    return task.category;
  }

  /// Regroupe les tâches actives par section d'affichage.
  Map<TaskCategoryId, List<Task>> groupActiveTasks(
    List<Task> tasks,
    DateTime now,
  ) {
    final grouped = <TaskCategoryId, List<Task>>{
      for (final id in TaskCategoryId.values) id: [],
    };

    for (final task in tasks.where((task) => task.isActive)) {
      final section = displayCategory(task, now);
      grouped[section]!.add(task);
    }

    return grouped;
  }

  List<Task> completedTasks(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted && !task.isDeleted).toList();
  }
}
