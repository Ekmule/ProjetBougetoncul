import 'package:flutter/material.dart';
import 'package:mya/core/utils/date_display.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_date_service.dart';

enum _PlannedDateAction { today, tomorrow, pick, clear }

/// Menu pour assigner ou retirer une date planifiée (D7).
class TaskPlannedDateButton extends StatelessWidget {
  const TaskPlannedDateButton({
    super.key,
    required this.task,
    required this.onSetDate,
    required this.onClearDate,
  });

  final Task task;
  final void Function(DateTime date) onSetDate;
  final VoidCallback onClearDate;

  static const _dateService = TaskDateService();

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: task.plannedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Date prévue',
    );
    if (picked != null) {
      onSetDate(picked);
    }
  }

  void _handleAction(BuildContext context, _PlannedDateAction action) {
    final now = DateTime.now();
    switch (action) {
      case _PlannedDateAction.today:
        onSetDate(now);
      case _PlannedDateAction.tomorrow:
        onSetDate(now.add(const Duration(days: 1)));
      case _PlannedDateAction.pick:
        _pickDate(context);
      case _PlannedDateAction.clear:
        onClearDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasDate = task.plannedDate != null;
    final isOverdue = _dateService.isOverdue(task, now);
    final tooltip = hasDate
        ? 'Date : ${DateDisplay.plannedDate(task.plannedDate!)}'
        : 'Ajouter une date';

    return PopupMenuButton<_PlannedDateAction>(
      tooltip: tooltip,
      icon: Icon(
        hasDate ? Icons.event : Icons.event_outlined,
        size: 20,
        color: isOverdue ? Colors.redAccent : null,
      ),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _PlannedDateAction.today,
          child: Text('Aujourd\'hui'),
        ),
        const PopupMenuItem(
          value: _PlannedDateAction.tomorrow,
          child: Text('Demain'),
        ),
        const PopupMenuItem(
          value: _PlannedDateAction.pick,
          child: Text('Choisir une date…'),
        ),
        if (hasDate)
          const PopupMenuItem(
            value: _PlannedDateAction.clear,
            child: Text('Effacer la date'),
          ),
      ],
    );
  }
}
