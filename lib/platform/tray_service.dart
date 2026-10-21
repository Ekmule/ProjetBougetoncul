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
    required this.tooltip,
    required this.openLabel,
    required this.toggleVisibleLabel,
    required this.toggleAotLabel,
    required this.toggleStartupLabel,
    required this.hotkeyMenuLabel,
    required this.authLabel,
    required this.quitLabel,
  });

  final String tooltip;
  final String openLabel;
  final String toggleVisibleLabel;
  final String toggleAotLabel;
  final String toggleStartupLabel;
  final String hotkeyMenuLabel;
  final String authLabel;
  final String quitLabel;
}
