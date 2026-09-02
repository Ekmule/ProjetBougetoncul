import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_category_service.dart';

void main() {
  const service = TaskCategoryService();
  final now = DateTime(2026, 3, 15);

  test('moveToCategory met à jour la catégorie persistée', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Test',
      category: TaskCategoryId.someday,
      now: now,
    );

    final moved = service.moveToCategory(task, TaskCategoryId.mustDo, now: now);

    expect(moved.category, TaskCategoryId.mustDo);
    expect(moved.syncVersion, 2);
  });

  test('moveToCategory vers AUJOURD HUI fixe category et plannedDate', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Test',
      category: TaskCategoryId.next,
      now: now,
    );

    final moved = service.moveToCategory(task, TaskCategoryId.today, now: now);

    expect(moved.category, TaskCategoryId.today);
    expect(moved.plannedDate, DateTime(2026, 3, 15));
  });

  test('moveToCategory vers ENSUITE efface plannedDate', () {
    final task = Task.createNew(
      id: 't1',
      title: 'Avec date',
      category: TaskCategoryId.next,
      plannedDate: now,
      now: now,
    );

    final moved = service.moveToCategory(task, TaskCategoryId.someday, now: now);

    expect(moved.category, TaskCategoryId.someday);
    expect(moved.plannedDate, isNull);
  });

  test('moveToCategory interdit les tâches inactives', () {
    final task = Task.createNew(id: 't1', title: 'Done', now: now).complete(
      now: now,
    );

    expect(
      () => service.moveToCategory(task, TaskCategoryId.next),
      throwsStateError,
    );
  });
}
