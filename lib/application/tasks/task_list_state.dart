import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/tasks/task_history_providers.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_display_service.dart';

/// Vue calculée de la liste (catégories d'affichage + terminées).
class TaskListState {
  const TaskListState({
    required this.grouped,
    required this.completed,
  });

  final Map<TaskCategoryId, List<Task>> grouped;
  final List<Task> completed;
}

final taskDisplayServiceProvider =
    Provider<TaskDisplayService>((ref) => const TaskDisplayService());

/// Regroupe les tâches visibles pour l'UI (pastille + écran principal).
final taskListStateProvider = Provider<TaskListState>((ref) {
  final tasks = ref.watch(visibleTasksProvider);
  final displayService = ref.watch(taskDisplayServiceProvider);
  final historyService = ref.watch(taskHistoryServiceProvider);
  final retentionDays = ref.watch(historyRetentionDaysProvider);
  final now = DateTime.now();

  return TaskListState(
    grouped: displayService.groupActiveTasks(tasks, now),
    completed: historyService.filterVisibleCompleted(
      tasks,
      now,
      retentionDays,
    ),
  );
});
