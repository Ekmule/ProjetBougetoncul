import 'package:flutter/material.dart';

import 'package:mya/core/utils/date_display.dart';

import 'package:mya/domain/entities/task.dart';

import 'package:mya/l10n/mya_localizations.dart';



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

    final l10n = context.l10n;



    final pickedDate = await showDatePicker(

      context: context,

      initialDate: initialDate,

      firstDate: now,

      lastDate: DateTime(now.year + 5),

      locale: Localizations.localeOf(context),

      helpText: l10n.reminderDateHelp,

    );

    if (pickedDate == null || !context.mounted) return;



    final pickedTime = await showTimePicker(

      context: context,

      initialTime: TimeOfDay.fromDateTime(task.reminderAt ?? now),

      helpText: l10n.reminderTimeHelp,

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

        SnackBar(content: Text(l10n.reminderMustBeFuture)),

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

    final l10n = context.l10n;

    final hasReminder = task.reminderAt != null;

    final tooltip = hasReminder

        ? l10n.reminderButtonLabel(

            DateDisplay.reminderDateTime(

              task.reminderAt!,

              locale: l10n.localeCode,

            ),

          )

        : l10n.addReminder;



    return PopupMenuButton<_ReminderAction>(

      tooltip: tooltip,

      icon: Icon(

        hasReminder ? Icons.notifications_active : Icons.notifications_outlined,

        size: 20,

        color: hasReminder ? Colors.amber : null,

      ),

      onSelected: (action) => _handleAction(context, action),

      itemBuilder: (context) => [

        PopupMenuItem(

          value: _ReminderAction.inOneHour,

          child: Text(l10n.reminderInOneHour),

        ),

        PopupMenuItem(

          value: _ReminderAction.tomorrowMorning,

          child: Text(l10n.reminderTomorrow9),

        ),

        PopupMenuItem(

          value: _ReminderAction.pick,

          child: Text(l10n.reminderPickDateTime),

        ),

        if (hasReminder)

          PopupMenuItem(

            value: _ReminderAction.clear,

            child: Text(l10n.clearReminder),

          ),

      ],

    );

  }

}


