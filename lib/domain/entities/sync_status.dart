/// État de synchronisation locale — colonne `sync_status` (Drift uniquement).
enum SyncStatus {
  synced,
  pending,
  failed,
}

extension SyncStatusDb on SyncStatus {
  String get dbValue => name;

  static SyncStatus fromDb(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw ArgumentError('Statut de sync inconnu: $value'),
    );
  }
}
