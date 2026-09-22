import 'dart:async';

import 'package:mya/core/utils/app_logger.dart';
import 'package:mya/platform/tray_service.dart';
import 'package:tray_manager/tray_manager.dart';

/// Menu contextuel tray Windows via tray_manager (ADR-010).
class WindowsTrayService with TrayListener implements TrayService {
  WindowsTrayService(this._actions, this._readMenuState);

  final TrayActions _actions;
  final TrayMenuState Function() _readMenuState;
  var _initialized = false;

  /// Windows Shell charge le tray via `LoadImage(IMAGE_ICON)` — un .ico léger
  /// est requis. Les PNG pastille (plusieurs Mo) provoquent un tray instable.
  static const _trayIconPath = 'assets/icons/tray_icon.ico';

  @override
  Future<void> initialize({String? iconAssetPath}) async {
    if (_initialized) return;

    await trayManager.setIcon(_trayIconPath);
    await trayManager.setToolTip(
      'MYA — clic gauche : ouvrir · clic droit : menu',
    );
    trayManager.addListener(this);
    _initialized = true;
    await updateMenu();
  }

  @override
  Future<void> updateMenu() async {
    if (!_initialized) return;

    final state = _readMenuState();
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'open', label: 'Ouvrir MYA'),
          MenuItem(
            key: 'toggle_visible',
            label: state.bubbleVisible
                ? 'Masquer la pastille'
                : 'Afficher la pastille',
          ),
          MenuItem(
            key: 'toggle_aot',
            label: state.alwaysOnTop
                ? 'Toujours au-dessus : activé'
                : 'Toujours au-dessus : désactivé',
          ),
          MenuItem(
            key: 'toggle_startup',
            label: state.startupEnabled
                ? 'Démarrage avec Windows : activé'
                : 'Démarrage avec Windows : désactivé',
          ),
          MenuItem(
            key: 'configure_hotkey',
            label: 'Raccourci : ${state.hotkeyLabel}…',
          ),
          MenuItem(key: 'configure_account', label: state.authLabel),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: 'Quitter'),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    trayManager.removeListener(this);
    if (_initialized) {
      await trayManager.destroy();
      _initialized = false;
    }
  }

  /// Affiche le menu contextuel (ex. aide découverte au premier lancement).
  Future<void> popUpContextMenu() async {
    await _showContextMenu();
  }

  Future<void> _showContextMenu() async {
    if (!_initialized) return;

    try {
      await updateMenu();
      // ignore: deprecated_member_use
      await trayManager.popUpContextMenu(bringAppToFront: true);
    } catch (error, stackTrace) {
      appLogger.w(
        'Impossible d\'afficher le menu tray',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _dispatchSync(void Function() action) {
    // Les événements du tray arrivent déjà sur l'isolate UI. Un
    // addPostFrameCallback peut ne jamais s'exécuter lorsque la fenêtre est
    // inactive et qu'aucune nouvelle frame n'est planifiée.
    action();
  }

  void _dispatchAsync(Future<void> Function() action) {
    unawaited(action());
  }

  @override
  void onTrayIconMouseDown() {
    _dispatchSync(_actions.openMya);
  }

  @override
  void onTrayIconRightMouseDown() {
    _dispatchAsync(_showContextMenu);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open':
        _dispatchSync(_actions.openMya);
        return;
      case 'toggle_visible':
        _dispatchSync(_actions.toggleBubbleVisible);
        unawaited(updateMenu());
        return;
      case 'toggle_aot':
        _dispatchSync(_actions.toggleAlwaysOnTop);
        unawaited(updateMenu());
        return;
      case 'toggle_startup':
        unawaited(_toggleStartup());
        return;
      case 'configure_hotkey':
        _dispatchSync(_actions.configureHotkey);
        return;
      case 'configure_account':
        _dispatchSync(_actions.configureAccount);
        return;
      case 'quit':
        unawaited(_quit());
        return;
    }
  }

  Future<void> _toggleStartup() async {
    await _actions.toggleStartupEnabled();
    await updateMenu();
  }

  Future<void> _quit() async {
    if (_initialized) {
      await trayManager.destroy();
      _initialized = false;
    }
    await _actions.quit();
  }
}
