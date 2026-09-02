import 'package:flutter_test/flutter_test.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/repositories/drift_task_repository.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  late AppDatabase database;
  late DriftTaskRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DriftTaskRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('addTask puis watchTasks émet la tâche', () async {
    final task = Task.createNew(
      id: 'task-1',
      title: 'Persistée',
      now: DateTime(2026, 1, 1),
    );

    await repository.addTask(task);

    final tasks = await repository.watchTasks().first;
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Persistée');
    expect(tasks.first.syncStatus, SyncStatus.pending);
  });

  test('updateTask persiste complete()', () async {
    final task = Task.createNew(
      id: 'task-1',
      title: 'À finir',
      now: DateTime(2026, 1, 1),
    );
    await repository.addTask(task);

    final completedAt = DateTime(2026, 1, 2);
    await repository.updateTask(task.complete(now: completedAt));

    final stored = await repository.findById('task-1');
    expect(stored?.status, TaskStatus.completed);
    expect(stored?.completedAt, completedAt);
  });

  test('deleteTask effectue un soft delete', () async {
    final task = Task.createNew(
      id: 'task-1',
      title: 'À supprimer',
      now: DateTime(2026, 1, 1),
    );
    await repository.addTask(task);

    await repository.deleteTask('task-1');

    final stored = await repository.findById('task-1');
    expect(stored?.isDeleted, isTrue);
  });
}
