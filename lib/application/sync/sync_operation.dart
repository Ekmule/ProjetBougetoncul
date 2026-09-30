enum SyncOperationKind {
  create,
  update,
  complete,
  delete;

  static SyncOperationKind fromName(String value) {
    return values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => throw ArgumentError('Opération de sync inconnue: $value'),
    );
  }
}

enum SyncOperationState {
  pending,
  inProgress,
  sent,
  failed;

  String get dbValue => switch (this) {
    SyncOperationState.inProgress => 'in_progress',
    _ => name,
  };
}

class QueuedSyncOperation {
  const QueuedSyncOperation({
    required this.id,
    required this.entityId,
    required this.kind,
    required this.retryCount,
  });

  final String id;
  final String entityId;
  final SyncOperationKind kind;
  final int retryCount;
}
