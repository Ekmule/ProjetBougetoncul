import 'package:drift/drift.dart';
import 'package:mya/application/sync/sync_operation.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/models/task_cloud_mapper.dart';
import 'package:mya/data/models/task_mapper.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Implémentation Drift de [TaskRepository].
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(
    AppDatabase database, {
    String? activeUserId,
    bool filterByOwner = false,
  }) : this._(database, activeUserId, filterByOwner);

  DriftTaskRepository._(
    this._database,
    this._activeUserId,
    this._filterByOwner,
  );

  final AppDatabase _database;
  final String? _activeUserId;
  final bool _filterByOwner;
  static const _uuid = Uuid();

  @override
  Stream<List<Task>> watchTasks() {
    final query = _database.select(_database.taskEntries);
    if (_filterByOwner) {
      query.where(_belongsToActiveUser);
    }
    query.orderBy([
      (task) => OrderingTerm.desc(task.updatedAt),
      (task) => OrderingTerm.asc(task.sortOrder),
    ]);
    return query.watch().map((rows) => rows.map(TaskMapper.fromRow).toList());
  }

  @override
  Future<Task?> findById(String id) async {
    final row =
        await (_database.select(
              _database.taskEntries,
            )..where((task) => task.id.equals(id) & _belongsToActiveUser(task)))
            .getSingleOrNull();
    return row == null ? null : TaskMapper.fromRow(row);
  }

  @override
  Future<void> addTask(Task task) async {
    await _database.transaction(() async {
      await _database
          .into(_database.taskEntries)
          .insert(TaskMapper.toCompanion(task));
      await _enqueue(task, SyncOperationKind.create);
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    await _database.transaction(() async {
      final previousRow =
          await (_database.select(_database.taskEntries)..where(
                (row) => row.id.equals(task.id) & _belongsToActiveUser(row),
              ))
              .getSingleOrNull();
      if (previousRow == null) return;

      await (_database.update(
            _database.taskEntries,
          )..where((row) => row.id.equals(task.id) & _belongsToActiveUser(row)))
          .write(TaskMapper.toUpdateCompanion(task));
      await _enqueue(task, _operationFor(previousRow, task));
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    await _database.transaction(() async {
      final row =
          await (_database.select(_database.taskEntries)..where(
                (task) => task.id.equals(id) & _belongsToActiveUser(task),
              ))
              .getSingleOrNull();
      if (row == null) return;

      final existing = TaskMapper.fromRow(row);
      if (existing.isDeleted) return;
      final deleted = existing.softDelete();

      await (_database.update(_database.taskEntries)
            ..where((task) => task.id.equals(id) & _belongsToActiveUser(task)))
          .write(TaskMapper.toUpdateCompanion(deleted));
      await _enqueue(deleted, SyncOperationKind.delete);
    });
  }

  SyncOperationKind _operationFor(TaskRow previousRow, Task task) {
    if (task.isDeleted) return SyncOperationKind.delete;
    final previous = TaskMapper.fromRow(previousRow);
    if (!previous.isCompleted && task.isCompleted) {
      return SyncOperationKind.complete;
    }
    return SyncOperationKind.update;
  }

  Future<void> _enqueue(Task task, SyncOperationKind kind) async {
    await (_database.delete(_database.syncOperations)..where(
          (row) =>
              row.entityType.equals('task') &
              row.entityId.equals(task.id) &
              row.status.isNotIn([SyncOperationState.sent.dbValue]),
        ))
        .go();

    await _database
        .into(_database.syncOperations)
        .insert(
          SyncOperationsCompanion.insert(
            id: _uuid.v4(),
            entityType: 'task',
            entityId: task.id,
            operation: kind.name,
            payload: TaskCloudMapper.encodeQueuePayload(task),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Expression<bool> _belongsToActiveUser($TaskEntriesTable row) {
    if (!_filterByOwner) return const Constant(true);
    final activeUserId = _activeUserId;
    if (activeUserId == null) return row.userId.isNull();
    return row.userId.isNull() | row.userId.equals(activeUserId);
  }
}
