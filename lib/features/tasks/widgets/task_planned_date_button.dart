import 'package:flutter/material.dart';

import 'package:mya/core/utils/date_display.dart';

import 'package:mya/domain/entities/task.dart';

import 'package:mya/domain/services/task_date_service.dart';

import 'package:mya/l10n/mya_localizations.dart';



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

    final l10n = context.l10n;

    final picked = await showDatePicker(

      context: context,

      initialDate: task.plannedDate ?? now,

      firstDate: DateTime(now.year - 1),

      lastDate: DateTime(now.year + 5),

      locale: Localizations.localeOf(context),

      helpText: l10n.plannedDateHelp,

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

    final l10n = context.l10n;

    final now = DateTime.now();

    final hasDate = task.plannedDate != null;

    final isOverdue = _dateService.isOverdue(task, now);

    final tooltip = hasDate

        ? l10n.plannedDateButtonLabel(

            DateDisplay.plannedDate(

              task.plannedDate!,

              locale: l10n.localeCode,

            ),

          )

        : l10n.addPlannedDate;



    return PopupMenuButton<_PlannedDateAction>(

      tooltip: tooltip,

      icon: Icon(

        hasDate ? Icons.event : Icons.event_outlined,

        size: 20,

        color: isOverdue ? Colors.redAccent : null,

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


