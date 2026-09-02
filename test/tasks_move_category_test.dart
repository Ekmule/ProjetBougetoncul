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
  test('moveTaskToCategory persiste le changement', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    await notifier.addTask('Déplacer moi');
    await pumpEventQueue();

    final task = container.read(tasksProvider).firstWhere(
          (t) => t.title == 'Déplacer moi',
        );

    await notifier.moveTaskToCategory(task.id, TaskCategoryId.mustDo);
    await pumpEventQueue();

    final updated = await container
        .read(taskRepositoryProvider)
        .findById(task.id);
    expect(updated?.category, TaskCategoryId.mustDo);
  });
}
