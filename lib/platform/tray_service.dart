/// Icône et menu de la zone de notification Windows (ADR-010).
abstract class TrayService {
  Future<void> initialize({String? iconAssetPath});

  Future<void> updateMenu();

  Future<void> dispose();
}

/// Callbacks du menu contextuel tray — injectés depuis l'UI.
abstract class TrayActions {
  void openMya();

  void toggleBubbleVisible();

  void toggleAlwaysOnTop();

  Future<void> toggleStartupEnabled();

  void configureHotkey();

  void configureAccount();

  Future<void> quit();
}

/// État affiché dans le menu tray.
class TrayMenuState {
  const TrayMenuState({
    required this.bubbleVisible,
    required this.alwaysOnTop,
    required this.startupEnabled,
    required this.hotkeyLabel,
    required this.authLabel,
  });

  final bool bubbleVisible;
  final bool alwaysOnTop;
  final bool startupEnabled;
  final String hotkeyLabel;
  final String authLabel;
}
