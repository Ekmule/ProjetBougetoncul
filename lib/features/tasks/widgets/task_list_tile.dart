import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mya/core/utils/date_display.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_date_service.dart';
import 'package:mya/features/tasks/widgets/move_category_button.dart';
import 'package:mya/features/tasks/widgets/task_edit_dialog.dart';
import 'package:mya/features/tasks/widgets/task_planned_date_button.dart';
import 'package:mya/features/tasks/widgets/task_reminder_button.dart';

/// Ligne d'une tâche dans une section catégorie.
class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
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
    this.enableCategoryMove = true,
    this.enableDateEdit = true,
    this.enableReminderEdit = true,
    this.enableTaskEdit = true,
  });

  final Task task;
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
  final bool enableCategoryMove;
  final bool enableDateEdit;
  final bool enableReminderEdit;
  final bool enableTaskEdit;

  static const _dateService = TaskDateService();

  String? _subtitle() {
    if (isCompleted && task.completedAt != null) {
      return 'Terminée le ${DateDisplay.plannedDate(task.completedAt!)}';
    }

    final parts = <String>[];
    if (task.plannedDate != null) {
      parts.add('📅 ${DateDisplay.plannedDate(task.plannedDate!)}');
    }
    if (task.reminderAt != null) {
      parts.add('🔔 ${DateDisplay.reminderDateTime(task.reminderAt!)}');
    }

    return parts.isEmpty ? null : parts.join('\n');
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await TaskEditDialog.show(context, task);
    switch (result) {
      case TaskTitleChanged(:final title):
        await onEditTitle?.call(task.id, title);
      case TaskDeletionRequested():
        await onDelete?.call(task.id);
      case null:
        return;
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    if (onEditTaskRequested != null) {
      onEditTaskRequested!(task);
      return;
    }
    await _showEditDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canMove =
        enableCategoryMove &&
        !isCompleted &&
        task.isActive &&
        onMoveCategory != null;
    final canEditDate =
        enableDateEdit &&
        !isCompleted &&
        task.isActive &&
        onSetPlannedDate != null &&
        onClearPlannedDate != null;
    final canEditReminder =
        enableReminderEdit &&
        !isCompleted &&
        task.isActive &&
        onSetReminder != null &&
        onClearReminder != null;
    final canReopen = isCompleted && task.isCompleted && onReopen != null;
    final canEditTask =
        enableTaskEdit &&
        !isCompleted &&
        task.isActive &&
        (onEditTaskRequested != null ||
            (onEditTitle != null && onDelete != null));

    final isOverdue = !isCompleted && _dateService.isOverdue(task, now);
    final subtitle = _subtitle();

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: isCompleted
          ? IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              tooltip: 'Réouvrir la tâche',
              onPressed: canReopen ? () => onReopen!(task.id) : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : IconButton(
              icon: const Icon(Icons.circle_outlined, size: 20),
              tooltip: 'Marquer comme terminée',
              onPressed: () => onComplete(task.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      onTap: canEditTask ? () => unawaited(_handleTap(context)) : null,
      title: Tooltip(
        message: canEditTask ? 'Cliquer pour modifier' : '',
        child: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.white54 : null,
          ),
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isOverdue ? Colors.redAccent : Colors.white38,
              ),
            ),
      trailing: (canEditDate || canEditReminder || canMove)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEditDate)
                  TaskPlannedDateButton(
                    task: task,
                    onSetDate: (date) => onSetPlannedDate!(task.id, date),
                    onClearDate: () => onClearPlannedDate!(task.id),
                  ),
                if (canEditReminder)
                  TaskReminderButton(
                    task: task,
                    onSetReminder: (when) => onSetReminder!(task.id, when),
                    onClearReminder: () => onClearReminder!(task.id),
                  ),
                if (canMove)
                  MoveCategoryButton(
                    task: task,
                    onMove: (category) => onMoveCategory!(task.id, category),
                  ),
              ],
            )
          : null,
    );
  }
}
