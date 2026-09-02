import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/reminders/reminder_providers.dart';
import 'package:mya/application/tasks/task_category_service_provider.dart';
import 'package:mya/application/tasks/task_date_service_provider.dart';
import 'package:mya/application/tasks/task_history_providers.dart';
import 'package:mya/core/utils/debug_trace.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Liste réactive des tâches persistées (Drift).
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

/// Tâches affichables (hors soft-deleted).
final visibleTasksProvider = Provider<List<Task>>((ref) {
  return ref
      .watch(tasksProvider)
      .where((task) => !task.isDeleted)
      .toList(growable: false);
});

/// Actions sur les tâches — lit/écrit via [TaskRepository].
class TasksNotifier extends Notifier<List<Task>> {
  final _uuid = const Uuid();
  StreamSubscription<List<Task>>? _subscription;
  var _isPurgingHistory = false;
  var _initialReminderSyncDone = false;

  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  List<Task> build() {
    _subscription?.cancel();
    _subscription = _repository.watchTasks().listen((tasks) {
      state = tasks;
      unawaited(_purgeExpiredHistory(tasks));
      if (!_initialReminderSyncDone) {
        _initialReminderSyncDone = true;
        unawaited(ref.read(reminderServiceProvider).syncAll(tasks));
      }
    });
    ref.onDispose(() => _subscription?.cancel());

    return const [];
  }

  /// Ajoute une tâche simple (titre seul → catégorie ENSUITE par défaut).
  Future<void> addTask(
    String title, {
    TaskCategoryId category = TaskCategoryId.next,
  }) async {
    final task = Task.createNew(
      id: _uuid.v4(),
      title: title,
      category: category,
    );
    await _repository.addTask(task);
    DebugTrace.log('tasks', 'created', {
      'id': task.id,
      'category': task.category.name,
    });
  }

  /// Modifie le titre d'une tâche active.
  Future<void> updateTaskTitle(String id, String title) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed == task.title) return;
    await _repository.updateTask(task.touch(title: trimmed));
    DebugTrace.log('tasks', 'title updated', {'id': id});
  }

  /// Marque une tâche comme terminée.
  Future<void> completeTask(String id) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;
    final updated = task.complete();
    await _repository.updateTask(updated);
    await ref.read(reminderServiceProvider).syncForTask(updated);
    DebugTrace.log('tasks', 'completed', {'id': id});
  }

  /// Réouvre une tâche terminée (section historique).
  Future<void> reopenTask(String id) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isCompleted) return;
    final updated = task.reopen();
    await _repository.updateTask(updated);
    await ref.read(reminderServiceProvider).syncForTask(updated);
    DebugTrace.log('tasks', 'reopened', {'id': id});
  }

  /// Soft delete — conservé en base pour la synchronisation (D15).
  Future<void> deleteTask(String id) async {
    final task = await _repository.findById(id);
    if (task == null) return;
    await _repository.deleteTask(id);
    await ref.read(reminderServiceProvider).cancelForTaskId(id);
    DebugTrace.log('tasks', 'deleted', {'id': id});
  }

  /// Déplace manuellement une tâche vers une autre catégorie persistée (D6).
  Future<void> moveTaskToCategory(String id, TaskCategoryId category) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final categoryService = ref.read(taskCategoryServiceProvider);
    final updated = categoryService.moveToCategory(task, category);
    if (updated == task) return;

    await _repository.updateTask(updated);
    DebugTrace.log('tasks', 'category changed', {
      'id': id,
      'category': category.name,
    });
  }

  /// Assigne une date planifiée (sans heure).
  Future<void> setTaskPlannedDate(String id, DateTime date) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final dateService = ref.read(taskDateServiceProvider);
    await _repository.updateTask(dateService.setPlannedDate(task, date));
  }

  /// Retire la date planifiée d'une tâche.
  Future<void> clearTaskPlannedDate(String id) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final dateService = ref.read(taskDateServiceProvider);
    final updated = dateService.clearPlannedDate(task);
    if (updated == task) return;

    await _repository.updateTask(updated);
  }

  /// Programme un rappel notification (date + heure).
  Future<void> setTaskReminder(String id, DateTime when) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final reminderService = ref.read(taskReminderServiceProvider);
    final updated = reminderService.setReminder(task, when);
    await _repository.updateTask(updated);
    await ref.read(reminderServiceProvider).syncForTask(updated);
  }

  /// Retire le rappel d'une tâche.
  Future<void> clearTaskReminder(String id) async {
    final task = await _repository.findById(id);
    if (task == null || !task.isActive) return;

    final reminderService = ref.read(taskReminderServiceProvider);
    final updated = reminderService.clearReminder(task);
    if (updated == task) return;

    await _repository.updateTask(updated);
    await ref.read(reminderServiceProvider).syncForTask(updated);
  }

  /// Purge automatique des tâches terminées hors rétention (D8).
  Future<void> _purgeExpiredHistory(List<Task> tasks) async {
    if (_isPurgingHistory) return;
    _isPurgingHistory = true;

    try {
      final historyService = ref.read(taskHistoryServiceProvider);
      final retentionDays = ref.read(historyRetentionDaysProvider);
      final expired = historyService.findExpiredCompleted(
        tasks,
        DateTime.now(),
        retentionDays,
      );

      for (final task in expired) {
        await _repository.deleteTask(task.id);
        await ref.read(reminderServiceProvider).cancelForTaskId(task.id);
      }
    } finally {
      _isPurgingHistory = false;
    }
  }
}
