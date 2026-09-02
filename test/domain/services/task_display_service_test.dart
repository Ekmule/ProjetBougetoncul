import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/task_display_service.dart';

void main() {
  const service = TaskDisplayService();
  final today = DateTime(2026, 3, 15, 12);

  Task task({
    required String id,
    TaskCategoryId category = TaskCategoryId.next,
    DateTime? plannedDate,
    TaskStatus status = TaskStatus.active,
  }) {
    return Task.createNew(
      id: id,
      title: id,
      category: category,
      plannedDate: plannedDate,
      now: today,
    ).copyWith(status: status);
  }

  test('plannedDate aujourd hui → section AUJOURD HUI', () {
    final result = service.displayCategory(
      task(id: 'a', plannedDate: today),
      today,
    );

    expect(result, TaskCategoryId.today);
  });

  test('plannedDate en retard → section urgente', () {
    final result = service.displayCategory(
      task(id: 'a', plannedDate: DateTime(2026, 3, 10)),
      today,
    );

    expect(result, TaskCategoryId.mustDo);
  });

  test('must_do manuel reste urgent sans date', () {
    final result = service.displayCategory(
      task(id: 'a', category: TaskCategoryId.mustDo),
      today,
    );

    expect(result, TaskCategoryId.mustDo);
  });

  test('next sans date reste ENSUITE', () {
    final result = service.displayCategory(
      task(id: 'a', category: TaskCategoryId.next),
      today,
    );

    expect(result, TaskCategoryId.next);
  });

  test('groupActiveTasks ignore les tâches supprimées', () {
    final active = task(id: 'active', category: TaskCategoryId.next);
    final deleted = task(id: 'deleted').softDelete(now: today);

    final grouped = service.groupActiveTasks([active, deleted], today);

    expect(grouped[TaskCategoryId.next], [active]);
    expect(grouped.values.expand((tasks) => tasks), hasLength(1));
  });

  test('completedTasks ignore les soft-deleted', () {
    final completed = task(id: 'done').complete(now: today);
    final deletedCompleted = task(id: 'gone')
        .complete(now: today)
        .softDelete(now: today);

    final result = service.completedTasks([completed, deletedCompleted]);

    expect(result, [completed]);
  });
}
