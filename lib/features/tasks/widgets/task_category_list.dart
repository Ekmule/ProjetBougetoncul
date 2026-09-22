import 'package:flutter/material.dart';
import 'package:mya/core/constants/task_categories.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/tasks/widgets/task_list_tile.dart';

/// En-tête + tâches d'une section catégorie.
class TaskCategorySection extends StatelessWidget {
  const TaskCategorySection({
    super.key,
    this.category,
    this.title,
    required this.tasks,
    required this.onComplete,
    this.onReopen,
    this.onMoveCategory,
    this.onSetPlannedDate,
    this.onClearPlannedDate,
    this.onSetReminder,
    this.onClearReminder,
    this.onEditTitle,
    this.onEditTaskRequested,
    this.onDelete,
    this.isCompleted = false,
    this.showWhenEmpty = false,
    this.enableCategoryMove = true,
    this.enableDateEdit = true,
    this.enableReminderEdit = true,
    this.enableTaskEdit = true,
  });

  final TaskCategoryId? category;
  final String? title;
  final List<Task> tasks;
  final void Function(String id) onComplete;
  final void Function(String id)? onReopen;
  final void Function(String id, TaskCategoryId category)? onMoveCategory;
  final void Function(String id, DateTime date)? onSetPlannedDate;
  final void Function(String id)? onClearPlannedDate;
  final void Function(String id, DateTime when)? onSetReminder;
  final void Function(String id)? onClearReminder;
  final Future<void> Function(String id, String title)? onEditTitle;
  final void Function(Task task)? onEditTaskRequested;
  final Future<void> Function(String id)? onDelete;
  final bool isCompleted;
  final bool showWhenEmpty;
  final bool enableCategoryMove;
  final bool enableDateEdit;
  final bool enableReminderEdit;
  final bool enableTaskEdit;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty && !showWhenEmpty) {
      return const SizedBox.shrink();
    }

    final label = title ?? category!.defaultLabel;
    final color = Color(category?.colorValue ?? 0xFF757575);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Rien ici',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.white38),
              ),
            )
          else
            for (final task in tasks)
              TaskListTile(
                task: task,
                onComplete: onComplete,
                onReopen: onReopen,
                onMoveCategory: onMoveCategory,
                onSetPlannedDate: onSetPlannedDate,
                onClearPlannedDate: onClearPlannedDate,
                onSetReminder: onSetReminder,
                onClearReminder: onClearReminder,
                onEditTitle: onEditTitle,
                onEditTaskRequested: onEditTaskRequested,
                onDelete: onDelete,
                isCompleted: isCompleted,
                enableCategoryMove: enableCategoryMove,
                enableDateEdit: enableDateEdit,
                enableReminderEdit: enableReminderEdit,
                enableTaskEdit: enableTaskEdit,
              ),
        ],
      ),
    );
  }
}

/// Liste scrollable groupée par catégories d'affichage.
class TaskCategoryList extends StatelessWidget {
  const TaskCategoryList({
    super.key,
    required this.groupedTasks,
    required this.completedTasks,
    required this.onComplete,
    this.onReopen,
    this.onMoveCategory,
    this.onSetPlannedDate,
    this.onClearPlannedDate,
    this.onSetReminder,
    this.onClearReminder,
    this.onEditTitle,
    this.onEditTaskRequested,
    this.onDelete,
    this.isPreview = false,
    this.showCompleted = true,
    this.showEmptySections = false,
    this.enableCategoryMove = true,
    this.enableDateEdit = true,
    this.enableReminderEdit = true,
    this.enableTaskEdit = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  final Map<TaskCategoryId, List<Task>> groupedTasks;
  final List<Task> completedTasks;
  final void Function(String id) onComplete;
  final void Function(String id)? onReopen;
  final void Function(String id, TaskCategoryId category)? onMoveCategory;
  final void Function(String id, DateTime date)? onSetPlannedDate;
  final void Function(String id)? onClearPlannedDate;
  final void Function(String id, DateTime when)? onSetReminder;
  final void Function(String id)? onClearReminder;
  final Future<void> Function(String id, String title)? onEditTitle;
  final void Function(Task task)? onEditTaskRequested;
  final Future<void> Function(String id)? onDelete;
  final bool isPreview;
  final bool showCompleted;
  final bool showEmptySections;
  final bool enableCategoryMove;
  final bool enableDateEdit;
  final bool enableReminderEdit;
  final bool enableTaskEdit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final canMove = enableCategoryMove && !isPreview && onMoveCategory != null;
    final canEditDate =
        enableDateEdit && !isPreview && onSetPlannedDate != null;
    final canEditReminder =
        enableReminderEdit && !isPreview && onSetReminder != null;
    final canEditTask =
        enableTaskEdit &&
        (onEditTaskRequested != null ||
            (onEditTitle != null && onDelete != null));

    return ListView(
      padding: padding,
      children: [
        if (_isCompletelyEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              isPreview
                  ? 'Aucune tâche active.\nCliquez pour ouvrir le panneau complet.'
                  : 'Aucune tâche active.\nAjoutez-en une ci-dessus ou rouvrez une tâche terminée.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                fontSize: isPreview ? 11 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        for (final category in TaskCategoryDisplay.displayOrder)
          TaskCategorySection(
            category: category,
            tasks: _tasksFor(category),
            onComplete: onComplete,
            onMoveCategory: onMoveCategory,
            showWhenEmpty: showEmptySections,
            enableCategoryMove: canMove,
            enableDateEdit: canEditDate,
            enableReminderEdit: canEditReminder,
            onSetPlannedDate: onSetPlannedDate,
            onClearPlannedDate: onClearPlannedDate,
            onSetReminder: onSetReminder,
            onClearReminder: onClearReminder,
            onEditTitle: onEditTitle,
            onEditTaskRequested: onEditTaskRequested,
            onDelete: onDelete,
            enableTaskEdit: canEditTask,
          ),
        if (showCompleted && completedTasks.isNotEmpty)
          TaskCategorySection(
            title: 'TERMINÉES (${completedTasks.length})',
            tasks: completedTasks,
            onComplete: onComplete,
            onReopen: onReopen,
            isCompleted: true,
            enableCategoryMove: false,
            enableDateEdit: false,
            enableReminderEdit: false,
            enableTaskEdit: false,
          ),
      ],
    );
  }

  List<Task> _tasksFor(TaskCategoryId category) {
    return groupedTasks[category] ?? const [];
  }

  bool get _isCompletelyEmpty {
    if (completedTasks.isNotEmpty) return false;
    for (final tasks in groupedTasks.values) {
      if (tasks.isNotEmpty) return false;
    }
    return true;
  }
}
