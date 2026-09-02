import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/providers/data_providers.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_display_service.dart';

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
  test('setTaskPlannedDate affiche la tâche dans AUJOURD HUI', () async {
    final database = AppDatabase.forTesting();
    final container = _createContainer(database);
    addTearDown(container.dispose);

    final notifier = container.read(tasksProvider.notifier);
    final today = DateTime(2026, 3, 15);

    await notifier.addTask('Portraits');
    await pumpEventQueue();

    final task = container.read(tasksProvider).firstWhere(
          (t) => t.title == 'Portraits',
        );

    await notifier.setTaskPlannedDate(task.id, today);
    await pumpEventQueue();

    const displayService = TaskDisplayService();
    final updated = container.read(tasksProvider).firstWhere(
          (t) => t.id == task.id,
        );

    expect(
      displayService.displayCategory(updated, today),
      TaskCategoryId.today,
    );
  });
}
