import 'package:flutter/material.dart';
import 'package:mya/core/utils/date_display.dart';
import 'package:mya/domain/entities/task.dart';

enum _ReminderAction { inOneHour, tomorrowMorning, pick, clear }

/// Menu pour programmer ou retirer un rappel notification (D9).
class TaskReminderButton extends StatelessWidget {
  const TaskReminderButton({
    super.key,
    required this.task,
    required this.onSetReminder,
    required this.onClearReminder,
  });

  final Task task;
  final void Function(DateTime when) onSetReminder;
  final VoidCallback onClearReminder;

  DateTime _tomorrowMorning(DateTime now) {
    final tomorrow = now.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = task.reminderAt ?? task.plannedDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Date du rappel',
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(task.reminderAt ?? now),
      helpText: 'Heure du rappel',
    );
    if (pickedTime == null) return;

    final when = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!when.isAfter(now)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le rappel doit être dans le futur.')),
      );
      return;
    }

    onSetReminder(when);
  }

  void _handleAction(BuildContext context, _ReminderAction action) {
    final now = DateTime.now();
    switch (action) {
      case _ReminderAction.inOneHour:
        onSetReminder(now.add(const Duration(hours: 1)));
      case _ReminderAction.tomorrowMorning:
        onSetReminder(_tomorrowMorning(now));
      case _ReminderAction.pick:
        _pickDateTime(context);
      case _ReminderAction.clear:
        onClearReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = task.reminderAt != null;
    final tooltip = hasReminder
        ? 'Rappel : ${DateDisplay.reminderDateTime(task.reminderAt!)}'
        : 'Ajouter un rappel';

    return PopupMenuButton<_ReminderAction>(
      tooltip: tooltip,
      icon: Icon(
        hasReminder ? Icons.notifications_active : Icons.notifications_outlined,
        size: 20,
        color: hasReminder ? Colors.amber : null,
      ),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _ReminderAction.inOneHour,
          child: Text('Dans 1 heure'),
        ),
        const PopupMenuItem(
          value: _ReminderAction.tomorrowMorning,
          child: Text('Demain 9h'),
        ),
        const PopupMenuItem(
          value: _ReminderAction.pick,
          child: Text('Choisir date et heure…'),
        ),
        if (hasReminder)
          const PopupMenuItem(
            value: _ReminderAction.clear,
            child: Text('Effacer le rappel'),
          ),
      ],
    );
  }
}
