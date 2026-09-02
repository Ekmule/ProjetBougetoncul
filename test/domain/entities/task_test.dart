import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';

void main() {
  group('Task.createNew', () {
    test('crée une tâche active avec sync pending', () {
      final now = DateTime(2026, 3, 15, 14, 30);
      final task = Task.createNew(
        id: 'task-1',
        title: '  Acheter du lait  ',
        plannedDate: DateTime(2026, 3, 16, 8, 0),
        now: now,
      );

      expect(task.title, 'Acheter du lait');
      expect(task.status, TaskStatus.active);
      expect(task.syncStatus, SyncStatus.pending);
      expect(task.syncVersion, 1);
      expect(task.plannedDate, DateTime(2026, 3, 16));
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
      expect(task.completedAt, isNull);
      expect(task.deletedAt, isNull);
    });

    test('rejette un titre vide', () {
      expect(
        () => Task.createNew(id: 'x', title: '   '),
        throwsArgumentError,
      );
    });
  });

  group('Task.complete', () {
    test('renseigne completedAt et incrémente syncVersion', () {
      final created = DateTime(2026, 1, 1);
      final completedAt = DateTime(2026, 1, 2);
      final task = Task.createNew(
        id: 'task-1',
        title: 'Test',
        now: created,
      );

      final completed = task.complete(now: completedAt);

      expect(completed.status, TaskStatus.completed);
      expect(completed.completedAt, completedAt);
      expect(completed.updatedAt, completedAt);
      expect(completed.syncVersion, 2);
      expect(completed.syncStatus, SyncStatus.pending);
    });
  });

  group('Task.softDelete', () {
    test('passe en deleted avec deletedAt', () {
      final now = DateTime(2026, 2, 1);
      final task = Task.createNew(id: 'task-1', title: 'Test', now: now);

      final deleted = task.softDelete(now: now);

      expect(deleted.status, TaskStatus.deleted);
      expect(deleted.deletedAt, now);
      expect(deleted.isDeleted, isTrue);
    });
  });

  group('Task.touch', () {
    test('modifie le titre et marque pending', () {
      final task = Task.createNew(
        id: 'task-1',
        title: 'Avant',
        now: DateTime(2026, 1, 1),
      );

      final updated = task.touch(
        title: 'Après',
        now: DateTime(2026, 1, 2),
      );

      expect(updated.title, 'Après');
      expect(updated.syncVersion, 2);
      expect(updated.syncStatus, SyncStatus.pending);
    });

    test('interdit la modification d une tâche supprimée', () {
      final task = Task.createNew(id: 'task-1', title: 'Test').softDelete();

      expect(() => task.touch(title: 'Nope'), throwsStateError);
    });
  });

  group('TaskCategoryIdDb', () {
    test('convertit must_do en mustDo', () {
      expect(TaskCategoryIdDb.fromDb('must_do'), TaskCategoryId.mustDo);
      expect(TaskCategoryId.mustDo.dbValue, 'must_do');
    });
  });
}
