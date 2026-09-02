import 'package:equatable/equatable.dart';
import 'package:mya/core/extensions/datetime_extensions.dart';
import 'package:mya/domain/entities/sync_status.dart';
import 'package:mya/domain/entities/task_category.dart';
import 'package:mya/domain/entities/task_status.dart';

export 'sync_status.dart';
export 'task_category.dart';
export 'task_status.dart';

const _unset = Object();

/// Représente une tâche MYA — modèle domaine complet (voir docs/database.md).
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    required this.syncVersion,
    required this.syncStatus,
    this.userId,
    this.plannedDate,
    this.reminderAt,
    this.completedAt,
    this.deletedAt,
  });

  final String id;
  final String? userId;
  final String title;
  final TaskStatus status;
  final TaskCategoryId category;

  /// Date prévue (jour calendaire local, sans heure).
  final DateTime? plannedDate;

  /// Rappel notification (date + heure).
  final DateTime? reminderAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final int sortOrder;
  final int syncVersion;
  final SyncStatus syncStatus;

  /// Crée une nouvelle tâche active avec les métadonnées par défaut.
  factory Task.createNew({
    required String id,
    required String title,
    TaskCategoryId category = TaskCategoryId.next,
    DateTime? plannedDate,
    DateTime? reminderAt,
    String? userId,
    int sortOrder = 0,
    DateTime? now,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Le titre ne peut pas être vide.');
    }

    final timestamp = now ?? DateTime.now();

    return Task(
      id: id,
      userId: userId,
      title: trimmed,
      status: TaskStatus.active,
      category: category,
      plannedDate: plannedDate?.dateOnly,
      reminderAt: reminderAt,
      createdAt: timestamp,
      updatedAt: timestamp,
      sortOrder: sortOrder,
      syncVersion: 1,
      syncStatus: SyncStatus.pending,
    );
  }

  bool get isActive => status == TaskStatus.active && deletedAt == null;

  bool get isCompleted => status == TaskStatus.completed;

  bool get isDeleted => status == TaskStatus.deleted || deletedAt != null;

  /// Marque la tâche comme terminée (règle : `completed_at` renseigné).
  Task complete({DateTime? now}) {
    _assertNotDeleted();
    if (status == TaskStatus.completed) return this;

    final timestamp = now ?? DateTime.now();

    return copyWith(
      status: TaskStatus.completed,
      completedAt: timestamp,
      updatedAt: timestamp,
      syncVersion: syncVersion + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Réouvre une tâche terminée (retour dans la liste active).
  Task reopen({DateTime? now}) {
    if (!isCompleted || isDeleted) return this;

    final timestamp = now ?? DateTime.now();

    return copyWith(
      status: TaskStatus.active,
      updatedAt: timestamp,
      syncVersion: syncVersion + 1,
      syncStatus: SyncStatus.pending,
      clearCompletedAt: true,
    );
  }

  /// Soft delete pour la synchronisation (règle : `deleted_at` renseigné).
  Task softDelete({DateTime? now}) {
    if (isDeleted) return this;

    final timestamp = now ?? DateTime.now();

    return copyWith(
      status: TaskStatus.deleted,
      deletedAt: timestamp,
      updatedAt: timestamp,
      syncVersion: syncVersion + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Applique une modification métier (incrémente syncVersion, marque pending).
  Task touch({
    String? title,
    TaskCategoryId? category,
    DateTime? plannedDate,
    DateTime? reminderAt,
    int? sortOrder,
    DateTime? now,
    bool clearPlannedDate = false,
    bool clearReminderAt = false,
  }) {
    _assertNotDeleted();

    if (title != null && title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Le titre ne peut pas être vide.');
    }

    final timestamp = now ?? DateTime.now();

    return copyWith(
      title: title?.trim(),
      category: category,
      plannedDate: plannedDate?.dateOnly ?? _unset,
      reminderAt: reminderAt ?? _unset,
      sortOrder: sortOrder,
      updatedAt: timestamp,
      syncVersion: syncVersion + 1,
      syncStatus: SyncStatus.pending,
      clearPlannedDate: clearPlannedDate,
      clearReminderAt: clearReminderAt,
    );
  }

  Task copyWith({
    Object? userId = _unset,
    String? title,
    TaskStatus? status,
    TaskCategoryId? category,
    Object? plannedDate = _unset,
    Object? reminderAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? completedAt = _unset,
    Object? deletedAt = _unset,
    int? sortOrder,
    int? syncVersion,
    SyncStatus? syncStatus,
    bool clearPlannedDate = false,
    bool clearReminderAt = false,
    bool clearCompletedAt = false,
    bool clearDeletedAt = false,
  }) {
    return Task(
      id: id,
      userId: userId == _unset ? this.userId : userId as String?,
      title: title ?? this.title,
      status: status ?? this.status,
      category: category ?? this.category,
      plannedDate: clearPlannedDate
          ? null
          : plannedDate == _unset
              ? this.plannedDate
              : (plannedDate as DateTime?)?.dateOnly,
      reminderAt: clearReminderAt
          ? null
          : reminderAt == _unset
              ? this.reminderAt
              : reminderAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt
          ? null
          : completedAt == _unset
              ? this.completedAt
              : completedAt as DateTime?,
      deletedAt: clearDeletedAt
          ? null
          : deletedAt == _unset
              ? this.deletedAt
              : deletedAt as DateTime?,
      sortOrder: sortOrder ?? this.sortOrder,
      syncVersion: syncVersion ?? this.syncVersion,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  void _assertNotDeleted() {
    if (isDeleted) {
      throw StateError('Impossible de modifier une tâche supprimée ($id).');
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        status,
        category,
        plannedDate,
        reminderAt,
        createdAt,
        updatedAt,
        completedAt,
        deletedAt,
        sortOrder,
        syncVersion,
        syncStatus,
      ];
}
