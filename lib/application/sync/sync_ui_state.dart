import 'package:flutter/material.dart';
import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/l10n/mya_localizations.dart';

/// État agrégé affiché dans la pastille, l'aperçu et les paramètres (D4d).
enum CloudSyncUiState { notConfigured, local, syncing, pending, synced }

class CloudSyncSnapshot {
  const CloudSyncSnapshot({required this.state, this.user});

  final CloudSyncUiState state;
  final AuthUser? user;

  bool get showsConnectedBadge =>
      state == CloudSyncUiState.synced ||
      state == CloudSyncUiState.syncing ||
      state == CloudSyncUiState.pending;

  Color badgeColor(ColorScheme scheme) {
    return switch (state) {
      CloudSyncUiState.synced => Colors.greenAccent,
      CloudSyncUiState.syncing => Colors.lightGreenAccent,
      CloudSyncUiState.pending => Colors.amberAccent,
      _ => Colors.transparent,
    };
  }

  String statusLabel(MyaLocalizations l10n) {
    return l10n.syncStatusLabel(state);
  }

  String accountAndSyncSummary({
    required MyaLocalizations l10n,
    required bool isConfigured,
  }) {
    if (!isConfigured) return l10n.syncNotConfigured;
    if (user == null) return l10n.authLocalNotSignedIn;
    final account = user!.email ?? user!.displayName ?? l10n.authConnectedAccount;
    return '${l10n.authAccountSummary(account, isConfigured: true)}\n${statusLabel(l10n)}';
  }
}
