import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/bubble_device_settings.dart';
import 'package:mya/data/providers/device_settings_providers.dart';

/// Paramètres initiaux de la pastille — chargés au bootstrap (D10).
final bubbleInitialSettingsProvider = Provider<BubbleDeviceSettings>((ref) {
  throw UnimplementedError(
    'bubbleInitialSettingsProvider must be overridden at startup.',
  );
});

/// Mode d'affichage de la pastille / fenêtre.
enum BubbleViewMode {
  /// Pastille seule (petit cercle).
  bubble,

  /// Aperçu au survol (quelques tâches).
  preview,

  /// Panneau complet.
  panel,
}

/// État de l'interface pastille (taille fenêtre, Always-on-Top, visibilité).
class BubbleUiState {
  const BubbleUiState({
    this.viewMode = BubbleViewMode.bubble,
    this.alwaysOnTop = true,
    this.isVisible = true,
    this.showQuickAdd = false,
  });

  final BubbleViewMode viewMode;
  final bool alwaysOnTop;
  final bool isVisible;
  final bool showQuickAdd;

  BubbleUiState copyWith({
    BubbleViewMode? viewMode,
    bool? alwaysOnTop,
    bool? isVisible,
    bool? showQuickAdd,
  }) {
    return BubbleUiState(
      viewMode: viewMode ?? this.viewMode,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      isVisible: isVisible ?? this.isVisible,
      showQuickAdd: showQuickAdd ?? this.showQuickAdd,
    );
  }
}

/// Contrôle l'état visuel de la pastille Windows.
final bubbleUiProvider =
    NotifierProvider<BubbleUiNotifier, BubbleUiState>(BubbleUiNotifier.new);

class BubbleUiNotifier extends Notifier<BubbleUiState> {
  @override
  BubbleUiState build() {
    final initial = ref.read(bubbleInitialSettingsProvider);
    return BubbleUiState(
      alwaysOnTop: initial.alwaysOnTop,
      isVisible: initial.bubbleVisible,
    );
  }

  void setViewMode(BubbleViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void toggleAlwaysOnTop() {
    state = state.copyWith(alwaysOnTop: !state.alwaysOnTop);
  }

  void setAlwaysOnTop(bool value) {
    state = state.copyWith(alwaysOnTop: value);
  }

  void hideBubble() {
    state = state.copyWith(isVisible: false, viewMode: BubbleViewMode.bubble);
    unawaited(ref.read(deviceSettingsStoreProvider).saveBubbleVisible(false));
  }

  void showBubble() {
    state = state.copyWith(isVisible: true);
    unawaited(ref.read(deviceSettingsStoreProvider).saveBubbleVisible(true));
  }

  void openQuickAdd() {
    _openVisible(
      viewMode: BubbleViewMode.panel,
      showQuickAdd: true,
    );
  }

  void closeQuickAdd() {
    state = state.copyWith(showQuickAdd: false);
  }

  void collapseToBubble() {
    state = state.copyWith(
      viewMode: BubbleViewMode.bubble,
      showQuickAdd: false,
    );
  }

  void openPanel() {
    _openVisible(
      viewMode: BubbleViewMode.panel,
      showQuickAdd: false,
    );
  }

  void openPreview() {
    if (state.viewMode != BubbleViewMode.panel) {
      _openVisible(viewMode: BubbleViewMode.preview);
    }
  }

  /// Toute interaction qui ouvre une vue implique que la fenêtre est visible.
  ///
  /// Cette invariance évite un état incohérent où Windows affiche encore la
  /// pastille alors que la préférence persistée vaut `bubbleVisible=false`.
  void _openVisible({
    required BubbleViewMode viewMode,
    bool? showQuickAdd,
  }) {
    final wasHidden = !state.isVisible;
    state = state.copyWith(
      isVisible: true,
      viewMode: viewMode,
      showQuickAdd: showQuickAdd,
    );
    if (wasHidden) {
      unawaited(ref.read(deviceSettingsStoreProvider).saveBubbleVisible(true));
    }
  }
}
