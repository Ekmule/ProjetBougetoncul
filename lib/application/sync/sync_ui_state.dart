import 'package:flutter/material.dart';
import 'package:mya/domain/entities/auth_user.dart';

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

  String statusLabel() {
    return switch (state) {
      CloudSyncUiState.notConfigured => 'Sync cloud non configurée',
      CloudSyncUiState.local => 'Mode local',
      CloudSyncUiState.syncing => 'Synchronisation…',
      CloudSyncUiState.pending => 'En attente cloud',
      CloudSyncUiState.synced => 'Synchronisé',
    };
  }

  String accountAndSyncSummary({required bool isConfigured}) {
    if (!isConfigured) return 'Sync cloud non configurée';
    if (user == null) return 'Mode local — non connecté';
    final account = user!.email ?? user!.displayName ?? 'Compte connecté';
    return 'Connecté : $account\n${statusLabel()}';
  }
}
