import 'package:flutter/material.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/l10n/super_alert_strings.dart';

/// Cloche d'activation directe de la super alerte.
class TaskReminderButton extends StatelessWidget {
  const TaskReminderButton({
    super.key,
    required this.task,
    required this.onSetSuperAlert,
  });

  final Task task;
  final ValueChanged<bool> onSetSuperAlert;

  @override
  Widget build(BuildContext context) {
    final strings = context.superAlertStrings;
    final enabled = task.superAlertEnabled;

    return IconButton(
      tooltip: enabled ? strings.disableOption : strings.enableOption,
      icon: Icon(
        enabled ? Icons.notification_important : Icons.notifications_outlined,
        size: 20,
        color: enabled ? Colors.redAccent : null,
      ),
      onPressed: () => onSetSuperAlert(!enabled),
    );
  }
}
