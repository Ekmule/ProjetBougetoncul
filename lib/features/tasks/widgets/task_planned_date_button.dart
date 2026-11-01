import 'package:flutter/material.dart';

import 'package:mya/core/utils/date_display.dart';

import 'package:mya/domain/entities/task.dart';

import 'package:mya/domain/services/task_date_service.dart';

import 'package:mya/l10n/mya_localizations.dart';
import 'package:mya/l10n/super_alert_strings.dart';

enum _PlannedDateAction { today, tomorrow, pick, toggleSuperAlert, clear }

/// Menu pour assigner ou retirer une date planifiée (D7).

class TaskPlannedDateButton extends StatelessWidget {
  const TaskPlannedDateButton({
    super.key,

    required this.task,

    required this.onSetDate,

    required this.onClearDate,

    required this.onSetSuperAlert,
  });

  final Task task;

  final void Function(DateTime date, bool superAlert) onSetDate;

  final VoidCallback onClearDate;

  final ValueChanged<bool> onSetSuperAlert;

  static const _dateService = TaskDateService();

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final l10n = context.l10n;
    var selectedDate = task.plannedDate ?? now;
    var superAlert = task.superAlertEnabled;
    final result = await showDialog<(DateTime, bool)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final alertStrings = context.superAlertStrings;
          return AlertDialog(
            title: Text(l10n.plannedDateHelp),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 5),
                    onDateChanged: (date) =>
                        setDialogState(() => selectedDate = date),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: superAlert,
                    title: Text(alertStrings.option),
                    subtitle: Text(alertStrings.optionHelp),
                    onChanged: (enabled) =>
                        setDialogState(() => superAlert = enabled),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop((selectedDate, superAlert)),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      onSetDate(result.$1, result.$2);
    }
  }

  void _handleAction(BuildContext context, _PlannedDateAction action) {
    final now = DateTime.now();

    switch (action) {
      case _PlannedDateAction.today:
        onSetDate(now, task.superAlertEnabled);

      case _PlannedDateAction.tomorrow:
        onSetDate(now.add(const Duration(days: 1)), task.superAlertEnabled);

      case _PlannedDateAction.pick:
        _pickDate(context);

      case _PlannedDateAction.toggleSuperAlert:
        onSetSuperAlert(!task.superAlertEnabled);

      case _PlannedDateAction.clear:
        onClearDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alertStrings = context.superAlertStrings;

    final now = DateTime.now();

    final hasDate = task.plannedDate != null;

    final isOverdue = _dateService.isOverdue(task, now);

    final tooltip = hasDate
        ? l10n.plannedDateButtonLabel(
            DateDisplay.plannedDate(task.plannedDate!, locale: l10n.localeCode),
          )
        : l10n.addPlannedDate;

    return PopupMenuButton<_PlannedDateAction>(
      tooltip: tooltip,

      icon: Icon(
        hasDate ? Icons.event : Icons.event_outlined,

        size: 20,

        color: task.superAlertEnabled || isOverdue ? Colors.redAccent : null,
      ),

      onSelected: (action) => _handleAction(context, action),

      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: _PlannedDateAction.today,

            child: Text(l10n.plannedDateToday),
          ),

          PopupMenuItem(
            value: _PlannedDateAction.tomorrow,

            child: Text(l10n.plannedDateTomorrow),
          ),

          PopupMenuItem(
            value: _PlannedDateAction.pick,

            child: Text(l10n.plannedDatePick),
          ),

          const PopupMenuDivider(),

          PopupMenuItem(
            value: _PlannedDateAction.toggleSuperAlert,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.superAlertEnabled
                        ? alertStrings.disableOption
                        : alertStrings.enableOption,
                  ),
                ),
                if (task.superAlertEnabled) const Icon(Icons.check, size: 18),
              ],
            ),
          ),

          if (hasDate)
            PopupMenuItem(
              value: _PlannedDateAction.clear,

              child: Text(l10n.plannedDateClear),
            ),
        ];
      },
    );
  }
}
