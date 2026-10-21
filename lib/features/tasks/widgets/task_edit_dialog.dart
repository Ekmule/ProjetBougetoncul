import 'package:flutter/material.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/l10n/mya_localizations.dart';

sealed class TaskEditResult {
  const TaskEditResult();
}

class TaskTitleChanged extends TaskEditResult {
  const TaskTitleChanged(this.title);

  final String title;
}

class TaskDeletionRequested extends TaskEditResult {
  const TaskDeletionRequested();
}

/// Dialogue minimal d'édition d'une tâche active.
class TaskEditDialog extends StatefulWidget {
  const TaskEditDialog({super.key, required this.task});

  final Task task;

  static Future<TaskEditResult?> show(BuildContext context, Task task) {
    return showDialog<TaskEditResult>(
      context: context,
      builder: (context) => TaskEditDialog(task: task),
    );
  }

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(TaskTitleChanged(title));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editTaskTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(labelText: l10n.taskTitleLabel),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const TaskDeletionRequested()),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.delete),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
