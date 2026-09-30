import 'dart:convert';

import 'package:mya/data/local/date_codec.dart';
import 'package:mya/domain/entities/task.dart';

/// Mapping d'une tâche entre le domaine local et PostgreSQL/Supabase.
abstract final class TaskCloudMapper {
  static Map<String, dynamic> toJson(Task task, {required String userId}) {
    return {
      'id': task.id,
      'user_id': userId,
      'title': task.title,
      'status': task.status.dbValue,
      'category': task.category.dbValue,
      'planned_date': DateCodec.toPlannedDateString(task.plannedDate),
      'reminder_at': _toTimestamp(task.reminderAt),
      'sort_order': task.sortOrder,
      'sync_version': task.syncVersion,
      'created_at': _toTimestamp(task.createdAt),
      'updated_at': _toTimestamp(task.updatedAt),
      'completed_at': _toTimestamp(task.completedAt),
      'deleted_at': _toTimestamp(task.deletedAt),
    };
  }

  /// Payload local de la file. `user_id` reste nullable avant connexion.
  static String encodeQueuePayload(Task task) {
    final json = {
      'id': task.id,
      'user_id': task.userId,
      'title': task.title,
      'status': task.status.dbValue,
      'category': task.category.dbValue,
      'planned_date': DateCodec.toPlannedDateString(task.plannedDate),
      'reminder_at': _toTimestamp(task.reminderAt),
      'sort_order': task.sortOrder,
      'sync_version': task.syncVersion,
      'created_at': _toTimestamp(task.createdAt),
      'updated_at': _toTimestamp(task.updatedAt),
      'completed_at': _toTimestamp(task.completedAt),
      'deleted_at': _toTimestamp(task.deletedAt),
    };
    return jsonEncode(json);
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      status: TaskStatusDb.fromDb(json['status'] as String),
      category: TaskCategoryIdDb.fromDb(json['category'] as String),
      plannedDate: DateCodec.fromPlannedDateString(
        json['planned_date'] as String?,
      ),
      reminderAt: _fromTimestamp(json['reminder_at']),
      sortOrder: (json['sort_order'] as num).toInt(),
      syncVersion: (json['sync_version'] as num).toInt(),
      createdAt: _fromRequiredTimestamp(json['created_at']),
      updatedAt: _fromRequiredTimestamp(json['updated_at']),
      completedAt: _fromTimestamp(json['completed_at']),
      deletedAt: _fromTimestamp(json['deleted_at']),
      syncStatus: SyncStatus.synced,
    );
  }

  static String? _toTimestamp(DateTime? value) =>
      value?.toUtc().toIso8601String();

  static DateTime _fromRequiredTimestamp(Object? value) {
    final parsed = _fromTimestamp(value);
    if (parsed == null) {
      throw FormatException('Timestamp Supabase manquant.');
    }
    return parsed;
  }

  static DateTime? _fromTimestamp(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toLocal();
  }
}
