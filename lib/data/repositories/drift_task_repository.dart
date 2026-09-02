import 'package:drift/drift.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/models/task_mapper.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/repositories/task_repository.dart';

/// Implémentation Drift de [TaskRepository].
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Task>> watchTasks() {
    return (_database.select(_database.taskEntries)
          ..orderBy([
            (task) => OrderingTerm.desc(task.updatedAt),
            (task) => OrderingTerm.asc(task.sortOrder),
          ]))
        .watch()
        .map((rows) => rows.map(TaskMapper.fromRow).toList());
  }

  @override
  Future<Task?> findById(String id) async {
    final row = await (_database.select(_database.taskEntries)
          ..where((task) => task.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : TaskMapper.fromRow(row);
  }

  @override
  Future<void> addTask(Task task) async {
    await _database.into(_database.taskEntries).insert(
          TaskMapper.toCompanion(task),
        );
  }

  @override
  Future<void> updateTask(Task task) async {
    await (_database.update(_database.taskEntries)
          ..where((row) => row.id.equals(task.id)))
        .write(TaskMapper.toUpdateCompanion(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    final existing = await findById(id);
    if (existing == null || existing.isDeleted) return;
    await updateTask(existing.softDelete());
  }
}
