import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/sync/sync_ui_state.dart';
import 'package:mya/domain/entities/auth_user.dart';

void main() {
  group('CloudSyncSnapshot', () {
    const user = AuthUser(id: 'user-1', email: 'test@example.com');

    test('affiche une pastille uniquement quand connecté', () {
      expect(
        const CloudSyncSnapshot(state: CloudSyncUiState.local)
            .showsConnectedBadge,
        isFalse,
      );
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.synced,
          user: user,
        ).showsConnectedBadge,
        isTrue,
      );
    });

    test('libellés de statut', () {
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.syncing,
          user: user,
        ).statusLabel(),
        'Synchronisation…',
      );
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.pending,
          user: user,
        ).statusLabel(),
        'En attente cloud',
      );
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.synced,
          user: user,
        ).statusLabel(),
        'Synchronisé',
      );
    });

    test('résumé compte + sync', () {
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.synced,
          user: user,
        ).accountAndSyncSummary(isConfigured: true),
        'Connecté : test@example.com\nSynchronisé',
      );
    });
  });
}
