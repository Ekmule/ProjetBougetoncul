import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/domain/entities/task.dart';

ProviderContainer _createContainer(AppDatabase database) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(database.close);
        return database;
      }),
    ],
  );
}

void main() {
  test('purge automatique des tâches terminées expirées', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final repo = container.read(taskRepositoryProvider);
    final oldCompleted = Task.createNew(
      id: 'old',
      title: 'Ancienne',
      now: DateTime(2026, 3, 1),
    ).complete(now: DateTime(2026, 3, 1));
    await repo.addTask(oldCompleted);

    // Force le notifier à s'abonner et lancer la purge.
    container.read(tasksProvider);
    await pumpEventQueue();
    await pumpEventQueue();

    final stored = await repo.findById('old');
    expect(stored?.isDeleted, isTrue);
  });

  test('reopenTask réactive une tâche terminée', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('À rouvrir');
    await pumpEventQueue();

    final id = container.read(tasksProvider).first.id;
    await notifier.completeTask(id);
    await pumpEventQueue();

    await notifier.reopenTask(id);
    await pumpEventQueue();

    final task = await container.read(taskRepositoryProvider).findById(id);
    expect(task?.isActive, isTrue);
  });
}
