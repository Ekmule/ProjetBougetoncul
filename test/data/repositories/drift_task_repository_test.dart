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

    final operations = await database.select(database.syncOperations).get();
    expect(operations, hasLength(1));
    expect(operations.single.operation, 'create');
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

    final operations = await database.select(database.syncOperations).get();
    expect(operations, hasLength(1));
    expect(operations.single.operation, 'complete');
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

    final operations = await database.select(database.syncOperations).get();
    expect(operations, hasLength(1));
    expect(operations.single.operation, 'delete');
  });

  test(
    'un compte ne voit pas les tâches appartenant à un autre compte',
    () async {
      await repository.addTask(
        Task.createNew(id: 'user-1-task', title: 'Compte 1', userId: 'user-1'),
      );
      await repository.addTask(
        Task.createNew(id: 'user-2-task', title: 'Compte 2', userId: 'user-2'),
      );

      final userOneRepository = DriftTaskRepository(
        database,
        activeUserId: 'user-1',
        filterByOwner: true,
      );
      final localRepository = DriftTaskRepository(
        database,
        filterByOwner: true,
      );

      expect(
        (await userOneRepository.watchTasks().first).map((task) => task.id),
        ['user-1-task'],
      );
      expect(await userOneRepository.findById('user-2-task'), isNull);
      expect(await localRepository.watchTasks().first, isEmpty);
    },
  );
}
