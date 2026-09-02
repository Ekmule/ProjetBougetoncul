import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/reminders/reminder_service.dart';
import 'package:mya/domain/services/notification_message_service.dart';
import 'package:mya/domain/services/task_reminder_service.dart';
import 'package:mya/platform/platform_providers.dart';

final notificationMessageServiceProvider =
    Provider<NotificationMessageService>(
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
