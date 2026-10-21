import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/sync/sync_ui_state.dart';
import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/l10n/mya_localizations.dart';

void main() {
  group('CloudSyncSnapshot', () {
    const user = AuthUser(id: 'user-1', email: 'test@example.com');
    final l10n = MyaLocalizations.lookupFromLocale(const Locale('fr'));

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
        ).statusLabel(l10n),
        'Synchronisation…',
      );
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.pending,
          user: user,
        ).statusLabel(l10n),
        'En attente cloud',
      );
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.synced,
          user: user,
        ).statusLabel(l10n),
        'Synchronisé',
      );
    });

    test('résumé compte + sync', () {
      expect(
        CloudSyncSnapshot(
          state: CloudSyncUiState.synced,
          user: user,
        ).accountAndSyncSummary(l10n: l10n, isConfigured: true),
        'Connecté : test@example.com\nSynchronisé',
      );
    });
  });
}
