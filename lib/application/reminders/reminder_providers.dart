import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/reminders/reminder_service.dart';
import 'package:mya/application/tasks/task_list_state.dart';
import 'package:mya/application/tasks/task_date_service_provider.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/notification_message_service.dart';
import 'package:mya/domain/services/task_reminder_service.dart';
import 'package:mya/platform/platform_providers.dart';

final notificationMessageServiceProvider = Provider<NotificationMessageService>(
  (ref) => const NotificationMessageService(),
);

final taskReminderServiceProvider = Provider<TaskReminderService>(
  (ref) => const TaskReminderService(),
);

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    ref.watch(notificationServiceProvider),
    ref.watch(notificationMessageServiceProvider),
    ref.watch(taskReminderServiceProvider),
  );
});

/// Première super alerte arrivée à échéance et non acquittée.
final pendingSuperAlertProvider = Provider<Task?>((ref) {
  final listState = ref.watch(taskListStateProvider);
  final tasks = listState.grouped.values.expand((tasks) => tasks);
  final service = ref.watch(taskDateServiceProvider);
  final now = DateTime.now();
  final due = tasks.where((task) => service.isSuperAlertDue(task, now)).toList()
    ..sort((a, b) => a.plannedDate!.compareTo(b.plannedDate!));
  return due.firstOrNull;
});
