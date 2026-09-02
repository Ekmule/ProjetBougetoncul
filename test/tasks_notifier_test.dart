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
  test('TasksNotifier ajoute une tâche persistée', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('Test tâche');
    await pumpEventQueue();

    final tasks = container.read(tasksProvider);
    expect(tasks.any((task) => task.title == 'Test tâche'), isTrue);
    expect(tasks.first.syncStatus, SyncStatus.pending);
  });

  test('deleteTask masque la tâche via visibleTasksProvider', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('À effacer');
    await pumpEventQueue();

    final id = container.read(tasksProvider).first.id;
    await notifier.deleteTask(id);
    await pumpEventQueue();

    final deleted = container.read(tasksProvider).firstWhere((t) => t.id == id);
    expect(deleted.isDeleted, isTrue);
    expect(container.read(visibleTasksProvider), isNot(contains(deleted)));
  });

  test('updateTaskTitle modifie et persiste le titre', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('Ancien titre');
    await pumpEventQueue();

    final original = container.read(tasksProvider).first;
    await notifier.updateTaskTitle(original.id, '  Nouveau titre  ');
    await pumpEventQueue();

    final updated = container
        .read(tasksProvider)
        .firstWhere((task) => task.id == original.id);
    expect(updated.title, 'Nouveau titre');
    expect(updated.syncVersion, original.syncVersion + 1);
    expect(updated.syncStatus, SyncStatus.pending);
  });
}
