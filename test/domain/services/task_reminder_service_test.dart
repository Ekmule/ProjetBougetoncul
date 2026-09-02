import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_reminder_service.dart';

void main() {
  const service = TaskReminderService();
  final now = DateTime(2026, 3, 15, 10);

  Task activeTask() {
    return Task.createNew(id: 't1', title: 'Test', now: now);
  }

  test('setReminder enregistre une date future', () {
    final when = DateTime(2026, 3, 16, 14);
    final updated = service.setReminder(activeTask(), when, now: now);

    expect(updated.reminderAt, when);
  });

  test('setReminder rejette une date passée', () {
    expect(
      () => service.setReminder(
        activeTask(),
        DateTime(2026, 3, 14, 12),
        now: now,
      ),
      throwsArgumentError,
    );
  });

  test('clearReminder efface reminderAt', () {
    final withReminder = service.setReminder(
      activeTask(),
      DateTime(2026, 3, 16, 14),
      now: now,
    );

    final cleared = service.clearReminder(withReminder, now: now);
    expect(cleared.reminderAt, isNull);
  });

  test('shouldSchedule ignore les tâches terminées', () {
    final completed = activeTask()
        .complete(now: now)
        .copyWith(reminderAt: DateTime(2026, 3, 16, 14));

    expect(service.shouldSchedule(completed, now), isFalse);
  });

  test('shouldSchedule exige un rappel futur', () {
    final future = service.setReminder(
      activeTask(),
      DateTime(2026, 3, 16, 14),
      now: now,
    );
    final pastTask = activeTask().copyWith(
      reminderAt: DateTime(2026, 3, 14, 8),
    );

    expect(service.shouldSchedule(future, now), isTrue);
    expect(service.shouldSchedule(pastTask, now), isFalse);
  });
}
