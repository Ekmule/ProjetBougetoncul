import 'package:mya/data/local/database.dart';
import 'package:mya/data/models/task_mapper.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:uuid/uuid.dart';

/// Données initiales pour le premier lancement.
abstract final class DatabaseSeeder {
  static Future<void> seedSampleTasksIfEmpty(AppDatabase database) async {
    final existing = await (database.select(database.taskEntries)..limit(1)).get();
    if (existing.isNotEmpty) return;

    const uuid = Uuid();
    final now = DateTime.now();

    final samples = [
      Task.createNew(
        id: uuid.v4(),
        title: 'Faire les portraits',
        category: TaskCategoryId.next,
        plannedDate: now,
        now: now,
      ),
      Task.createNew(
        id: uuid.v4(),
        title: 'Corriger le dialogue',
        category: TaskCategoryId.next,
        now: now,
      ),
      Task.createNew(
        id: uuid.v4(),
        title: 'Refaire les icônes',
        category: TaskCategoryId.someday,
        now: now,
      ),
    ];

    await database.batch((batch) {
      for (final task in samples) {
        batch.insert(database.taskEntries, TaskMapper.toCompanion(task));
      }
    });
  }
}
