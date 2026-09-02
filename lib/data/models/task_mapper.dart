import 'package:drift/drift.dart';
import 'package:mya/data/local/database.dart';
import 'package:mya/data/local/date_codec.dart';
import 'package:mya/domain/entities/task.dart';

/// Mapping entité domaine ↔ lignes Drift.
abstract final class TaskMapper {
  static Task fromRow(TaskRow row) {
    return Task(
      id: row.id,
      userId: row.userId,
      title: row.title,
      status: TaskStatusDb.fromDb(row.status),
      category: TaskCategoryIdDb.fromDb(row.category),
      plannedDate: DateCodec.fromPlannedDateString(row.plannedDate),
      reminderAt: row.reminderAt == null
          ? null
          : DateCodec.fromUtcMillis(row.reminderAt!),
      sortOrder: row.sortOrder,
      syncVersion: row.syncVersion,
      createdAt: DateCodec.fromUtcMillis(row.createdAt),
      updatedAt: DateCodec.fromUtcMillis(row.updatedAt),
      completedAt: row.completedAt == null
          ? null
          : DateCodec.fromUtcMillis(row.completedAt!),
      deletedAt: row.deletedAt == null
          ? null
          : DateCodec.fromUtcMillis(row.deletedAt!),
      syncStatus: SyncStatusDb.fromDb(row.syncStatus),
    );
  }

  static TaskEntriesCompanion toCompanion(Task task) {
    return TaskEntriesCompanion.insert(
      id: task.id,
      userId: Value(task.userId),
      title: task.title,
      status: task.status.dbValue,
      category: task.category.dbValue,
      plannedDate: Value(DateCodec.toPlannedDateString(task.plannedDate)),
      reminderAt: Value(
        task.reminderAt == null
            ? null
            : DateCodec.toUtcMillis(task.reminderAt!),
      ),
      sortOrder: Value(task.sortOrder),
      syncVersion: Value(task.syncVersion),
      createdAt: DateCodec.toUtcMillis(task.createdAt),
      updatedAt: DateCodec.toUtcMillis(task.updatedAt),
      completedAt: Value(
        task.completedAt == null
            ? null
            : DateCodec.toUtcMillis(task.completedAt!),
      ),
      deletedAt: Value(
        task.deletedAt == null ? null : DateCodec.toUtcMillis(task.deletedAt!),
      ),
      syncStatus: Value(task.syncStatus.dbValue),
    );
  }

  static TaskEntriesCompanion toUpdateCompanion(Task task) {
    return TaskEntriesCompanion(
      id: Value(task.id),
      userId: Value(task.userId),
      title: Value(task.title),
      status: Value(task.status.dbValue),
      category: Value(task.category.dbValue),
      plannedDate: Value(DateCodec.toPlannedDateString(task.plannedDate)),
      reminderAt: Value(
        task.reminderAt == null
            ? null
            : DateCodec.toUtcMillis(task.reminderAt!),
      ),
      sortOrder: Value(task.sortOrder),
      syncVersion: Value(task.syncVersion),
      createdAt: Value(DateCodec.toUtcMillis(task.createdAt)),
      updatedAt: Value(DateCodec.toUtcMillis(task.updatedAt)),
      completedAt: Value(
        task.completedAt == null
            ? null
            : DateCodec.toUtcMillis(task.completedAt!),
      ),
      deletedAt: Value(
        task.deletedAt == null ? null : DateCodec.toUtcMillis(task.deletedAt!),
      ),
      syncStatus: Value(task.syncStatus.dbValue),
    );
  }
}
