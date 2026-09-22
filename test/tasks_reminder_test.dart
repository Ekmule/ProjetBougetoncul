import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/platform/notification_service.dart';
import 'package:mya/platform/platform_providers.dart';

class FakeNotificationService implements NotificationService {
  final scheduled = <String, DateTime>{};
  final cancelled = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    scheduled[taskId] = when;
    cancelled.remove(taskId);
  }

  @override
  Future<void> cancelReminder(String taskId) async {
    cancelled.add(taskId);
    scheduled.remove(taskId);
  }

  @override
  Future<void> showInfo({
    required String title,
    required String body,
  }) async {}
}

ProviderContainer _createContainer(
  AppDatabase database,
  FakeNotificationService notifications,
) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(database.close);
        return database;
      }),
      notificationServiceProvider.overrideWithValue(notifications),
    ],
  );
}

void main() {
  test('setTaskReminder persiste et programme une notification', () async {
    final database = AppDatabase.forTesting();
    final notifications = FakeNotificationService();
    final container = _createContainer(database, notifications);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('Rappeler ceci');
    await pumpEventQueue();

    final task = container.read(tasksProvider).firstWhere(
          (t) => t.title == 'Rappeler ceci',
        );
    final when = DateTime.now().add(const Duration(hours: 2));

    await notifier.setTaskReminder(task.id, when);
    await pumpEventQueue();

    final updated = await container.read(taskRepositoryProvider).findById(task.id);
    expect(updated?.reminderAt?.millisecondsSinceEpoch, when.millisecondsSinceEpoch);
    expect(
      notifications.scheduled[task.id]?.millisecondsSinceEpoch,
      when.millisecondsSinceEpoch,
    );
  });

  test('completeTask annule le rappel programmé', () async {
    final database = AppDatabase.forTesting();
    final notifications = FakeNotificationService();
    final container = _createContainer(database, notifications);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('À terminer');
    await pumpEventQueue();

    final task = container.read(tasksProvider).first;
    final when = DateTime.now().add(const Duration(hours: 1));
    await notifier.setTaskReminder(task.id, when);
    await pumpEventQueue();

    await notifier.completeTask(task.id);
    await pumpEventQueue();

    expect(notifications.cancelled, contains(task.id));
    expect(notifications.scheduled.containsKey(task.id), isFalse);
  });

  test('clearTaskReminder efface reminderAt et annule la notification', () async {
    final database = AppDatabase.forTesting();
    final notifications = FakeNotificationService();
    final container = _createContainer(database, notifications);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('Sans rappel');
    await pumpEventQueue();

    final task = container.read(tasksProvider).first;
    final when = DateTime.now().add(const Duration(hours: 3));
    await notifier.setTaskReminder(task.id, when);
    await pumpEventQueue();

    await notifier.clearTaskReminder(task.id);
    await pumpEventQueue();

    final updated = await container.read(taskRepositoryProvider).findById(task.id);
    expect(updated?.reminderAt, isNull);
    expect(notifications.cancelled, contains(task.id));
  });
}
