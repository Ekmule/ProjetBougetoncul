import 'package:mya/domain/entities/task.dart';

/// Résolution déterministe des conflits selon ADR-015.
class SyncConflictResolver {
  const SyncConflictResolver();

  Task resolve({
    required Task local,
    required Task remote,
    required bool hasPendingLocalOperation,
  }) {
    if (hasPendingLocalOperation) return local;

    final localDeletion = local.deletedAt;
    final remoteDeletion = remote.deletedAt;

    if (localDeletion != null &&
        (remoteDeletion == null || localDeletion.isAfter(remote.updatedAt))) {
      return local;
    }
    if (remoteDeletion != null &&
        (localDeletion == null || remoteDeletion.isAfter(local.updatedAt))) {
      return remote;
    }

    if (remote.updatedAt.isAfter(local.updatedAt)) return remote;
    return local;
  }
}
