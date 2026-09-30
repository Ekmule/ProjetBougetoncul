import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_providers.dart';
import 'package:mya/application/sync/sync_service.dart';
import 'package:mya/application/sync/sync_ui_state.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/domain/entities/sync_status.dart';

final syncActivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(syncServiceProvider);
  return _syncActivityStream(service);
});

Stream<bool> _syncActivityStream(SyncService service) async* {
  yield service.isSyncing;
  yield* service.syncingStream;
}

/// État cloud agrégé pour l'UI (connexion + activité + file locale).
final cloudSyncStatusProvider = Provider<CloudSyncSnapshot>((ref) {
  final configured = ref.watch(authConfiguredProvider);
  if (!configured) {
    return const CloudSyncSnapshot(state: CloudSyncUiState.notConfigured);
  }

  final user = ref.watch(authUserProvider).value;
  if (user == null) {
    return const CloudSyncSnapshot(state: CloudSyncUiState.local);
  }

  final syncing = ref
      .watch(syncActivityProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => ref.read(syncServiceProvider).isSyncing,
      );
  if (syncing) {
    return CloudSyncSnapshot(state: CloudSyncUiState.syncing, user: user);
  }

  final hasPending = ref
      .watch(tasksProvider)
      .any((task) => task.syncStatus == SyncStatus.pending);
  if (hasPending) {
    return CloudSyncSnapshot(state: CloudSyncUiState.pending, user: user);
  }

  return CloudSyncSnapshot(state: CloudSyncUiState.synced, user: user);
});
