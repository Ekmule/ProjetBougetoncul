import 'package:drift/drift.dart';
import 'package:mya/application/sync/sync_operation.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/models/task_cloud_mapper.dart';
import 'package:mya/data/models/task_mapper.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:uuid/uuid.dart';

/// Opérations SQLite réservées au moteur de synchronisation.
///
/// Elles contournent volontairement [DriftTaskRepository] pour ne pas recréer
/// une opération de file quand un changement vient du cloud.
class SyncLocalStore {
  SyncLocalStore(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<List<String>> claimUnownedTasks(String userId) async {
    return _database.transaction(() async {
      final rows = await (_database.select(
        _database.taskEntries,
      )..where((row) => row.userId.isNull())).get();
      if (rows.isEmpty) return const [];

      await (_database.update(_database.taskEntries)
            ..where((row) => row.userId.isNull()))
          .write(TaskEntriesCompanion(userId: Value(userId)));
      return rows.map((row) => row.id).toList(growable: false);
    });
  }

  Future<void> releaseClaimedTasks(
    Iterable<String> taskIds,
    String userId,
  ) async {
    final ids = taskIds.toList(growable: false);
    if (ids.isEmpty) return;
    await (_database.update(_database.taskEntries)
          ..where((row) => row.id.isIn(ids) & row.userId.equals(userId)))
        .write(const TaskEntriesCompanion(userId: Value(null)));
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    final rows = await (_database.select(
      _database.taskEntries,
    )..where((row) => row.userId.isNull() | row.userId.equals(userId))).get();
    return rows.map(TaskMapper.fromRow).toList(growable: false);
  }

  Future<Task?> findTask(String id) async {
    final row = await (_database.select(
      _database.taskEntries,
    )..where((task) => task.id.equals(id))).getSingleOrNull();
    return row == null ? null : TaskMapper.fromRow(row);
  }

  Future<List<QueuedSyncOperation>> getRetryableOperations() async {
    final rows =
        await (_database.select(_database.syncOperations)
              ..where(
                (row) =>
                    (row.status.equals(SyncOperationState.pending.dbValue) |
                    row.status.equals(SyncOperationState.failed.dbValue)),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();

    return rows
        .map(
          (row) => QueuedSyncOperation(
            id: row.id,
            entityId: row.entityId,
            kind: SyncOperationKind.fromName(row.operation),
            retryCount: row.retryCount,
          ),
        )
        .toList(growable: false);
  }

  Future<void> recoverInterruptedOperations() {
    return (_database.update(_database.syncOperations)..where(
          (row) => row.status.equals(SyncOperationState.inProgress.dbValue),
        ))
        .write(
          SyncOperationsCompanion(
            status: Value(SyncOperationState.pending.dbValue),
          ),
        );
  }

  Future<void> ensureTaskQueued(Task task) async {
    await _database.transaction(() async {
      if (await hasOutstandingOperation(task.id)) return;
      await _database
          .into(_database.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              id: _uuid.v4(),
              entityType: 'task',
              entityId: task.id,
              operation: SyncOperationKind.create.name,
              payload: TaskCloudMapper.encodeQueuePayload(task),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    });
  }

  Future<bool> hasOutstandingOperation(String entityId) async {
    final row =
        await (_database.select(_database.syncOperations)
              ..where(
                (operation) =>
                    operation.entityId.equals(entityId) &
                    operation.status.isNotIn([SyncOperationState.sent.dbValue]),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<bool> hasOutstandingOperationsForUser(String userId) {
    return _hasOperationsForUser(userId);
  }

  Future<bool> hasRetryableOperationsForUser(String userId) {
    return _hasOperationsForUser(userId);
  }

  Future<bool> _hasOperationsForUser(String userId) async {
    final operations =
        await (_database.select(_database.syncOperations)..where(
              (row) => row.status.isNotIn([SyncOperationState.sent.dbValue]),
            ))
            .get();

    for (final operation in operations) {
      final task = await findTask(operation.entityId);
      if (task != null && (task.userId == null || task.userId == userId)) {
        return true;
      }
    }
    return false;
  }

  Future<void> markOperationInProgress(String id) {
    return (_database.update(
      _database.syncOperations,
    )..where((row) => row.id.equals(id))).write(
      SyncOperationsCompanion(
        status: Value(SyncOperationState.inProgress.dbValue),
        lastAttemptAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> markOperationSent(String id) {
    return (_database.update(
      _database.syncOperations,
    )..where((row) => row.id.equals(id))).write(
      SyncOperationsCompanion(status: Value(SyncOperationState.sent.dbValue)),
    );
  }

  Future<void> markOperationPending(String id) {
    return (_database.update(
      _database.syncOperations,
    )..where((row) => row.id.equals(id))).write(
      SyncOperationsCompanion(
        status: Value(SyncOperationState.pending.dbValue),
      ),
    );
  }

  Future<void> markOperationFailed(String id, int retryCount) {
    return (_database.update(
      _database.syncOperations,
    )..where((row) => row.id.equals(id))).write(
      SyncOperationsCompanion(
        status: Value(SyncOperationState.failed.dbValue),
        retryCount: Value(retryCount + 1),
        lastAttemptAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> applyRemoteTask(Task task) async {
    final synchronized = task.copyWith(syncStatus: SyncStatus.synced);
    await _database
        .into(_database.taskEntries)
        .insertOnConflictUpdate(TaskMapper.toCompanion(synchronized));
  }

  Future<bool> applyRemoteTaskIfQueueEmpty(Task task) async {
    return _database.transaction(() async {
      if (await hasOutstandingOperation(task.id)) return false;
      await _database
          .into(_database.taskEntries)
          .insertOnConflictUpdate(
            TaskMapper.toCompanion(
              task.copyWith(syncStatus: SyncStatus.synced),
            ),
          );
      return true;
    });
  }

  Future<void> completeOperation(String operationId, Task canonicalTask) async {
    await _database.transaction(() async {
      await markOperationSent(operationId);
      if (await hasOutstandingOperation(canonicalTask.id)) return;
      await _database
          .into(_database.taskEntries)
          .insertOnConflictUpdate(
            TaskMapper.toCompanion(
              canonicalTask.copyWith(syncStatus: SyncStatus.synced),
            ),
          );
    });
  }
}
